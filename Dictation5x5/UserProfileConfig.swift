import Foundation
import Combine

/// Manages user profile configuration including medical specialty
final class UserProfileConfig: ObservableObject {
    static let shared = UserProfileConfig()
    
    @Published var selectedSpecialty: MedicalSpecialty {
        didSet {
            saveSpecialty()
        }
    }
    
    @Published var customInstructions: String {
        didSet {
            saveCustomInstructions()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let specialtyKey = "userProfile.specialty"
    private let customInstructionsKey = "userProfile.customInstructions"
    
    private init() {
        // Load saved specialty or default to General
        if let specialtyRaw = userDefaults.string(forKey: specialtyKey),
           let specialty = MedicalSpecialty(rawValue: specialtyRaw) {
            self.selectedSpecialty = specialty
        } else {
            self.selectedSpecialty = .general
        }
        
        // Load custom instructions
        self.customInstructions = userDefaults.string(forKey: customInstructionsKey) ?? ""
    }
    
    private func saveSpecialty() {
        userDefaults.set(selectedSpecialty.rawValue, forKey: specialtyKey)
    }
    
    private func saveCustomInstructions() {
        userDefaults.set(customInstructions, forKey: customInstructionsKey)
    }
    
    func getOrganizationRules() -> OrganizationRules {
        return OrganizationRules(
            specialty: selectedSpecialty,
            customInstructions: customInstructions.isEmpty ? nil : customInstructions
        )
    }
}

