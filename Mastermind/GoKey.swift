//
//  FILE: GoKey.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: Go Key
//
// !! BEING RUN ON: iPhone 15 Pro
//
// https://www.hackingwithswift.com/books/ios-swiftui/customizing-animations-in-swiftui
//

import SwiftUI

// just two cases for the state of the go key
enum GoKeyState {
    case enabled
    case disabled
}

// GoKey: click to submit guess
struct GoKey: View {
    @ObservedObject var vm: ViewModel
    var stateProvider: () -> GoKeyState
    
    var body: some View {
        return makeGoKeyBody(stateProvider: stateProvider, vm: vm)
    }
}

// view for the GoKey, colors change depending on if the row is filled with colors or not
// instead of passing GoKeyState directly, having it be an escaping closure so I can recheck the state even after the key is clicked
func makeGoKeyBody(stateProvider: @escaping () -> GoKeyState, vm: ViewModel) -> some View {
    return ZStack {
        RoundedRectangle(cornerRadius: CGFloat(GO_KEY_RADIUS))
            .fill(GO_KEY_READY_COLOR.gradient)
            .frame(width: CGFloat(GO_KEY_FRAME_WIDTH), height: CGFloat(GO_KEY_FRAME_HEIGHT))
        RoundedRectangle(cornerRadius: CGFloat(GO_KEY_RADIUS))
            .stroke(lineWidth: CGFloat(GO_KEY_STROKE_WIDTH))
            .foregroundColor(stateProvider() == .enabled ? GO_KEY_ENABLED_COLOR : GO_KEY_DISABLED_COLOR)
            .frame(width: CGFloat(GO_KEY_FRAME_WIDTH), height: CGFloat(GO_KEY_FRAME_HEIGHT))
        Text(LocalizedStringKey(((stateProvider() == .enabled ? vm.languageType.localizedStrings["SUBMIT"] : vm.languageType.localizedStrings[""]) ?? "")))
            .bold()
            .font(.custom("Silkscreen-Regular", size: CGFloat(GO_KEY_TEXT_SIZE)))
            .padding([.leading, .trailing])
            .scaleEffect(stateProvider() == .enabled ? SUBMIT_TEXT_SCALED : SUBMIT_TEXT_UNSCALED)
            .animation(.easeInOut(duration: GENERAL_ANIMATION_DURATION), value: stateProvider())
        
    }.if(vm.tutorialMode) { view in
        view.saturation(vm.currentStep != 0 && vm.currentStep != 1 && vm.currentStep != 2 && vm.currentStep != 3 ? SATURATED : UNSATURATED)
    }
    .padding(CGFloat(GO_KEY_PADDING))
}


