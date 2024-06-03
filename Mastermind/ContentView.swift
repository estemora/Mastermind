//
//  FILE: ContentView.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: View
//
// !! BEING RUN ON: iPhone 15 Pro
//
//  Created by Estefan Mora on 1/23/24.
//
// Toolbar Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-toolbar-and-add-buttons-to-it
// NavLink Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-programmatic-navigation-in-swiftui
// Drag and Drop Initial Reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-support-drag-and-drop-in-swiftui
// Desaturation for Tutorial: https://www.hackingwithswift.com/quick-start/swiftui/how-to-adjust-views-by-tinting-and-desaturating-and-more
// Effects Library for Win/Lose Confetti: https://getstream.github.io/effects-library/tutorials/effectslibrary/getting-started/
// Conditional View Modifier Extension https://www.avanderlee.com/swiftui/conditional-view-modifier/
// Custom Back in Navigation View: https://sarunw.com/posts/custom-back-button-action-in-swiftui/

import SwiftUI
import UniformTypeIdentifiers
import EffectsLibrary

// ContentView initially just returns a HomePage, other views are accessed through navigation view
struct ContentView: View {
    
    // creates an observable instance of the ViewModel
    @ObservedObject var vm = ViewModel()
    
    var body: some View {
        NavigationView {
            HomePage(vm: vm)
                // toolbar for calling different views with navigation links
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsPage(vm: vm)) {
                            Text("⚙️")
                                .font(.system(size: CGFloat(SETTINGS_BUTTON_SIZE)))
                        }
                    }
                }
        }
    }
}

// Game View which used to be the Content View, seperated for NavLink usage
struct GameView: View {
    @ObservedObject var vm: ViewModel
    @State private var currentStep = 0
    @State private var isTutorialTooltipVisible = false
    
