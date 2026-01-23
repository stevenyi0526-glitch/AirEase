//
//  OnboardingView.swift
//  AirEase
//
//  User persona selection screen
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.aireasePurple)
                
                Text(L10n.onboardingTitle)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(L10n.onboardingSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 48)
            
            // Persona Cards
            VStack(spacing: 16) {
                ForEach(UserPersona.allCases, id: \.self) { persona in
                    PersonaCard(
                        persona: persona,
                        isSelected: viewModel.selectedPersona == persona,
                        action: { viewModel.selectPersona(persona) }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Confirm Button
            Button(action: {
                viewModel.confirmSelection()
                isOnboardingComplete = true
            }) {
                Text(L10n.getStarted)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.canProceed ? Color.aireasePurple : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canProceed)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Persona Card
struct PersonaCard: View {
    let persona: UserPersona
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: persona.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : persona.color)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? persona.color : persona.color.opacity(0.1))
                    .cornerRadius(12)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.personaName(persona))
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(L10n.personaDescription(persona))
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(isSelected ? persona.color : Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? persona.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
