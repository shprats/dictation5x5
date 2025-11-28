import Foundation

/// Service for organizing medical notes using AI based on specialty rules
final class AINoteOrganizer {
    
    /// Organize a transcript according to the given rules
    /// Note: This is a placeholder implementation. In production, this would call an AI service
    /// like OpenAI, Anthropic, or a medical-specific AI API.
    static func organize(
        transcript: String,
        rules: OrganizationRules,
        completion: @escaping (Result<OrganizedNote, Error>) -> Void
    ) {
        // Simulate AI processing delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.5) {
            // PLACEHOLDER: This would normally call an AI API
            // For now, we'll do a simple rule-based organization as a demo
            
            let organized = organizeWithRules(transcript: transcript, rules: rules)
            completion(.success(organized))
        }
    }
    
    /// Placeholder implementation using rule-based organization
    /// In production, replace this with actual AI API calls
    private static func organizeWithRules(
        transcript: String,
        rules: OrganizationRules
    ) -> OrganizedNote {
        var sections: [OrganizedNote.OrganizedSection] = []
        
        // Simple keyword-based organization for demo
        // In production, this would use AI to intelligently parse and organize
        let lowerTranscript = transcript.lowercased()
        
        for section in rules.sections {
            var content = ""
            
            // Extract relevant content based on section type
            switch section {
            case .chiefComplaint:
                // Look for complaint-related phrases
                content = extractContent(transcript: transcript, keywords: [
                    "complaint", "here for", "presents with", "chief complaint", "reason for visit"
                ])
            case .historyOfPresentIllness, .history:
                content = extractContent(transcript: transcript, keywords: [
                    "history", "started", "began", "symptoms", "pain", "feeling"
                ])
            case .physicalExam:
                content = extractContent(transcript: transcript, keywords: [
                    "exam", "examination", "appears", "palpation", "auscultation", "inspection"
                ])
            case .assessment:
                content = extractContent(transcript: transcript, keywords: [
                    "assessment", "diagnosis", "impression", "findings suggest"
                ])
            case .plan, .treatmentPlan:
                content = extractContent(transcript: transcript, keywords: [
                    "plan", "treatment", "prescribe", "follow up", "recommend"
                ])
            default:
                // For other sections, try to find relevant content
                content = extractContent(transcript: transcript, keywords: [
                    section.rawValue.lowercased()
                ])
            }
            
            if !content.isEmpty {
                sections.append(OrganizedNote.OrganizedSection(
                    section: section,
                    content: content
                ))
            } else {
                // If no content found for a section, still include it with a placeholder
                // This ensures all expected sections are shown
                sections.append(OrganizedNote.OrganizedSection(
                    section: section,
                    content: "[No specific content found for this section]"
                ))
            }
        }
        
        // If no sections were found, put everything in the first section
        if sections.isEmpty && !rules.sections.isEmpty {
            sections.append(OrganizedNote.OrganizedSection(
                section: rules.sections[0],
                content: transcript
            ))
        }
        
        return OrganizedNote(
            originalTranscript: transcript,
            sections: sections,
            organizedAt: Date()
        )
    }
    
    /// Extract content from transcript based on keywords
    private static func extractContent(transcript: String, keywords: [String]) -> String {
        let sentences = transcript.components(separatedBy: CharacterSet(charactersIn: ".!?\n"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var relevantSentences: [String] = []
        let lowerTranscript = transcript.lowercased()
        
        for sentence in sentences {
            let lowerSentence = sentence.lowercased()
            for keyword in keywords {
                if lowerSentence.contains(keyword) {
                    relevantSentences.append(sentence)
                    break
                }
            }
        }
        
        return relevantSentences.joined(separator: ". ").trimmingCharacters(in: .whitespaces)
    }
    
    /// Example: Call to OpenAI API (commented out - implement when ready)
    /*
    private static func callOpenAI(
        transcript: String,
        rules: OrganizationRules
    ) async throws -> OrganizedNote {
        let apiKey = "YOUR_OPENAI_API_KEY"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = buildSystemPrompt(rules: rules)
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": transcript]
            ],
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        // Parse response and create OrganizedNote
        // ...
    }
    
    private static func buildSystemPrompt(rules: OrganizationRules) -> String {
        var prompt = "You are a medical note organization assistant. Organize the following transcript into the following sections:\n\n"
        for section in rules.sections {
            prompt += "- \(section.rawValue): \(section.description)\n"
        }
        if let instructions = rules.customInstructions {
            prompt += "\nAdditional instructions: \(instructions)\n"
        }
        prompt += "\nReturn the organized note in JSON format with sections and their content."
        return prompt
    }
    */
}