    var body: some View {
        NavigationView {
            Color(BACKGROUND_COLOR)
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        // title at top of game view changes whether it is tutorial mode or not
                        if !vm.tutorialMode {
                            Text(LocalizedStringKey(vm.languageType.localizedStrings["title"]!))
                                .font(.custom("Silkscreen-Regular", size: CGFloat(TITLE_TEXT_SIZE)))
                        }
                        else {
                            Text(LocalizedStringKey(vm.languageType.localizedStrings["tutorial_mode"]!))
                                .font(.custom("Silkscreen-Regular", size: CGFloat(TITLE_TEXT_SIZE)))
                        }
                        
                        // rows of color guesses
                        ForEach(vm.userGuesses) {guessNumber in
                            HStack{
                                ColorGuessRow(row: guessNumber.id, colorOptions: vm.colorOptions, vmLocal: vm)
                                PegGuessRow(row: guessNumber.id, vmLocal: vm)
                            }
                        }
                        
                        
                        // text to communicate to user
                        switch vm.gameState {
                        case .playing:
                            Text(LocalizedStringKey(vm.languageType.localizedStrings["choose_color"]!))
                                .font(.custom("Silkscreen-Regular", size: CGFloat(INFO_TEXT_SIZE)))
                        case .lost:
                            Text(LocalizedStringKey(vm.languageType.localizedStrings["game_over"]!))
                                .font(.custom("Silkscreen-Regular", size: CGFloat(INFO_TEXT_SIZE)))
                        case .won:
                            Text(LocalizedStringKey(vm.languageType.localizedStrings["winner"]!))
                                .bold()
                                .font(.custom("Silkscreen-Regular", size: CGFloat(INFO_TEXT_SIZE)))
                        }
                        
                        
                        HStack {
                            ForEach(vm.colorOptions) { thisColor in
                                // color options only work when not in tutorial mode or when in tutorial mode but not on the respective steps
                                if !vm.tutorialMode || ( vm.currentStep != 0 && vm.currentStep != 1 && vm.currentStep != 7) {
                                    switch vm.moveBeadType {
                                    case .dragAndDrop:
                                        ColorOptionView(colorId: thisColor.id, isSelected: thisColor.isSelected, vmLocal: vm, colorOption: thisColor)
                                            .contentShape(.dragPreview, .circle)
                                            .draggable(thisColor)
                                            .dropDestination(for: Bead.self) { droppedColor, location in
                                                vm.removeColor(rowNumber: vm.currentRowNumber, column: droppedColor[0].column)
                                                return true}
                                    case .tapToMove:
                                        ColorOptionView(colorId: thisColor.id, isSelected: thisColor.isSelected, vmLocal: vm, colorOption: thisColor)
                                            .onTapGesture {
                                                vm.chooseColor(colorNumber: thisColor.id)
                                            }
                                    }
                                } else {
                                    ColorOptionView(colorId: thisColor.id, isSelected: thisColor.isSelected, vmLocal: vm, colorOption: thisColor)
                                }
                            }
                        }
                        
                        // go/submit guess key when a row is completely filled with colored beads, putting conditions inside a let variable that will be passed into the GoKey function
                        let currentStateProvider = { vm.isRowComplete(thisRow: vm.currentRowNumber) && vm.currentRowNumber < MAX_GUESSES && vm.gameState == .playing ? GoKeyState.enabled : GoKeyState.disabled }
                        
                        makeGoKeyBody(stateProvider: currentStateProvider, vm: vm)
                            .onTapGesture {
                                
                                // geting the current state with the closure
                                let currentState = currentStateProvider()
                                
                                // check if tutorial mode is false before incrementing as normal
                                if !vm.tutorialMode && vm.currentRowNumber < MAX_GUESSES && vm.gameState == .playing {
                                    vm.incrementRow(rowNumber: vm.currentRowNumber)
                                }
                                
                                // if tutorial mode true, check these ifs before incrementing
                                else {
                                    if vm.currentStep == 5 && currentState == .enabled {
                                        // simulating a scripted win for the user on the 5th step of the tutorial
                                        vm.tutorialModeCodeGen()
                                        vm.feedbackBeads(row: 1)
                                        vm.currentStep = 6
                                    }
                                    if vm.currentStep == 4 && currentState == .enabled {
                                        vm.currentStep = 5
                                    }
                                    vm.incrementRow(rowNumber: vm.currentRowNumber)
                                }
                            }
                    }
                )}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(gameOverlay)
        .overlay(tutorialOverlay)
        
        // game view toolbar, feature animation on tutorial settings step
        .navigationBarBackButtonHidden(true)
        .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ZStack{
                        CustomBackButton(vm: vm)
                    }
                }
            ToolbarItem(placement: .navigationBarTrailing) {
                ZStack {
                    NavigationLink(destination: SettingsPage(vm: vm)) {
                        Text("⚙️")
                            .font(.system(size: CGFloat(SETTINGS_BUTTON_SIZE)))
                            .offset(y: vm.currentStep == 1 ? CGFloat(SPRING_ANIMATION_HEIGHT) : CGFloat(SPRING_DEFAULT_HEIGHT))
                            .animation(Animation.spring(duration: GENERAL_ANIMATION_DURATION).repeatForever(), value: vm.currentStep)
                    }
                }
            }
        }
    }
    // viewbuilder for tutorial overlay for tutorial mode
    @ViewBuilder var tutorialOverlay: some View {
        if vm.tutorialMode {
            TutorialTooltip(step: 0, onClose: { isTutorialTooltipVisible = false }, vm: vm)
            // on each step, have it transition not as jarringly via opacity
                .transition(.opacity)
        }
    }
    // view builder for overlay that tells the user the secret code when they lose
    @ViewBuilder var gameOverlay: some View {
        
        // game over screen when a user loses
        if vm.gameState == .lost {
            ZStack{
                // loss confetti animation
                ConfettiView(
                    config: ConfettiConfig(
                        content: [
                            .emoji("💧", CGFloat(LOSE_CONFETTI_SIZE)),
                            .emoji("💧", CGFloat(LOSE_CONFETTI_SIZE)),
                            .emoji("💧", CGFloat(LOSE_CONFETTI_SIZE)),
                            .emoji("💧", CGFloat(LOSE_CONFETTI_SIZE))                        
                        ],
                        intensity: .high,
                        lifetime: .long,
                        initialVelocity: .fast,
                        fadeOut: .fast,
                        spreadRadius: .medium
                    )
                )
                RoundedRectangle(cornerRadius: CGFloat(GO_KEY_RADIUS))
                    .stroke(lineWidth: CGFloat(GAME_OVER_SCREEN_STROKE_WIDTH))
                    .background(CURRENT_ROW_STROKE_COLOR)
                    .padding(CGFloat(GAME_OVER_SCREEN_PADDING_SIZE))
                    .frame(width: CGFloat(GAME_OVER_SCREEN_WIDTH), height: CGFloat(GAME_OVER_SCREEN_HEIGHT))
                VStack{
                    Text(LocalizedStringKey(vm.languageType.localizedStrings["loss_text"]!))
                        .bold()
                        .foregroundColor(.black)
                        .font(.custom("Silkscreen-Regular", size: CGFloat(vm.languageType == .es ? SPANISH_LOSE_CODE_TEXT_SIZE : LOSE_CODE_TEXT_SIZE)))
                        .background(GAME_OVER_BACKGROUND_COLOR)
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                        .padding([.leading, .trailing])
                    
                    // secret code display on the game over screen
                    SecretCodeView(secretCode: vm.secretCode)
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                    Text(LocalizedStringKey(vm.languageType.localizedStrings["loss_restart_text"]!))
                        .bold()
                        .foregroundColor(.black)
                        .font(.custom("Silkscreen-Regular", size: CGFloat(PLAY_AGAIN_TEXT_SIZE)))
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                        .padding([.leading, .trailing])
                        .background(CURRENT_ROW_STROKE_COLOR)
                        .cornerRadius(CGFloat(GAME_OVER_SCREEN_CORNER_RADIUS))
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(GAME_OVER_SECRET_CODE_CORNER_RADIUS))
                                .stroke(Color.black, lineWidth: CGFloat(GAME_OVER_SECRET_CODE_LINE_WIDTH))
                        )
                        .onTapGesture {
                            // disabling restarting via end game button for tutorial mode
                            if !vm.tutorialMode {
                                vm.restartGame()
                            }
                        }
                }
            }
        }
        
        // game over screen when a user wins or at the second to last step of tutorial mode
        if (vm.tutorialMode && vm.currentStep == 6) || vm.gameState == .won {
            ZStack{
                // win confetti animation
                ConfettiView(
                    config: ConfettiConfig(
                        content: [
                            .emoji("🎉", CGFloat(WIN_CONFETTI_SIZE)),
                            .emoji("🎊", CGFloat(WIN_CONFETTI_SIZE)),
                            .emoji("🥳", CGFloat(WIN_CONFETTI_SIZE)),
                        ],
                        intensity: .high,
                        lifetime: .long,
                        initialVelocity: .fast,
                        fadeOut: .slow,
                        spreadRadius: .medium
                    )
                )
                RoundedRectangle(cornerRadius: CGFloat(GO_KEY_RADIUS))
                    .stroke(lineWidth: CGFloat(GAME_OVER_SCREEN_STROKE_WIDTH))
                    .background(GAME_OVER_BACKGROUND_COLOR)
                    .padding(CGFloat(GAME_OVER_SCREEN_PADDING_SIZE))
                    .frame(width: CGFloat(GAME_OVER_SCREEN_WIDTH), height: CGFloat(GAME_OVER_SCREEN_HEIGHT))
                VStack {
                    Text(LocalizedStringKey(vm.languageType.localizedStrings["win_text"]!))
                        .bold()
                        .foregroundColor(.black)
                        .font(.custom("Silkscreen-Regular", size: CGFloat(WIN_CODE_TEXT_SIZE)))
                        .background(CURRENT_ROW_STROKE_COLOR)
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                        .padding([.leading, .trailing])
                    
                    // secret code display for the game over screen
                    SecretCodeView(secretCode: vm.secretCode)
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                    Text(LocalizedStringKey(vm.languageType.localizedStrings["win_restart_text"]!))
                        .bold()
                        .foregroundColor(.black)
                        .font(.custom("Silkscreen-Regular", size: CGFloat(PLAY_AGAIN_TEXT_SIZE)))
                        .padding(CGFloat(GENERAL_PADDING_SIZE))
                        .padding([.leading, .trailing])
                        .background(CURRENT_ROW_STROKE_COLOR)
                        .cornerRadius(CGFloat(GAME_OVER_SCREEN_CORNER_RADIUS))
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(GAME_OVER_SECRET_CODE_CORNER_RADIUS))
                                .stroke(Color.black, lineWidth: CGFloat(GAME_OVER_SECRET_CODE_LINE_WIDTH))
                        )
                        .onTapGesture {
                            if !vm.tutorialMode {
                                vm.restartGame()
                            }
                        }
                }
            }
        }
    }
}


