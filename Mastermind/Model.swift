//
//  FILE: Model.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: Model
//
// !! BEING RUN ON: iPhone 15 Pro
//
// Unwrapping Optionals Reference: https://stackoverflow.com/questions/25589605/swift-shortcut-unwrapping-of-array-of-optionals
// Localization recommended by Apple: https://developer.apple.com/documentation/swiftui/preparing-views-for-localization
// Drag and Drop Struggles Reference: https://stackoverflow.com/questions/74290721/how-do-you-mark-a-single-container-as-a-dropdestination-for-multiple-transferabl
//

import SwiftUI
import UniformTypeIdentifiers
import CoreTransferable

struct Model {
    
    // initializing game state
    var gameState: GameState = .playing
    
    var tutorialMode: Bool = false
    
    var currentStep: Int = 0
    
    // making an array to hold color options
    var colorOptions: Array<ColorOption>
    
    // optional value for color
    var currentColor: Int?
    
    // Isabella's setting guess for a specific bead variable 
    var setGuessCurrentColor: Int?
    
    // array of all user guesses
    var userGuesses: Array<Guess>
    
    // variable for the arry of a singular guess
    var singleGuess: Array<Bead>
    
    // variable for tracking current row number
    var currentRowNumber: Int = 0
    
    // variable to hold the secret code
    var secretCode = SecretCode(codeColors: [])
    
    // making totalRed a global variable so other functions can see
    var totalRed: Int = 0
    
    // key for the language values
    let languageUserDefaultsKey = "LanguagePreference"
    
    // variable that gets the current setting device language and initially sets that to the user defaulted language
    var languageType: LanguageType {
        get {
            if let languageString = Locale.current.language.languageCode?.identifier {
                switch languageString {
                    case "en":
                        return .en
                    case "es":
                        return .es
                    case "zh":
                        return .zh
                    case "ko":
                        return .ko
                    default:
                        return .en
                }
            } else {
                return .en 
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageUserDefaultsKey)
        }
    }

    
    // array initializer of color options based on id equiv to array index number
    init (numberOfColorOptions: Int) {
        colorOptions = Array<ColorOption>()
        for colorIndex in 0..<numberOfColorOptions {
            colorOptions.append(ColorOption(id: colorIndex, isSelected: false))
        }
        
        // initialize set of all user guesses
        userGuesses = Array<Guess>()
        for i in 0..<MAX_GUESSES {
            userGuesses.append(Guess(id: i))
        }
        singleGuess = Array<Bead>()
        for i in 0..<MAX_GUESSES {
            singleGuess.append(Bead(id: i, column: i, isSelected: false, color: 5))
        }
        // generate the secret code at the start
        secretCode = generateCode()
        
        print("\(languageType)")
        // at the start, immediately let user know they are in test mode
        if TEST_MODE == true {
            print("YOU ARE CURRENTLY IN TEST MODE!")
        }
    }
    
    // function that can modify color option properties based on selection
    mutating func chooseColor(colorNumber: Int) {
        
            // deselect a previously selected color if applicable
            if let oldColor = currentColor {
                colorOptions[oldColor].isSelected = false
            }
            
            // selectng the new color
            colorOptions[colorNumber].isSelected = true
            currentColor = colorNumber
            print("Color Number: \(colorNumber) is selected!")
        
    }
    
    // function for removing a color, literally just setting to nil
    mutating func removeColor(rowNumber: Int, column: Int) {
        userGuesses[rowNumber].guessItem[column] = nil
    }
    
    // function that sets a color guess
    mutating func setGuessColor(row: Int, column: Int, currentColor: Int?) {
        print ("Setting bead color in column: \(column), row: \(row)")
        
        // checking if clicked color matches or not
        if userGuesses[row].guessItem[column] == currentColor {
            // if color matches, set the color to nil to make it void
            userGuesses[row].guessItem[column] = nil
        } 
        
        else {
            singleGuess[column].color = currentColor!
            userGuesses[row].guessItem[column] = currentColor
        }
    }
    

    // bool function to check if a row is complete, if there is at least one nil, do not increment row
    func isRowComplete(row: Int) -> Bool {
        if row < MAX_GUESSES && userGuesses[row].guessItem.contains(nil) {
            return false
        } 
        
        else {
            return true
        }
    }
    
