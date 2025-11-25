import asyncio

import websockets

import logging

import os

import sys

from typing import Optional, List

from google.cloud import speech_v2 as speech

from google.api_core import exceptions as api_exceptions

from google.api_core.client_options import ClientOptions



# ------------------- CONFIG / ENV -------------------

print("==== ENV CHECK ====")

for k in [

    "SPEECH_SAMPLE_RATE","SAMPLE_RATE_HERTZ","SPEECH_LANGUAGE","SPEECH_MODEL",

    "RECOGNIZER_FULL_NAME","GOOGLE_CLOUD_PROJECT","COMPOSITE_INTERIMS"

]:

    print(f"{k:20s}: {repr(os.environ.get(k))}")

print("===================\n")



def get_valid_sample_rate() -> int:

    val = os.environ.get("SPEECH_SAMPLE_RATE")

    if not val:

        return 16000

    try:

        rate = int(val)

        return rate if 8000 <= rate <= 48000 else 16000

    except Exception:

        return 16000



TARGET_SAMPLE_RATE = get_valid_sample_rate()

PORT               = int(os.environ.get("PORT", 8080))

HOST               = os.environ.get("WEBSOCKET_HOST", "0.0.0.0")

LANGUAGE_CODE      = os.environ.get("SPEECH_LANGUAGE", "en-US")

LOG_LEVEL          = os.environ.get("LOG_LEVEL", "DEBUG").upper()

GCP_PROJECT_ID     = os.environ.get("GOOGLE_CLOUD_PROJECT")

GCP_LOCATION       = os.environ.get("GCP_LOCATION", "us-central1")

RECOGNIZER_FULL_NAME = os.environ.get("RECOGNIZER_FULL_NAME")

MODEL              = os.environ.get("SPEECH_MODEL", "chirp")  # Using "chirp" to match recognizer configuration

USE_NATIVE_IS_FINAL = (os.environ.get("USE_NATIVE_IS_FINAL","true").lower()=="true")

STOP_FINAL_GRACE_SECONDS = float(os.environ.get("STOP_FINAL_GRACE_SECONDS","0"))

COMPOSITE_INTERIMS = (os.environ.get("COMPOSITE_INTERIMS","true").lower()=="true")



logging.basicConfig(

    level=LOG_LEVEL,

    format="%(asctime)s %(levelname)-8s %(name)s : %(message)s"

)

logger = logging.getLogger(__name__)

logging.getLogger("websockets").setLevel(logging.WARNING)  # reduce low-level noise



speech_client: Optional[speech.SpeechAsyncClient] = None

try:

    logger.info("Initializing Google Speech Async Client (v2)...")

    if not GCP_PROJECT_ID:

        import google.auth

        _, detected = google.auth.default()

        if detected:

            GCP_PROJECT_ID = detected

        else:

            raise ValueError("GOOGLE_CLOUD_PROJECT not set and auto-detect failed.")

    if not RECOGNIZER_FULL_NAME:

        raise ValueError("RECOGNIZER_FULL_NAME must be set.")



    if not (RECOGNIZER_FULL_NAME.startswith("projects/") and "/locations/" in RECOGNIZER_FULL_NAME and "/recognizers/" in RECOGNIZER_FULL_NAME):

        raise ValueError(f"Invalid recognizer name format: {RECOGNIZER_FULL_NAME}")



    # Derive location from recognizer if needed

    try:

        parts = RECOGNIZER_FULL_NAME.split("/")

        derived_loc = parts[3] if len(parts) > 3 and parts[2]=="locations" else GCP_LOCATION

    except Exception:

        derived_loc = GCP_LOCATION

    if derived_loc != GCP_LOCATION:

        logger.warning(f"Overriding GCP_LOCATION to recognizer location '{derived_loc}'")

        GCP_LOCATION = derived_loc



    client_opts = None

    if GCP_LOCATION != "global":

        client_opts = ClientOptions(api_endpoint=f"{GCP_LOCATION}-speech.googleapis.com")

        logger.info(f"Using regional endpoint: {GCP_LOCATION}-speech.googleapis.com")



    speech_client = speech.SpeechAsyncClient(client_options=client_opts)

    logger.info("Speech client ready.")