// view of singular color key
struct ColorOptionView: View {
    var colorId: Int
    var isSelected: Bool
    @ObservedObject var vmLocal: ViewModel
    var colorOption: ColorOption
    
    var body: some View {
        ZStack {
            // specifications for each represented color options available
            Circle()
                .fill(COLOR_OPTIONS[colorId])
                .frame(width: CGFloat(COLOR_OPTIONS_FRAME_WIDTH), height: CGFloat(COLOR_OPTIONS_FRAME_HEIGHT))
            // line width is different depending on selection status
            Circle()
                .stroke(lineWidth: CGFloat(isSelected ? SELECTED_COLOR_STROKE_WIDTH : UNSELECTED_COLOR_STROKE_WIDTH))
        }
        // conditional if that sets saturation only in tutorialMode
        .if(vmLocal.tutorialMode) { view in
            view.saturation((vmLocal.currentStep != 0 && vmLocal.currentStep != 1) ? 1 : 0)
        }
    }
}



// view for single color of a user's guess
struct ColorGuessView: View {
    
    var colorId: Int?
    var highlighted: Bool = false
    @ObservedObject var vmLocal: ViewModel
    
    var body: some View {
        if let colorNumber = colorId {
            return AnyView(
                ZStack {
                    Circle()
                        .fill((COLOR_OPTIONS[colorNumber]))
                        .frame(width: CGFloat(COLOR_GUESS_FRAME_WIDTH), height: CGFloat(COLOR_GUESS_FRAME_HEIGHT))
                    
                    // stroke for clicked or unclicked bead
                    Circle()
                        .stroke(lineWidth: highlighted ? CGFloat(CLICKED_BEAD_STROKE_WIDTH + 2) : CGFloat(UNCLICKED_BEAD_STROKE_WIDTH))
                    
                    // stroke for current or not current row
                    Circle()
                        .stroke(lineWidth: CGFloat(UNCLICKED_BEAD_STROKE_WIDTH))
                        .foregroundColor(highlighted ? CURRENT_ROW_STROKE_COLOR : NOT_CURRENT_ROW_STROKE_COLOR)
                }
                    .if(vmLocal.tutorialMode) { view in
                        view.saturation(vmLocal.currentStep != 0 && vmLocal.currentStep != 1 && vmLocal.currentStep != 2 ? 1 : 0)
                    }
            )
        }
        
        else {
            return AnyView(
                ZStack {
                    Circle()
                        .fill(UNFILLED_COLOR)
                        .frame(width: CGFloat(COLOR_GUESS_FRAME_WIDTH), height: CGFloat(COLOR_GUESS_FRAME_HEIGHT))
                    
                    // stroke for clicked or unclicked bead
                    Circle()
                        .stroke(lineWidth: highlighted ? CGFloat(CLICKED_BEAD_STROKE_WIDTH) : CGFloat(UNCLICKED_BEAD_STROKE_WIDTH))
                    
                    // stroke for current or not current row
                    Circle()
                        .stroke(lineWidth: CGFloat(UNCLICKED_BEAD_STROKE_WIDTH))
                        .foregroundColor(highlighted ? CURRENT_ROW_STROKE_COLOR : NOT_CURRENT_ROW_STROKE_COLOR)
                }
                    .if(vmLocal.tutorialMode) { view in
                        view.saturation(vmLocal.currentStep != 0 && vmLocal.currentStep != 1 && vmLocal.currentStep != 2 ? 1 : 0)
                    }
            )
        }
    }
}


