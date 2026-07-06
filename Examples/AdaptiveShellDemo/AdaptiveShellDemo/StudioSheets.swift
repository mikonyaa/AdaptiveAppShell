import AdaptiveAppShell
import SwiftUI

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.adaptiveShellTheme) private var theme

    @State private var name = ""
    @State private var category = "Brand"
    @State private var dueDate = Date.now.addingTimeInterval(604_800)

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                }

                Section {
                    Text("This demo keeps creation local. Replace the action with your own repository or service.")
                        .font(.footnote)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .navigationTitle("New project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct ProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.adaptiveShellTheme) private var theme

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("AM")
                    .font(.title.weight(.bold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 88, height: 88)
                    .background(theme.accent.opacity(0.12), in: Circle())

                VStack(spacing: 4) {
                    Text("Alex Morgan")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(theme.primaryText)

                    Text("Design Director")
                        .foregroundStyle(theme.secondaryText)
                }

                AdaptiveShellCard(padding: 0) {
                    VStack(spacing: 0) {
                        profileRow(
                            title: "alex@example.com",
                            systemImage: "envelope"
                        )

                        Divider()
                            .overlay(theme.separator)
                            .padding(.leading, 54)

                        profileRow(
                            title: "Studio workspace",
                            systemImage: "building.2"
                        )
                    }
                }

                Spacer()
            }
            .padding(24)
            .background(theme.canvas)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func profileRow(
        title: String,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.body)
            .foregroundStyle(theme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
    }
}
