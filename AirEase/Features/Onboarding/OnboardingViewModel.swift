//
//  OnboardingViewModel.swift
//  AirEase
//
//  Onboarding视图模型
//

import Foundation
import SwiftUI

@Observable
final class OnboardingViewModel {
    var selectedPersona: UserPersona?
    var isCompleted: Bool = false
    
    private let persistence = PersistenceService.shared
    
    var canProceed: Bool {
        selectedPersona != nil
    }
    
    func selectPersona(_ persona: UserPersona) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedPersona == persona {
                selectedPersona = nil
            } else {
                selectedPersona = persona
            }
        }
    }
    
    func confirmSelection() {
        guard let persona = selectedPersona else { return }
        persistence.setPersona(persona)
        isCompleted = true
    }
}