except Exception as e:

    logger.critical("Failed to init speech client", exc_info=True)

    sys.exit(1)



# ------------------- ENCODINGS -------------------

ENCODING_MAP = {

    "WEBM_OPUS":  speech.ExplicitDecodingConfig.AudioEncoding.WEBM_OPUS,

    "OGG_OPUS":   speech.ExplicitDecodingConfig.AudioEncoding.OGG_OPUS,

    "LINEAR16":   speech.ExplicitDecodingConfig.AudioEncoding.LINEAR16,

    "MP3":        speech.ExplicitDecodingConfig.AudioEncoding.MP3,

}

ENCODINGS_REQUIRING_RATE = {

    speech.ExplicitDecodingConfig.AudioEncoding.LINEAR16,

    speech.ExplicitDecodingConfig.AudioEncoding.MP3,

    speech.ExplicitDecodingConfig.AudioEncoding.MULAW,

    speech.ExplicitDecodingConfig.AudioEncoding.ALAW,

}



# ------------------- FINAL MERGE -------------------

def merge_final(cumulative: str, new_text: str) -> str:

    if not cumulative:

        return new_text

    if new_text.startswith(cumulative):

        return new_text

    if cumulative.startswith(new_text):

        return cumulative

    if not cumulative.endswith((" ","\n")):

        return cumulative + " " + new_text

    return cumulative + new_text



# ------------------- INTERIM COMPOSITOR -------------------

def merge_tail(base: str, tail: str) -> str:

    """

    Attach a short tail to base while avoiding duplication.

    - If tail already substring -> no change.

    - Try to overlap tail's prefix with base's suffix.

    """

    if not tail or tail.isspace():

        return base

    tail = tail.strip()

    if not base:

        return tail

    if tail in base:

        return base

    if base.endswith(tail):

        return base

    # Overlap search

    max_overlap = min(len(tail), 20)

    for k in range(max_overlap, 0, -1):

        if base.endswith(tail[:k]):

            return base + tail[k:]

    # Space awareness

    sep = "" if base.endswith((" ","\n")) or tail.startswith((" ",",",".","!","?",";")) else " "

    return base + sep + tail



def composite_interim_from_results(results) -> str:

    """

    Given multiple non-final results in a single API response:

    - Choose 'base' = highest stability (fallback: longest transcript).

    - Append other transcripts as tails.

    """

    if not results:

        return ""

    # Extract (transcript, stability)

    extracted = []

    for r in results:

        if not r.alternatives:

            continue

        t = (r.alternatives[0].transcript or "").strip()

        if not t:

            continue

        s = getattr(r, "stability", 0.0) or 0.0

        extracted.append((t, s))

    if not extracted:

        return ""

    # Pick base

    extracted.sort(key=lambda x: (x[1], len(x[0])), reverse=True)

    base, _ = extracted[0]

    for t, _ in extracted[1:]:

        base = merge_tail(base, t)

    return base



# ------------------- STREAM PROCESSOR -------------------