    // calculates the number of red and white feedbacks to be displayed for a guess, slightly adapted from Isabella's
    mutating func feedbackBeads(row: Int) {
        
        // making new arrays to hold red and white pegs, just doing bools to count amount of trues and falses
        var redsFound = [Bool](repeating: false, count: COLOR_GUESS_COUNT)
        var whitesFound = [Bool](repeating: false, count: COLOR_GUESS_COUNT)
        
        // re-initializing count for red and white pegs
        var totalRed = 0
        var totalWhite = 0
        
        // loop to check reds
        for i in 0..<COLOR_GUESS_COUNT {
            if secretCode.codeColors[i] == userGuesses[row].guessItem[i] {
                totalRed += 1
                redsFound[i] = true
            }
        }
        
        // loop to check whites
        for i in 0..<COLOR_GUESS_COUNT {
            if redsFound[i] { 
                continue   // continue if the same one was already found as red
            }

            for j in 0..<COLOR_GUESS_COUNT {
                if !redsFound[j] && !whitesFound[j] && secretCode.codeColors[i] == userGuesses[row].guessItem[j] {
                    totalWhite += 1
                    whitesFound[j] = true
                    break // breaking, as each color in a guess can only match with one in the code
                }
            }
        }
        
        print("Total Reds: \(totalRed)")
        userGuesses[row].reds = totalRed
        print("Total White: \(totalWhite)")
        userGuesses[row].whites = totalWhite
    }

    // function for incrementing a row
    mutating func incrementRow(rowNumber: Int) {
        @ObservedObject var vm: ViewModel
        // if statement for test mode code determination, in incRow function since this occurs after final submission but before incrementation
        if currentRowNumber == 0 && TEST_MODE == true {
            testModeCodeGen()
        }
        
        // only continue if the row is fully filled
        if isRowComplete(row: currentRowNumber) == true {
            
            // checking total amount of red and white pegs before moving to next row
            feedbackBeads(row: currentRowNumber)
            
            // if the number of red pegs is equal to max pegs, the user won, unless in test_mode it skips the initial row so tester can continue
            if userGuesses[currentRowNumber].reds == MAX_PEGS && !(TEST_MODE && currentRowNumber == 0) {
                gameState = .won
                print("MODEL SAYS user won")
                for index in 0..<colorOptions.count {
                    colorOptions[index].isSelected = false
                }
            }
            
            else  {
                // if all pegs are not red, keep incrementing the row!
                currentRowNumber += 1
                print("Current Row: \(currentRowNumber)")
                
                if currentRowNumber == MAX_GUESSES {
                    gameState = .lost
                    print("\(gameState)")
                    print("MODEL: You Lose!")
                }
            }
        }
    }

    
    // function for generating the secret code that the user needs to guess correctly
    mutating func generateCode() -> SecretCode {
        var codeColors = [Int]()
        
        for _ in 0..<COLOR_GUESS_COUNT {
                // using Int.random to pick random index numbers of the array of color options
                let randomColorIndex = Int.random(in: 0..<NUMBER_OF_COLOR_OPTIONS)
                codeColors.append(randomColorIndex)
        }
        
        let secretCode = SecretCode(codeColors: codeColors)
        print("Generated Secret Code: \(secretCode.codeColors)")
        return secretCode
    }
    
    // kinda whacky function where if test mode is true, unwraps it then sets the secret code to the colors, see stack overflow link at top
    mutating func testModeCodeGen() {
        if let unwrappedCode = userGuesses.first?.guessItem.compactMap({ $0 }) {
            secretCode.codeColors = unwrappedCode
            print("Secret Code is now based on Row 0's bead index numbers: \(secretCode.codeColors)")
        } 
        
        else {
            print("No guess item found in userGuesses, or it's nil...")
        }
    }
    // another whacky function used for tutorial mode with a similar idea as test mode, dropFirst used to ignore first row
    // https://www.programiz.com/swift-programming/library/array/dropfirst
    mutating func tutorialModeCodeGen() {
        if let unwrappedCode = userGuesses.dropFirst().first?.guessItem.compactMap({ $0 }) {
            secretCode.codeColors = unwrappedCode
            print("Tutorial Code is now based on Row 2's bead index numbers: \(secretCode.codeColors)")
        } else {
            print("No guess item found in the second row of userGuesses, or it's nil...")
        }
    }
}

// secret code structure that just has an array for the code color index numbers
struct SecretCode {
    var codeColors : [Int]
}

// structure for all the color options
struct ColorOption: Transferable, Identifiable, Codable {
    
    // id = color option array index number
    var id: Int
    
    // selected color option
    var isSelected: Bool
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .colorOption)
    }
}

// four beads representing user guess of secret color code
struct Guess: Identifiable {
    
    // id of a single guess
    var id: Int
    
    // array is initialized to all nils then gradually gets filled as user fills in the row
    var guessItem: [Int?] = Array(repeating: nil, count: COLOR_GUESS_COUNT)
    
    // variables to represent pegs in the row
    var reds: Int = 0
    var whites: Int = 0
    
}

