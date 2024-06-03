//
//  FILE: SettingsPage.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: Settings Page
//
// !! BEING RUN ON: iPhone 15 Pro
//
// Toggle Feature: https://developer.apple.com/documentation/swiftui/toggle
// Navigation View Usage: https://www.hackingwithswift.com/articles/216/complete-guide-to-navigationview-in-swiftui
// Picker: https://designcode.io/swiftui-handbook-swiftui-picker
//

import SwiftUI

struct SettingsPage: View {
    @ObservedObject var vm: ViewModel
    @State private var selectedLanguage: LanguageType = .en // defaulting to English
    
    var body: some View {
        NavigationView {
            Color(BACKGROUND_COLOR)
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        Text(LocalizedStringKey(vm.languageType.localizedStrings["settings_title"]!))
                            .font(.custom("Silkscreen-Regular", size: CGFloat(vm.languageType == .es ? SPANISH_SETTINGS_TEXT_SIZE : HOME_TITLE_TEXT_SIZE)))
                            .padding()
                            .foregroundColor(.red)
                        HStack(spacing: CGFloat(LANGUAGE_VIEW_SPACING)) {
                            LanguageView(selectedLanguage: $selectedLanguage, vm: vm)
                        }
                        .padding(.bottom, CGFloat(LANGUAGE_VIEW_BOTTOM_PADDING))
                        
                        // toggle to choose between my two color insertion types
                        Toggle(isOn: Binding<Bool>(
                            get: { vm.moveBeadType == .dragAndDrop },
                            set: { isDragAndDrop in
                                vm.moveBeadType = isDragAndDrop ? .dragAndDrop : .tapToMove
                            }
                        )) {
                            // button for changing color inserting
                            makeInputTypeKey(state: vm.moveBeadType, vm: vm)
                                .padding(.top, CGFloat(INPUT_TYPE_TOP_PADDING))
                                .padding(.leading, CGFloat(INPUT_TYPE_LEADING_PADDING))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: TOGGLE_COLOR))
                        .frame(width: CGFloat(TOGGLE_FRAME_WIDTH), height: CGFloat(TOGGLE_FRAME_HEIGHT))
                        .padding(.bottom, CGFloat(TOGGLE_BOTTOM_PADDING))
                    }
                        .padding(.bottom, CGFloat(SETTINGS_BOTTOM_PADDING))
                )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CustomBackButton(vm: vm)
            }
        }
    }
}


// sturcture to hold the language option choice in the settings
struct LanguageView: View {
    let languageOptions: [LanguageType] = [.en, .es, .zh, .ko]
    // binding selected language so it can update on change
    @Binding var selectedLanguage: LanguageType
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        Picker(selection: $vm.languageType, label: Text("")) {
            ForEach(languageOptions, id: \.self) { language in
                Text(language.localizedStrings["title"] ?? "")
                    .tag(language)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding([.leading, .trailing])
    }
}


// function for choosing color insertion type
func makeInputTypeKey(state: MoveBeadType, vm: ViewModel) -> some View {
    return ZStack {
        RoundedRectangle(cornerRadius: CGFloat(SETTINGS_BUTTON_RADIUS))
            .fill(START_KEY_COLOR.gradient)
            .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
        RoundedRectangle(cornerRadius: CGFloat(SETTINGS_BUTTON_RADIUS))
            .stroke(lineWidth: CGFloat(START_KEY_STROKE_WIDTH))
            .foregroundColor(START_KEY_STROKE_COLOR)
            .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
        Text(LocalizedStringKey((state == .dragAndDrop ? vm.languageType.localizedStrings["drag_and_drop"] : vm.languageType.localizedStrings["tap_to_move"])!))
            .bold()
            .font(.custom("Silkscreen-Regular", size: CGFloat(vm.languageType == .es || vm.languageType == .en ? ENGLISH_SPANISH_INPUT_TEXT_SIZE : START_KEY_TEXT_SIZE)))
            .padding([.leading, .trailing])
    }
    .padding(CGFloat(START_KEY_PADDING))
}