async def audio_stream_processor(websocket, request_generator_coro):

    client_id = f"{websocket.remote_address}"

    logger.info(f"[{client_id}] Stream start (COMPOSITE_INTERIMS={COMPOSITE_INTERIMS})")



    cumulative_final = ""

    last_sent_interim = ""

    response_count = 0

    last_response_time = asyncio.get_event_loop().time()

    RESPONSE_TIMEOUT = 60.0  # Timeout if no responses for 60 seconds



    try:

        # streaming_recognize returns a coroutine that must be awaited to get the async iterable
        response_stream = await speech_client.streaming_recognize(requests=request_generator_coro)

        # Iterate over responses using async for (standard way for Google Cloud Speech v2)
        async for response in response_stream:
            response_count += 1
            last_response_time = asyncio.get_event_loop().time()
            
            if not response.results:
                continue

            # Partition results by finality
            finals = []
            interims = []

            for r in response.results:
                native_is_final = getattr(r, "is_final", False)

                if USE_NATIVE_IS_FINAL:
                    is_final = bool(native_is_final)
                else:
                    stab = getattr(r,"stability",0) or 0
                    try:
                        eo = r.result_end_offset.total_seconds()
                    except Exception:
                        eo = 0
                    is_final = stab >= 0.85 and eo > 0

                if is_final:
                    finals.append(r)
                    logger.debug(f"[{client_id}] Result marked as FINAL")
                else:
                    interims.append(r)
                    logger.debug(f"[{client_id}] Result marked as INTERIM")

            # Handle finals first (if any)
            for r in finals:
                if not r.alternatives:
                    continue

                new_text = (r.alternatives[0].transcript or "").strip()
                if not new_text:
                    continue

                updated = merge_final(cumulative_final, new_text)
                if updated != cumulative_final:
                    logger.debug(f"[{client_id}] FINAL merge: OLD='{cumulative_final}' NEW='{updated}'")
                    cumulative_final = updated

                try:
                    await websocket.send(f"FINAL: {cumulative_final}")
                    logger.info(f"[{client_id}] FINAL sent (len={len(cumulative_final)})")
                except Exception as e:
                    logger.warning(f"[{client_id}] Failed to send FINAL: {e}")

                last_sent_interim = ""

            # Handle interims - send them even if we have finals, as they show current speech
            if interims:
                if COMPOSITE_INTERIMS:
                    composite = composite_interim_from_results(interims)
                    # Always send interim if it's different and not empty, to show real-time progress
                    if composite and composite != last_sent_interim and len(composite.strip()) > 0:
                        # Only skip if it's a clear regression (much shorter)
                        if last_sent_interim and len(composite) < len(last_sent_interim) - 10 and last_sent_interim.startswith(composite):
                            logger.debug(f"[{client_id}] Skipping regressive interim")
                        else:
                            try:
                                await websocket.send(f"INTERIM: {composite}")
                                last_sent_interim = composite
                                logger.info(f"[{client_id}] INTERIM sent (len={len(composite)}): {composite[:50]}...")
                            except Exception as e:
                                logger.warning(f"[{client_id}] Failed sending INTERIM: {e}")
                else:
                    # Legacy: send each (NOT recommended)
                    for r in interims:
                        if not r.alternatives: continue
                        t = (r.alternatives[0].transcript or "").strip()
                        if not t: continue
                        if t != last_sent_interim:
                            try:
                                await websocket.send(f"INTERIM: {t}")
                                last_sent_interim = t
                            except Exception as e:
                                logger.warning(f"[{client_id}] Failed sending INTERIM(single): {e}")



    except api_exceptions.InvalidArgument as e:

        logger.error(f"[{client_id}] InvalidArgument: {e}")

        try: 

            await websocket.send(f"ERROR: {e}")

        except Exception: pass

    except websockets.exceptions.ConnectionClosed:

        logger.info(f"[{client_id}] Connection closed mid-stream.")

    except asyncio.CancelledError:

        logger.info(f"[{client_id}] Stream task cancelled.")

    except asyncio.TimeoutError:

        # Already handled in inner loop, but catch here too for safety

        logger.warning(f"[{client_id}] Timeout in stream processor")

    except Exception:

        logger.error(f"[{client_id}] Streaming error", exc_info=True)

        try: 

            await websocket.send("ERROR: Streaming failure")

        except Exception: pass

    finally:

        if cumulative_final:

            logger.info(f"[{client_id}] Final transcript length={len(cumulative_final)}")

        try:

            await websocket.send("DONE")

        except Exception:

            pass

        logger.info(f"[{client_id}] Stream finished (responses={response_count})")



# ------------------- REQUEST GENERATOR -------------------

