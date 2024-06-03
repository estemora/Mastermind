//
//  FILE: ViewModel.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: View Model
//
// !! BEING RUN ON: iPhone 15 Pro
//
// Manually sending state updates: https://www.hackingwithswift.com/quick-start/swiftui/how-to-send-state-updates-manually-using-objectwillchange
// Using Raw Integers as Values for Enums: https://www.hackingwithswift.com/sixty/2/10/enum-raw-values
//

import Foundation

// class declaration for ViewModel that communicates between the ContentView and Model
class ViewModel: ObservableObject {
    
    // observable model that auto announces changes
    @Published var m = Model(numberOfColorOptions: NUMBER_OF_COLOR_OPTIONS)
    @Published var showHomePage: Bool = true
    @Published var tutorialMode: Bool = false
    @Published var selectedLanguage = Locale.current.language.languageCode?.identifier
    @Published var currentStep = 0
    
    // using UserDefaults to save user settings on app close, using objectWillChange since @Published doesn't work on a computed property
    var moveBeadType: MoveBeadType {
           get {
               return MoveBeadType(rawValue: UserDefaults.standard.integer(forKey: "moveBeadType")) ?? .tapToMove
           }
           set {
               UserDefaults.standard.set(newValue.rawValue, forKey: "moveBeadType")
               objectWillChange.send()
           }
       }
    
    var languageType: LanguageType {
           get {
               return LanguageType(rawValue: UserDefaults.standard.integer(forKey: "languageType")) ?? .en
           }
           set {
               UserDefaults.standard.set(newValue.rawValue, forKey: "languageType")
               objectWillChange.send()
           }
       }
    
    // computed property for getting all color options
    var colorOptions: Array<ColorOption> {
        return m.colorOptions
    }
    
    
    // computed property for getting all user guesses
    var userGuesses: Array<Guess> {
        return m.userGuesses
    }
    
    // var for Isabella's single guess array of beads
    var singleGuess: Array<Bead> {
        return m.singleGuess
    }

    // function for color selection
    func chooseColor(colorNumber: Int) {
        m.chooseColor(colorNumber: colorNumber)
    }
    
    //  function for row choice
    func incrementRow(rowNumber: Int) {
        m.incrementRow(rowNumber: rowNumber)
    }
    
    // function for checking if row is complete
    func isRowComplete(thisRow: Int) -> Bool {
        
        // conditional for step to change when the user in the tutorial fills up their first current row
        if m.isRowComplete(row: thisRow) == true && tutorialMode == true && currentStep == 3 {
            currentStep = 4
        }
        return m.isRowComplete(row: thisRow)
    }
    
    // function to directly remove a color from a single bead
    func removeColor(rowNumber: Int, column: Int) {
        m.removeColor(rowNumber: rowNumber, column: column)
    }
    
    // function for checking current row number
    var currentRowNumber: Int {
       return m.currentRowNumber
    }
    
    // recalculating initial row of the view to be at the bottom
    func recalcedRow(rowNumber: Int) -> Int {
        return MAX_GUESSES - 1 - rowNumber
    }
    
    // function for choosing a color in a guess
    func setGuessColor(selectedRow: Int, selectedCol: Int, currentColor: Int) {
        if gameState == .playing {
            m.setGuessColor(row: selectedRow, column: selectedCol, currentColor: currentColor)
        }
    }
    
    // function for creating tutorial mode code
    func tutorialModeCodeGen() {
        m.tutorialModeCodeGen()
    }
    
    // function for triggering feedback beads
    func feedbackBeads(row: Int) {
        m.feedbackBeads(row: row)
    }
    
    // var if there is a winner
    var winner: Bool {
        return m.gameState == .won
    }
    
    // var that gets the current color of a bead
    var currentColor: Int? {
        return m.currentColor
    }
    
    // var the returns what to set the current color of a guess to
    var setGuessCurrentColor: Int? {
        return m.setGuessCurrentColor
    }
    
    // var that returns the current state of the game (playing, won, lost)
    var gameState: GameState {
        return m.gameState
    }
    
    // var that returns the array of secret code color indices
    var secretCode: Array<Int> {
        return m.secretCode.codeColors
   }
    
    // function to reset the board
    func restartGame() {
        m = Model(numberOfColorOptions: NUMBER_OF_COLOR_OPTIONS)
    }
    
    // var that returns the current language type
    var updateLanguage: LanguageType {
        return m.languageType
    }
}