// view for complete row guess of all colors
struct ColorGuessRow: View {
    var row: Int
    var colorOptions: [ColorOption]
    @ObservedObject var vmLocal: ViewModel
    
    var body: some View {
        let guessRow = vmLocal.recalcedRow(rowNumber: row)
        HStack(spacing: CGFloat(COLOR_GUESS_ROW_STACK_SPACING)) {
            ForEach(0..<COLOR_GUESS_COUNT, id: \.self) { column in
                switch vmLocal.moveBeadType {
                    
                // drag and drop color insertion type case, hell on Earth
                case .dragAndDrop:
                    ColorGuessView(colorId: vmLocal.userGuesses[guessRow].guessItem[column],
                                   highlighted: guessRow == vmLocal.currentRowNumber,
                                   vmLocal: vmLocal)
                    .contentShape(.dragPreview, .circle) // used to make the dragged item appear as a circle
                    .frame(width: CGFloat(COLOR_GUESS_ROW_ITEM_WIDTH), height: CGFloat(COLOR_GUESS_ROW_HEIGHT))
                    // if modifier that makes a color draggable only if it is not nil and it is the current guess row
                    .if(vmLocal.currentRowNumber == guessRow && vmLocal.userGuesses[guessRow].guessItem[column] != nil) { view in
                        view.draggable(vmLocal.singleGuess[column])
                    }
                    
                    // my living nightmare, controls what views can receive dragged items
                    .dropDestination(for: DropItem.self) { droppedColor, location in
                        switch droppedColor[0] {
                        case .bead(let guess):
                            // LONG if condition that basically restricts tutorial users to only allow insertion on certain stpes, or just the typical when currentRow for non-tutorial mode
                            if (vmLocal.currentStep != 0 && vmLocal.currentStep != 1 && vmLocal.currentStep != 2 && vmLocal.currentStep != 7 && guessRow == vmLocal.currentRowNumber) || (!vmLocal.tutorialMode && guessRow == vmLocal.currentRowNumber)  {
                                print("Dropped guess: \(guess.color)")
                                vmLocal.removeColor(rowNumber: guessRow, column: guess.column)
                                vmLocal.setGuessColor(selectedRow: guessRow, selectedCol: column, currentColor: guess.color)
                            }
                        case .colorOption(let colorOption):
                            if (vmLocal.currentStep != 0 && vmLocal.currentStep != 1 && vmLocal.currentStep != 2 && vmLocal.currentStep != 7 && guessRow == vmLocal.currentRowNumber) || (!vmLocal.tutorialMode && guessRow == vmLocal.currentRowNumber)  {
                                print("Dropped color option: \(colorOption)")
                                vmLocal.setGuessColor(selectedRow: guessRow, selectedCol: column, currentColor: colorOption.id)
                            }
                        }
                        return true
                    }
                    
                // the on tap gesture color insertion case, much less of a hassle than drag nd drop
                case .tapToMove:
                    ColorGuessView(colorId: vmLocal.userGuesses[guessRow].guessItem[column],
                                   highlighted: guessRow == vmLocal.currentRowNumber,
                                   vmLocal: vmLocal)
                    .frame(width: CGFloat(COLOR_GUESS_ROW_ITEM_WIDTH), height: CGFloat(COLOR_GUESS_ROW_HEIGHT))
                    .onTapGesture {
                        if (vmLocal.currentColor != nil && vmLocal.currentStep != 0 && vmLocal.currentStep != 1 && vmLocal.currentStep != 2 && vmLocal.currentStep != 7 && guessRow == vmLocal.currentRowNumber)  || (vmLocal.currentColor != nil && !vmLocal.tutorialMode && guessRow == vmLocal.currentRowNumber)   {
                            vmLocal.setGuessColor(selectedRow: guessRow, selectedCol: column, currentColor: vmLocal.currentColor!)
                        }
                    }
                }
            }
        }
        // setting the width of the row based on item width and the number of items
        .frame(width: CGFloat(COLOR_GUESS_COUNT) * CGFloat(COLOR_GUESS_ROW_ITEM_WIDTH), height: CGFloat(COLOR_GUESS_ROW_HEIGHT))
        .padding(CGFloat(GENERAL_PADDING_SIZE))
    }
}

