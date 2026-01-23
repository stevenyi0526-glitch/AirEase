//
//  SettingsView.swift
//  AirEase
//
//  Settings screen with language selection
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var persistence = PersistenceService.shared
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var showLanguagePicker = false
    @State private var showPersonaPicker = false
    
    var body: some View {
        NavigationStack {
            List {
                // Traveler Profile Section
                Section {
                    Button(action: { showPersonaPicker = true }) {
                        HStack {
                            Image(systemName: persistence.userPersona?.iconName ?? "person.circle")
                                .foregroundStyle(Color.aireasePurple)
                                .frame(width: 28)
                            
                            Text("Traveler Profile")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(persistence.userPersona?.shortName ?? "Not Set")
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Profile")
                } footer: {
                    Text("Your traveler profile affects how flight scores are calculated based on your preferences.")
                }
                
                // Language Section
                Section {
                    Button(action: { showLanguagePicker = true }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(Color.aireasePurple)
                                .frame(width: 28)
                            
                            Text(L10n.language)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("\(languageManager.currentLanguage.flag) \(languageManager.currentLanguage.displayName)")
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text(L10n.settings)
                }
                
                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.aireasePurple)
                            .frame(width: 28)
                        
                        Text(L10n.version)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "airplane")
                            .foregroundStyle(Color.aireasePurple)
                            .frame(width: 28)
                        
                        Text("AirEase")
                        
                        Spacer()
                        
                        Text(languageManager.isEnglish ? "Flight Experience Optimizer" : "Flight Experience Optimizer")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text(L10n.about)
                }
            }
            .navigationTitle(L10n.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.done) {
                        dismiss()
                    }
                    .foregroundStyle(Color.aireasePurple)
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView()
            }
            .sheet(isPresented: $showPersonaPicker) {
                PersonaPickerView()
            }
        }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        languageManager.setLanguage(language)
                        dismiss()
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            
                            Text(language.displayName)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if languageManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.aireasePurple)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L10n.selectLanguage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundStyle(Color.aireasePurple)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Persona Picker View
struct PersonaPickerView: View {
    @ObservedObject private var persistence = PersistenceService.shared
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(UserPersona.allCases, id: \.self) { persona in
                    Button(action: {
                        persistence.setPersona(persona)
                        dismiss()
                    }) {
                        HStack(spacing: 14) {
                            // Icon
                            Image(systemName: persona.iconName)
                                .font(.title2)
                                .foregroundColor(persona.color)
                                .frame(width: 36)
                            
                            // Name and description
                            VStack(alignment: .leading, spacing: 2) {
                                Text(persona.shortName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text(persona.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // Checkmark for selected
                            if persistence.userPersona == persona {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.aireasePurple)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                
                // Explanation section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How profiles affect scoring:")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ProfileWeightRow(persona: .business, label: "Business Pro", weights: "Comfort 35%, Safety 25%, Service 25%, Value 15%")
                        ProfileWeightRow(persona: .family, label: "Family Traveler", weights: "Safety 35%, Comfort 30%, Service 25%, Value 10%")
                        ProfileWeightRow(persona: .student, label: "Student Saver", weights: "Value 45%, Safety 20%, Comfort 20%, Service 15%")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Traveler Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundStyle(Color.aireasePurple)
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Profile Weight Row
struct ProfileWeightRow: View {
    let persona: UserPersona
    let label: String
    let weights: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: persona.iconName)
                .font(.caption)
                .foregroundColor(persona.color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(weights)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
