//
// FILE: Tutorial.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: Tutorial
//
// !! BEING RUN ON: iPhone 15 Pro
//
// Multiline Text Alignment: https://www.hackingwithswift.com/quick-start/swiftui/how-to-adjust-text-alignment-using-multilinetextalignment
//

import SwiftUI

struct TutorialTooltip: View {
    let step: Int
    
    // on close used for making overlay dissappear
    let onClose: () -> Void
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text(tooltipTextForStep(vm.currentStep))
                .multilineTextAlignment(.center)
            
            // going through tutorial steps by clicking next will not work on steps where certain other conditions must be met
            if vm.currentStep != 3 && vm.currentStep != 4 && vm.currentStep != 5 {
                Button(LocalizedStringKey(vm.languageType.localizedStrings["next"]!)) {
                    if vm.currentStep >= 7 {
                        // reset everything when final step of tutorial is reached
                        vm.currentStep = 0
                        vm.tutorialMode = false
                        vm.restartGame()
                    } else {
                        vm.currentStep += 1
                    }
                }
            }
        }
        .padding()
        .background(TUTORIAL_BACKGROUND_COLOR)
        .cornerRadius(CGFloat(TUTORIAL_CORNER_RADIUS))
        .shadow(radius: CGFloat(TUTORIAL_SHADOW_RADIUS))
        .padding(CGFloat(GENERAL_TUTORIAL_PADDING))

        // settings padding to be different when the game over screen is visible so the tutorial overlay doesn't cover it
        .padding(.top, vm.currentStep != 6 && vm.currentStep != 7 ? CGFloat(TOP_TUTORIAL_PADDING_ENDGAME) : CGFloat(TOP_TUTORIAL_PADDING_NORMAL))
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    // function to provide tooltip text for each step
    private func tooltipTextForStep(_ step: Int) -> LocalizedStringKey {

        // each case in the switch represents a singular step that the tutorial will iterate through
        switch step {
        case 0:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_zero"]!)
        case 1:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_one"]!)
        case 2:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_two"]!)
        case 3:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_three"]!)
        case 4:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_four"]!)
        case 5:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_five"]!)
        case 6:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_six"]!)
        default:
            return LocalizedStringKey(vm.languageType.localizedStrings["step_seven"]!)
        }
    }
}