// https://www.avanderlee.com/swiftui/conditional-view-modifier/
// my lord and savior. saved me so much lines of code letting me add stuff like condtional .saturation modifiers on a view and to get my drag and drop functional!
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

// view for the whole peg square that holds the feedback pegs
struct PegGuessRow: View {
    var row: Int
    @ObservedObject var vmLocal: ViewModel
    
    var body: some View {
        ZStack {
            // recalc of row in order to be reversed with 0 at the bottom
            let row = vmLocal.recalcedRow(rowNumber: row)
            
            // view for the container that holds the pegs
            RoundedRectangle(cornerRadius: CGFloat(GO_KEY_RADIUS))
                .stroke(lineWidth: CGFloat(PEG_STROKE_WIDTH))
                .fill(.black)
                .frame(width: CGFloat(PEG_FRAME_WIDTH), height: CGFloat(PEG_FRAME_HEIGHT))
                .background(PEG_FRAME_BACKGROUND_COLOR)
            
            // HStack with two different VStacks so it is square rather than a long rectangle
            HStack(spacing: CGFloat(PEG_STACK_SPACING)) {
                VStack(spacing: CGFloat(PEG_STACK_SPACING)) {
                    ForEach(0..<PEGS_PER_ROW, id: \.self) { pegIndex in
                        PegGuessView(peg: pegIndex, rowNumber: row, vmLocal: vmLocal)
                    }
                }
                VStack(spacing: CGFloat(PEG_STACK_SPACING)) {
                    ForEach(0..<PEGS_PER_ROW, id: \.self) { pegIndex in
                        PegGuessView(peg: pegIndex + 2, rowNumber: row, vmLocal: vmLocal)
                    }
                }
            }
        }
        .if(vmLocal.tutorialMode) { view in
            view.saturation(vmLocal.currentStep == 5 || vmLocal.currentStep == 6 || vmLocal.currentStep == 7 ? 1 : 0)
        }
    }
}