// The Drag and Drop Saga
// source and general code given by Isabella, proxy representation basically uses another type's transfer representation as a proxy for a different type
struct Bead: Transferable, Identifiable, Codable {
    var id: Int
    var column: Int
    var isSelected: Bool
    var color: Int
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .bead)
    }
}

extension Int: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .integer)
    }
}

enum DropItem: Codable, Transferable {
    case bead(Bead)
    case colorOption(ColorOption)
    
    var bead: Bead {
        switch self {
        case .bead(let bead): return bead
        default: return Bead(id: 0, column: 0, isSelected: false, color: 5)
        }
    }
    
    var colorOption: ColorOption {
        switch self {
        case .colorOption(let colorOption): return colorOption
        default: return ColorOption(id: 0, isSelected: false)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { DropItem.bead($0) }
        ProxyRepresentation { DropItem.colorOption($0) }
    }
}

// extension type I need to add in order for custom drag and drop types to work
extension UTType {
    static let colorOption = UTType(exportedAs: "edu.transy.cs3164.colorOption")
    static let bead = UTType(exportedAs: "edu.transy.cs3164.bead")
    static let integer = UTType(exportedAs: "edu.transy.cs3164.integer")
}

// color insertion type enum, given raw values for user default setting
enum MoveBeadType: Int {
    case tapToMove = 0
    case dragAndDrop = 1
}

// enum that lists all the possible game states
enum GameState {
    case playing
    case lost
    case won
}

// massive enum for all my translations to handle in-app changing of language
enum LanguageType: Int {

