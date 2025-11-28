import Foundation

/// Medical specialty profiles that define how notes should be organized
enum MedicalSpecialty: String, CaseIterable, Identifiable, Codable {
    case cardiology = "Cardiology"
    case oncology = "Oncology"
    case orthopedics = "Orthopedics"
    case pediatrics = "Pediatrics"
    case internalMedicine = "Internal Medicine"
    case emergency = "Emergency Medicine"
    case surgery = "Surgery"
    case neurology = "Neurology"
    case psychiatry = "Psychiatry"
    case dermatology = "Dermatology"
    case general = "General Practice"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cardiology: return "heart.fill"
        case .oncology: return "cross.case.fill"
        case .orthopedics: return "figure.walk"
        case .pediatrics: return "figure.child"
        case .internalMedicine: return "stethoscope"
        case .emergency: return "cross.fill"
        case .surgery: return "scissors"
        case .neurology: return "brain.head.profile"
        case .psychiatry: return "brain"
        case .dermatology: return "hand.raised.fill"
        case .general: return "person.text.rectangle"
        case .custom: return "gearshape.fill"
        }
    }
    
    var description: String {
        switch self {
        case .cardiology:
            return "Organizes notes with: Chief Complaint, History of Present Illness, Physical Exam (Cardiovascular), Assessment & Plan"
        case .oncology:
            return "Organizes notes with: Chief Complaint, Cancer History, Current Treatment, Side Effects, Assessment & Plan"
        case .orthopedics:
            return "Organizes notes with: Chief Complaint, Injury Mechanism, Physical Exam (Musculoskeletal), Imaging, Assessment & Plan"
        case .pediatrics:
            return "Organizes notes with: Chief Complaint, Birth History, Developmental History, Physical Exam, Assessment & Plan"
        case .internalMedicine:
            return "Organizes notes with: Chief Complaint, History of Present Illness, Review of Systems, Physical Exam, Assessment & Plan"
        case .emergency:
            return "Organizes notes with: Chief Complaint, History, Physical Exam, Procedures, Disposition"
        case .surgery:
            return "Organizes notes with: Pre-op Assessment, Procedure Details, Post-op Findings, Complications, Plan"
        case .neurology:
            return "Organizes notes with: Chief Complaint, Neurological History, Mental Status, Neurological Exam, Assessment & Plan"
        case .psychiatry:
            return "Organizes notes with: Chief Complaint, Psychiatric History, Mental Status Exam, Assessment, Treatment Plan"
        case .dermatology:
            return "Organizes notes with: Chief Complaint, Skin History, Physical Exam (Dermatological), Assessment & Plan"
        case .general:
            return "Organizes notes with: Chief Complaint, History, Physical Exam, Assessment & Plan"
        case .custom:
            return "Create your own organization template"
        }
    }
    
    /// Default organization sections for each specialty
    var defaultSections: [NoteSection] {
        switch self {
        case .cardiology:
            return [
                .chiefComplaint,
                .historyOfPresentIllness,
                .physicalExam,
                .assessment,
                .plan
            ]
        case .oncology:
            return [
                .chiefComplaint,
                .cancerHistory,
                .currentTreatment,
                .sideEffects,
                .assessment,
                .plan
            ]
        case .orthopedics:
            return [
                .chiefComplaint,
                .injuryMechanism,
                .physicalExam,
                .imaging,
                .assessment,
                .plan
            ]
        case .pediatrics:
            return [
                .chiefComplaint,
                .birthHistory,
                .developmentalHistory,
                .physicalExam,
                .assessment,
                .plan
            ]
        case .internalMedicine:
            return [
                .chiefComplaint,
                .historyOfPresentIllness,
                .reviewOfSystems,
                .physicalExam,
                .assessment,
                .plan
            ]
        case .emergency:
            return [
                .chiefComplaint,
                .history,
                .physicalExam,
                .procedures,
                .disposition
            ]
        case .surgery:
            return [
                .preOpAssessment,
                .procedureDetails,
                .postOpFindings,
                .complications,
                .plan
            ]
        case .neurology:
            return [
                .chiefComplaint,
                .neurologicalHistory,
                .mentalStatus,
                .neurologicalExam,
                .assessment,
                .plan
            ]
        case .psychiatry:
            return [
                .chiefComplaint,
                .psychiatricHistory,
                .mentalStatusExam,
                .assessment,
                .treatmentPlan
            ]
        case .dermatology:
            return [
                .chiefComplaint,
                .skinHistory,
                .physicalExam,
                .assessment,
                .plan
            ]
        case .general:
            return [
                .chiefComplaint,
                .history,
                .physicalExam,
                .assessment,
                .plan
            ]
        case .custom:
            return []
        }
    }
}