// view for a singular peg
struct PegGuessView: View {
    var peg: Int
    var rowNumber: Int
    @ObservedObject var vmLocal: ViewModel

    var body: some View {
        // default counts
        let redsCount = vmLocal.userGuesses[rowNumber].reds
        let whitesCount = vmLocal.userGuesses[rowNumber].whites
        
        // determining color of the peg based on reds and whites counts
        var fillColor: Color = NO_PEG_COLOR
        var strokeColor: Color = NO_PEG_COLOR
        
        if peg < redsCount {
            fillColor = RIGHT_PEG_COLOR
            strokeColor = PEG_STROKE_COLOR
        } else if peg < redsCount + whitesCount {
            fillColor = RIGHT_WRONG_PLACE_PEG_COLOR
            strokeColor = PEG_STROKE_COLOR
        }
        
        return Circle()
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: CGFloat(PEG_STROKE_PADDING))
            .frame(width: CGFloat(PEG_WIDTH), height: CGFloat(PEG_HEIGHT))
            .padding([.top, .bottom], CGFloat(PEG_PADDING_SIZE))
    }
}


// structure for the secret code that is displayed at the end of the game
struct SecretCodeView: View {
    var secretCode: [Int]
    
    var body: some View {
        HStack {
            ForEach(0..<secretCode.count, id: \.self) { index in
                let colorId = secretCode[index]
                ZStack {
                    Circle()
                        .fill(COLOR_OPTIONS[colorId])
                        .frame(width: CGFloat(SECRET_CODE_WIDTH_HEIGHT), height: CGFloat(SECRET_CODE_WIDTH_HEIGHT))
                        .padding(CGFloat(SECRET_CODE_VIEW_PADDING))
                    Circle()
                        .stroke(lineWidth: CGFloat(SECRET_CODE_STROKE_WIDTH))
                        .fill(.black)
                        .frame(width: CGFloat(SECRET_CODE_WIDTH_HEIGHT), height: CGFloat(SECRET_CODE_WIDTH_HEIGHT))
                        .padding(CGFloat(SECRET_CODE_VIEW_PADDING))
                }
            }
        }
    }
}

// making a custom back button so the language can change instead of being the English "Back" for the already implemented back in the Nav View
struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            // using Swift's SF symbol library that has a pre-made left arrow image similar to the standard iOS back for a nav view
            Image(systemName: "arrow.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat(BACK_BUTTON_ARROW_WIDTH), height: CGFloat(BACK_BUTTON_ARROW_HEIGHT))
                .foregroundColor(.blue)
                .font(Font.system(size: CGFloat(BACK_BUTTON_ARROW_FONT_SIZE)))
            Text(LocalizedStringKey(vm.languageType.localizedStrings["back"]!))
                .font(.system(size: CGFloat(BACK_TEXT_SIZE)))
        }
        .padding(.top, CGFloat(BACK_BUTTON_TOP_PADDING))
    }
}

#Preview {
    ContentView()
}
