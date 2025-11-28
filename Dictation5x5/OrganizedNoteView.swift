import SwiftUI

struct OrganizedNoteView: View {
    let organizedNote: OrganizedNote
    @Environment(\.dismiss) var dismiss
    @State private var copiedSectionID: UUID?
    @State private var allCopied: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Organized Note")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.brandBlue)
                        
                        Text("Organized on \(formattedDate(organizedNote.organizedAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Organized sections
                    ForEach(organizedNote.sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(section.section.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.brandBlue)
                                
                                Spacer()
                                
                                Button(action: {
                                    UIPasteboard.general.string = section.content
                                    copiedSectionID = section.id
                                    allCopied = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        if copiedSectionID == section.id {
                                            copiedSectionID = nil
                                        }
                                    }
                                }) {
                                    Image(systemName: copiedSectionID == section.id ? "checkmark.circle.fill" : "doc.on.doc")
                                        .foregroundColor(copiedSectionID == section.id ? .brandOrange : .brandBlue)
                                }
                            }
                            
                            Text(section.content)
                                .font(.body)
                                .foregroundColor(.primary)
                                .textSelection(.enabled)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Copy all button
                    Button(action: {
                        let allText = organizedNote.sections.map { "\($0.section.rawValue)\n\($0.content)" }.joined(separator: "\n\n")
                        UIPasteboard.general.string = allText
                        allCopied = true
                        copiedSectionID = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            allCopied = false
                        }
                    }) {
                        HStack {
                            Image(systemName: allCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            Text("Copy All Sections")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Organized Note")
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