/// Sections that can appear in organized medical notes
enum NoteSection: String, CaseIterable, Codable {
    case chiefComplaint = "Chief Complaint"
    case historyOfPresentIllness = "History of Present Illness"
    case history = "History"
    case reviewOfSystems = "Review of Systems"
    case physicalExam = "Physical Examination"
    case assessment = "Assessment"
    case plan = "Plan"
    case treatmentPlan = "Treatment Plan"
    case cancerHistory = "Cancer History"
    case currentTreatment = "Current Treatment"
    case sideEffects = "Side Effects"
    case injuryMechanism = "Injury Mechanism"
    case imaging = "Imaging"
    case birthHistory = "Birth History"
    case developmentalHistory = "Developmental History"
    case procedures = "Procedures"
    case disposition = "Disposition"
    case preOpAssessment = "Pre-operative Assessment"
    case procedureDetails = "Procedure Details"
    case postOpFindings = "Post-operative Findings"
    case complications = "Complications"
    case neurologicalHistory = "Neurological History"
    case mentalStatus = "Mental Status"
    case neurologicalExam = "Neurological Examination"
    case psychiatricHistory = "Psychiatric History"
    case mentalStatusExam = "Mental Status Examination"
    case skinHistory = "Skin History"
    
    var description: String {
        switch self {
        case .chiefComplaint:
            return "Primary reason for the visit"
        case .historyOfPresentIllness:
            return "Detailed history of the current problem"
        case .history:
            return "Relevant medical history"
        case .reviewOfSystems:
            return "Systematic review of body systems"
        case .physicalExam:
            return "Findings from physical examination"
        case .assessment:
            return "Clinical assessment and diagnosis"
        case .plan:
            return "Treatment and follow-up plan"
        case .treatmentPlan:
            return "Detailed treatment plan"
        case .cancerHistory:
            return "History of cancer diagnosis and treatment"
        case .currentTreatment:
            return "Current cancer treatment regimen"
        case .sideEffects:
            return "Side effects from treatment"
        case .injuryMechanism:
            return "How the injury occurred"
        case .imaging:
            return "Imaging study results"
        case .birthHistory:
            return "Birth and neonatal history"
        case .developmentalHistory:
            return "Developmental milestones"
        case .procedures:
            return "Procedures performed"
        case .disposition:
            return "Patient disposition"
        case .preOpAssessment:
            return "Pre-operative assessment"
        case .procedureDetails:
            return "Details of the surgical procedure"
        case .postOpFindings:
            return "Post-operative findings"
        case .complications:
            return "Complications encountered"
        case .neurologicalHistory:
            return "Neurological history"
        case .mentalStatus:
            return "Mental status examination"
        case .neurologicalExam:
            return "Neurological examination findings"
        case .psychiatricHistory:
            return "Psychiatric history"
        case .mentalStatusExam:
            return "Mental status examination"
        case .skinHistory:
            return "History of skin conditions"
        }
    }
}

/// Organization rules for a specialty
struct OrganizationRules: Codable {
    let specialty: MedicalSpecialty
    let sections: [NoteSection]
    let customInstructions: String?
    
    init(specialty: MedicalSpecialty, customInstructions: String? = nil) {
        self.specialty = specialty
        self.sections = specialty.defaultSections
        self.customInstructions = customInstructions
    }
}

/// Organized note structure
struct OrganizedNote: Codable {
    let originalTranscript: String
    let sections: [OrganizedSection]
    let organizedAt: Date
    
    struct OrganizedSection: Codable, Identifiable {
        let id: UUID
        let section: NoteSection
        let content: String
        
        init(section: NoteSection, content: String) {
            self.id = UUID()
            self.section = section
            self.content = content
        }
        
        enum CodingKeys: String, CodingKey {
            case id, section, content
        }
    }
}