async def request_generator(websocket, client_id):

    try:

        cfg = await asyncio.wait_for(websocket.recv(), timeout=10)

        if not (isinstance(cfg,str) and cfg.startswith("CONFIG_ENCODING:")):

            await websocket.close(1002,"Bad config")

            return

        enc_name = cfg.split(":",1)[1].strip()

        enc_enum = ENCODING_MAP.get(enc_name)

        if not enc_enum:

            await websocket.close(1003,"Unsupported encoding")

            return



        decoding_args = dict(

            encoding=enc_enum,

            sample_rate_hertz=TARGET_SAMPLE_RATE,

            audio_channel_count=1

        )



        # Note: Speech contexts (phrases) can be added via recognizer configuration
        # For now, using the "long" model which is optimized for dictation
        rec_cfg = speech.RecognitionConfig(
            explicit_decoding_config=speech.ExplicitDecodingConfig(**decoding_args),
            model=MODEL
        )

        stream_cfg = speech.StreamingRecognitionConfig(

            config=rec_cfg,

            streaming_features=speech.StreamingRecognitionFeatures(

                interim_results=True

            )

        )



        yield speech.StreamingRecognizeRequest(

            recognizer=RECOGNIZER_FULL_NAME,

            streaming_config=stream_cfg

        )



        while True:

            try:

                # Add timeout to detect if client stops sending data

                msg = await asyncio.wait_for(websocket.recv(), timeout=300.0)  # 5 minute timeout

            except asyncio.TimeoutError:

                logger.warning(f"[{client_id}] No audio data received for 5 minutes - closing stream")

                break

            except websockets.exceptions.ConnectionClosed:

                logger.info(f"[{client_id}] WebSocket closed while waiting for audio")

                break

                

            if isinstance(msg, bytes):

                yield speech.StreamingRecognizeRequest(audio=msg)

            elif isinstance(msg, str):

                if msg == "STOP_RECORDING":

                    try:

                        await websocket.send("ACK: STOP_RECEIVED")

                    except Exception:

                        pass

                    if STOP_FINAL_GRACE_SECONDS > 0:

                        await asyncio.sleep(STOP_FINAL_GRACE_SECONDS)

                    break

            else:

                # Ignore unknown types

                pass

    except asyncio.TimeoutError:

        try: await websocket.close(1002,"Config Timeout")

        except Exception: pass

    except websockets.exceptions.ConnectionClosed:

        pass

    except Exception:

        logger.error("Error in request_generator", exc_info=True)

        try: await websocket.close(1011,"Generator Error")

        except Exception: pass



# ------------------- HANDLER / SERVER -------------------

async def handler(websocket):

    client_id = f"{websocket.remote_address}"

    logger.info(f"[{client_id}] Client connected.")

    try:

        await audio_stream_processor(websocket, request_generator(websocket, client_id))

    finally:

        try: 
            await websocket.close(1000,"Normal closure")
        except Exception: 
            pass

        logger.info(f"[{client_id}] Handler done.")



async def main():

    if not speech_client or not RECOGNIZER_FULL_NAME:

        logger.critical("Server cannot start; missing speech client or recognizer.")

        return

    logger.info("------------------------------------------------------")

    logger.info(" WebSocket Speech Server v23")

    logger.info(f" Host: {HOST}:{PORT}")

    logger.info(f" Recognizer: {RECOGNIZER_FULL_NAME}")

    logger.info(f" Model: {MODEL}")

    logger.info(f" Composite Interims: {COMPOSITE_INTERIMS}")

    logger.info("------------------------------------------------------")

    await websockets.serve(handler, HOST, PORT, ping_interval=20, ping_timeout=20)

    await asyncio.Future()



async def cleanup():

    try:

        if speech_client and getattr(speech_client,"_transport",None):

            close = getattr(speech_client._transport,"close",None)

            if close:

                if asyncio.iscoroutinefunction(close):

                    await close()

                else:

                    close()

    except Exception:

        logger.error("Cleanup error", exc_info=True)



if __name__ == "__main__":

    loop = asyncio.get_event_loop()

    main_task = loop.create_task(main())

    try:

        loop.run_forever()

    except KeyboardInterrupt:

        pass

    finally:

        main_task.cancel()

        try: loop.run_until_complete(main_task)

        except Exception: pass

        try: loop.run_until_complete(cleanup())

        except Exception: pass

        loop.close()