    // each case gets a raw value for setting user defaults
    case en = 0 // English
    case es = 1 // Spanish
    case zh = 2 // Chinese-Simplified
    case ko = 3 // Korean
    
    
    var localizedStrings: [String: String] {
        switch self {
        case .en:
            return [
                "choose_color": "Choose a Color",
                "drag_and_drop": "Drag and Drop",
                "game_over": "GAME OVER!",
                "loss_restart_text": "Play again?",
                "loss_text": "Yikes...",
                "restart": "Restart",
                "settings_title": "Settings",
                "start_game": "Start",
                "back": "Back",
                "SUBMIT": "SUBMIT",
                "next" : "Next",
                "tap_to_move": "Tap",
                "title": "Mastermind",
                "win_restart_text":  "Play Again?!",
                "win_text": "Great job!",
                "winner": "WINNER!",
                "language": "English",
                "tutorial_mode": "Tutorial",
                "step_zero" : "Welcome to the tutorial!",
                "step_one" : "If you want to change your settings, click on the cogwheel in the top right. Here, you can change your preferred language and color insertion style.",
                "step_two" : "These are your colors, combine a set of these to make a guess for the secret code.",
                "step_three": "This is the current row, this is where you place your chosen colors for the guess. Try filling up the row with colors!",
                "step_four": "This is your submit button, it will initially be grayed out. Once the current row is filled with colors, it will enable. Once satisfied with your guess, click on it to see how close your guess is to the code!",
                "step_five" : "These are your feedback bead boxes. They hold up to four beads. A white bead indicates you have a color right in the wrong spot, a red bead indicates you have a color right in the right spot. Try making another guess in the next row!",
                "step_six": "This is the end of game screen, you can see what the correct color code was, and you can choose to play again by clicking the bottom button.",
                "step_seven": "Tutorial complete. Enjoy the game!"
            ]
        case .es:
            return [
                "choose_color": "Elegir un Color",
                "drag_and_drop": "Arrastrar y Soltar",
                "game_over": "FIN DEL JUEGO!",
                "loss_restart_text": "¿Jugar de Nuevo?",
                "loss_text": "Pobrecito...",
                "restart": "Reiniciar ",
                "settings_title": "Configuraciónes",
                "start_game": "Empezar",
                "back" : "Atrás",
                "next" : "Próximo",
                "SUBMIT": "ENVIAR",
                "tap_to_move": "Toqué",
                "title": "Cerebro",
                "win_restart_text":  "¡¿Jugar de Nuevo?!",
                "win_text": "¡Magnífico!",
                "winner": "¡GANADOR!",
                "language": "Español",
                "tutorial_mode" : "Tutorial",
                "step_zero" : "¡Bienvenido al tutorial!",
                "step_one" : "Si desea cambiar su configuración, haga clic en la rueda dentada en la parte superior derecha. Aquí puede cambiar su idioma preferido y el estilo de inserción de color.",
                "step_two" : "Estos son tus colores, combina un conjunto de estos para adivinar el código secreto.",
                "step_three": "Esta es la fila actual, aquí es donde colocas los colores elegidos para adivinar. ¡Intenta llenar la fila con colores!",
                "step_four": "Este es su botón de enviar; inicialmente estará atenuado. Una vez que la fila actual esté llena de colores, se habilitará. Una vez que esté satisfecho con su suposición, haga clic en ella para ver qué tan cerca está su suposición del código.",
                "step_five" : "Estas son tus cajas de cuentas de comentarios. Tienen capacidad para cuatro cuentas. Una cuenta blanca indica que tiene un color en el lugar equivocado, una cuenta roja indica que tiene un color en el lugar correcto. ¡Intenta hacer otra suposición en la siguiente fila!",
                "step_six": "Esta es la pantalla de final del juego, puedes ver cuál era el código de color correcto y puedes elegir jugar nuevamente haciendo clic en el botón inferior.",
                "step_seven": "Tutorial completo. ¡Disfruta el juego!"
            ]
        case .zh:
            return [
                "choose_color": "选择一种颜色",
                "drag_and_drop": "拖放",
                "game_over": "游戏结束!",
                "loss_restart_text": "再玩一次吗？",
                "loss_text": "哎呀...",
                "restart": "重新开始",
                "next" : "下面",
                "settings_title": "设置",
                "start_game": "开始",
                "back": "返回",
                "SUBMIT": "提交",
                "tap_to_move": "点按 来移动",
                "title": "策划者",
                "win_restart_text":  "再玩一次吗?!",
                "win_text": "太好了!",
                "winner": "赢家!",
                "language": "中文",
                "tutorial_mode" : "模式教程",
                "step_zero" : "欢迎来到教程",
                "step_one" : "如果您想更改设置，请单击右上角的齿轮。在这里，您可以更改您的首选语言和颜色插入样式!",
                "step_two" : "这些是你的颜色，组合一组这些颜色来猜测密码。",
                "step_three": "这是当前行，您可以在此处放置您选择的猜测颜色。尝试用颜色填充该行!",
                "step_four": "这是您的提交按钮，最初会呈灰色。一旦当前行填充了颜色，它将启用。一旦对您的猜测感到满意，请单击它以查看您的猜测与代码有多接近!",
                "step_five" : "这些是您的反馈珠盒。它们最多可容纳四颗珠子。白色珠子表示您的颜色位于错误的位置，红色珠子表示您的颜色位于正确的位置。尝试在下一行再次猜测!",
                "step_six": "这是游戏屏幕的结束，您可以看到正确的颜色代码是什么，您可以通过单击底部按钮选择再次玩。",
                "step_seven": "教程完成。玩的开心!"
            ]
        case .ko:
            return [
                "choose_color": "색을 선택해",
                "drag_and_drop": "끌어서 놓기",
                "game_over": "패배.",
                "loss_restart_text": "다시 놉니까?",
                "loss_text": "땡!",
                "restart": "다시 시작해",
                "next" : "다음",
                "settings_title": "설정",
                "start_game": "게임을 시작해",
                "back": "뒤로",
                "SUBMIT": "제출해",
                "tap_to_move": "탭",
                "title": "마스터마인드",
                "win_restart_text":  "다시 놉니까?!",
                "win_text": "승리!",
                "winner": "승자!",
                "language": "한국어",
                "tutorial_mode" : "튜토리얼",
                "step_zero" : "이것은 튜토리얼이다!",
                "step_one" : "설정을 변경하려면 오른쪽 상단의 톱니바퀴를 클릭하세요. 여기에서 원하는 언어와 색상 삽입 스타일을 변경할 수 있다.",
                "step_two" : "이것은 색상 선택이에요. 색상 선택을 클릭하여 비밀 코드를 추측하세요.",
                "step_three": "이것은 현재 행이며, 추측을 위해 선택한 색상을 배치하는 곳이다.",
                "step_four": "이것은 제출 버튼! 처음에는 회색으로 표시다. 현재 행이 색상으로 채워지면 활성화된다. 추측에 만족하면 클릭하여 추측이 코드에 얼마나 가까운지 확인하세요!",
                "step_five" : "이것은 피드백 비드 박스이다. 최대 사개의 구슬을 담을 수 있어요. 흰색 구슬은 색상은 정확하지만 잘못된 위치에 있음을 의미하세요. 빨간색 구슬은 색상이 올바른 지점에 위치에 있음을 의미하세요. 다음 줄에 또 다른 추측을 해보세요",
                "step_six": "게임 종료 화면이다. 정확한 색상 코드가 무엇인지 확인할 수 있으며,  다시 놀다하려면 하단 버튼을 클릭하세요.",
                "step_seven": "튜토리얼을 완료, 재미를!"
            ]
        }
    }
}
