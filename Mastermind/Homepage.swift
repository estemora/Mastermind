//
//  Homepage.swift
//  Mastermind
//
//  Created by Estefan Mora on 3/8/24.
//
// Custom Font For English and Spanish Text: https://sarunw.com/posts/swiftui-custom-font/#find-a-custom-font-to-use-in-your-app
// Timer used for controlling animation: https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
//

import SwiftUI

struct HomePage: View {
    @ObservedObject var vm: ViewModel
    
    // State variables for rainbow colors
    @State private var currentColorIndex = 0
    @State private var shouldNavigateToGameView = false // track whether to navigate to GameView
    
    var body: some View {
        NavigationView {
            Color(BACKGROUND_COLOR)
                .ignoresSafeArea()
                // having the whole VStack be in an overlay so background color covers absolutely everything
                .overlay(
                    VStack {
                        Text(LocalizedStringKey(vm.languageType.localizedStrings["title"]!))
                            .font(.custom("Silkscreen-Regular", size: CGFloat(HOME_TITLE_TEXT_SIZE)))
                            .foregroundColor(COLOR_OPTIONS[currentColorIndex])
                            .padding()
                            .onAppear {
                                animateRainbowColors()
                            }
                        // isActive label for NavLink will be deprecated soon but it seemed to work best with onTapGesture
                        NavigationLink(destination: GameView(vm: vm), isActive: $shouldNavigateToGameView) {
                            makeStartGameKey(vm: vm)
                                .onTapGesture {
                                    // Set tutorialMode to false when starting the game from the home start button
                                    vm.restartGame()
                                    vm.tutorialMode = false
                                    shouldNavigateToGameView = true 
                                }
                        }
                        .padding()
                        makeTutorialModeKey(vm: vm)
                            .padding(CGFloat(GENERAL_PADDING_SIZE))
                            .onTapGesture {
                                // restarting the game on tutorial button click just in case they had been mid-game and decided to go back and do the tutorial
                                vm.restartGame()
                                vm.currentStep = 0
                                vm.tutorialMode = true
                                shouldNavigateToGameView = true
                            }
                    } .padding(.bottom, CGFloat(HOME_BOTTOM_PADDING))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity) // filling all available space so background color gets everywhere
        }
        .onDisappear {
            // resetting tutorialMode when navigating away from the view
            if !shouldNavigateToGameView {
                vm.tutorialMode = false
            }
        }
    }



    // function to create the start game key
    func makeStartGameKey(vm: ViewModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: CGFloat(START_KEY_RADIUS))
                .fill(START_KEY_COLOR.gradient)
                .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
            RoundedRectangle(cornerRadius: CGFloat(START_KEY_RADIUS))
                .stroke(lineWidth: CGFloat(START_KEY_STROKE_WIDTH))
                .foregroundColor(START_KEY_STROKE_COLOR)
                .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
            Text(LocalizedStringKey(vm.languageType.localizedStrings["start_game"]!))
                .bold()
                .foregroundColor(Color.black)
                .font(.custom("Silkscreen-Regular", size: CGFloat(START_KEY_TEXT_SIZE)))
                .padding([.leading, .trailing])
        }
        .padding(CGFloat(START_KEY_PADDING))
    }
    
    // function to create the tutorial mode key
    func makeTutorialModeKey(vm: ViewModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: CGFloat(START_KEY_RADIUS))
                .fill(START_KEY_COLOR.gradient)
                .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
            RoundedRectangle(cornerRadius: CGFloat(START_KEY_RADIUS))
                .stroke(lineWidth: CGFloat(START_KEY_STROKE_WIDTH))
                .foregroundColor(START_KEY_STROKE_COLOR)
                .frame(width: CGFloat(START_KEY_FRAME_WIDTH), height: CGFloat(START_KEY_FRAME_HEIGHT))
            Text(LocalizedStringKey(vm.languageType.localizedStrings["tutorial_mode"]!))
                .bold()
                .font(.custom("Silkscreen-Regular", size: CGFloat(START_KEY_TEXT_SIZE)))
                .padding([.leading, .trailing])
        }
        .padding(CGFloat(START_KEY_PADDING))
    }
    
    // function to animate rainbow colors
    func animateRainbowColors() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            withAnimation(Animation.linear(duration: 1)) {
                currentColorIndex = (currentColorIndex + 1) % COLOR_OPTIONS.count
            }
        }
    }
}


