import SwiftUI

struct SpecialtyConfigView: View {
    @ObservedObject var profileConfig: UserProfileConfig
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medical Specialty")) {
                    Text("Select your medical specialty to customize how your notes are organized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(MedicalSpecialty.allCases) { specialty in
                        Button(action: {
                            profileConfig.selectedSpecialty = specialty
                        }) {
                            HStack {
                                Image(systemName: specialty.icon)
                                    .foregroundColor(.brandBlue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(specialty.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(specialty.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                if profileConfig.selectedSpecialty == specialty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.brandOrange)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if profileConfig.selectedSpecialty == .custom {
                    Section(header: Text("Custom Instructions")) {
                        TextEditor(text: $profileConfig.customInstructions)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        Text("Describe how you want your notes organized. For example: 'Organize by: Chief Complaint, History, Physical Exam, Assessment, Plan'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Organization Preview")) {
                    let rules = profileConfig.getOrganizationRules()
                    if !rules.sections.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your notes will be organized into these sections:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(rules.sections, id: \.rawValue) { section in
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.brandBlue)
                                        .font(.caption)
                                    Text(section.rawValue)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text("Select a specialty to see organization structure")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Note Organization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

