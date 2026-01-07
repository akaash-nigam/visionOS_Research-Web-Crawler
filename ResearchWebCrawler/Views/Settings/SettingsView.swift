//
//  SettingsView.swift
//  Research Web Crawler
//
//  App settings view
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("defaultCitationStyle") private var defaultCitationStyle = "apa"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Citation") {
                    Picker("Default Style", selection: $defaultCitationStyle) {
                        Text("APA").tag("apa")
                        Text("MLA").tag("mla")
                        Text("Chicago").tag("chicago")
                    }
                }

                Section("Onboarding") {
                    Button("Replay Tutorial") {
                        hasCompletedOnboarding = false
                        dismiss()
                    }
                }

                Section("Data") {
                    Button("Clear All Data", role: .destructive) {
                        // Will implement in Epic 9
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0 (MVP)")
                    LabeledContent("Build", value: "001")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
