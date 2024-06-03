//
//  FILE: SymbolicConstants.swift
//  Estefan Mora, Transy U
//  CS 3164, Winter 2024
//
//  Mastermind Game App: Symbolic Constants
//
// !! BEING RUN ON: iPhone 15 Pro
//

import SwiftUI

    // general symbolic constants
    let MAX_GUESSES = 10
    let TITLE_TEXT_SIZE = 20
    let HOME_TITLE_TEXT_SIZE = 40
    let INFO_TEXT_SIZE = 20
    let GENERAL_PADDING_SIZE = 2
    let BACKGROUND_COLOR = Color(red: 201/RGB_MAX, green: 253/RGB_MAX, blue: 201/RGB_MAX)

    // color symbolic constants
    let RGB_MAX = 255.0
    let COLOR_OPTIONS: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let NUMBER_OF_COLOR_OPTIONS = 6
    let SELECTED_COLOR_STROKE_WIDTH = 6
    let UNSELECTED_COLOR_STROKE_WIDTH = 4
    let UNFILLED_COLOR = Color.white
    let COLOR_GUESS_COUNT = 4
    let CURRENT_ROW_STROKE_COLOR = Color(red: 66/RGB_MAX, green: 212/RGB_MAX, blue: 244/RGB_MAX)
    let CURRENT_ROW_STROKE_STROKE_COLOR = Color.black
    let NOT_CURRENT_ROW_STROKE_COLOR = Color.black
    let NO_COLOR_VIEW = Color.clear
    
    // color guess row symbolic constants
    let COLOR_GUESS_FRAME_WIDTH = 42
    let COLOR_GUESS_FRAME_HEIGHT = 42
    let COLOR_OPTIONS_FRAME_WIDTH = 40
    let COLOR_OPTIONS_FRAME_HEIGHT = 40
    let COLOR_GUESS_ROW_HEIGHT = 20
    let COLOR_GUESS_ROW_ITEM_WIDTH = 50
    let COLOR_GUESS_ROW_STACK_SPACING = 0

    let CLICKED_BEAD_STROKE_WIDTH = 6
    let UNCLICKED_BEAD_STROKE_WIDTH = 4

    // go key symbolic constants
    let GO_KEY_RADIUS = 5
    let GO_KEY_STROKE_WIDTH = 3
    let GO_KEY_TEXT_SIZE = 20
    let GO_KEY_READY_COLOR = Color.green
    let GO_KEY_FRAME_WIDTH = 150
    let GO_KEY_FRAME_HEIGHT = 45
    let GO_KEY_ENABLED_COLOR = Color.purple
    let GO_KEY_DISABLED_COLOR = Color.black
    let GO_KEY_PADDING = 5

    // start key symbolic constants
    let START_KEY_RADIUS = 10
    let START_KEY_COLOR = Color(red: 66/RGB_MAX, green: 212/RGB_MAX, blue: 244/RGB_MAX)
    let START_KEY_STROKE_COLOR = Color.purple
    let START_KEY_STROKE_WIDTH = 3
    let START_KEY_PADDING = 5
    let START_KEY_TEXT_SIZE = 30
    let START_KEY_FRAME_WIDTH = 200
    let START_KEY_FRAME_HEIGHT = 50


    // peg symbolic constants
    let PEG_FRAME_WIDTH = 60
    let PEG_FRAME_HEIGHT = 50
    let PEG_STROKE_WIDTH = 5
    let PEG_FRAME_BACKGROUND_COLOR = Color(red: 150/RGB_MAX, green: 123/RGB_MAX, blue: 182/RGB_MAX)
    let PEG_FRAME_COLOR = Color.black
    let RIGHT_PEG_COLOR = Color.red
    let RIGHT_WRONG_PLACE_PEG_COLOR = Color.white
    let NO_PEG_COLOR = Color.clear
    let MAX_PEGS = 4
    let PEG_WIDTH = 18
    let PEG_HEIGHT = 18
    let PEGS_PER_ROW = 2
    let PEG_PADDING_SIZE = -1
    let PEG_STACK_SPACING = 5
    let PEG_STROKE_PADDING = 1
    let PEG_STROKE_COLOR = Color.black

    // end of game secret code view symbolic constants
    let SECRET_CODE_WIDTH_HEIGHT = 50
    let SECRET_CODE_VIEW_PADDING = 5
    let SECRET_CODE_STROKE_WIDTH = 7
    let LOSE_CODE_TEXT_SIZE = 50
    let SPANISH_LOSE_CODE_TEXT_SIZE = 40
    let WIN_CODE_TEXT_SIZE = 50
    let PLAY_AGAIN_TEXT_SIZE = 20

    // game over overlay symbolic constants
    let GAME_OVER_SCREEN_WIDTH = 400
    let GAME_OVER_SCREEN_HEIGHT = 275
    let GAME_OVER_SCREEN_PADDING_SIZE = 20
    let GAME_OVER_SCREEN_STROKE_WIDTH = 10
    let GAME_OVER_SCREEN_STROKE_COLOR = Color.black
    let GAME_OVER_BACKGROUND_COLOR = Color(red: 66/RGB_MAX, green: 212/RGB_MAX, blue: 244/RGB_MAX)
    let GAME_OVER_SCREEN_CORNER_RADIUS = 10
    let GAME_OVER_SECRET_CODE_CORNER_RADIUS = 10
    let GAME_OVER_SECRET_CODE_LINE_WIDTH = 1
    let WIN_CONFETTI_SIZE = 0.7
    let LOSE_CONFETTI_SIZE = 0.2


    // test mode variable, change to true or false if you want test mode or not
    let TEST_MODE = false
    
    // home symbolic constants
    let HOME_BOTTOM_PADDING = 150

    // navigation bar back symbolic constants
    let BACK_TEXT_SIZE = 20
    let BACK_BUTTON_ARROW_WIDTH = 20
    let BACK_BUTTON_ARROW_HEIGHT = 20
    let BACK_BUTTON_ARROW_FONT_SIZE = 20
    let BACK_BUTTON_TOP_PADDING = 7

    // settings symbolic constant
    let SETTINGS_BUTTON_SIZE = 30
    let SETTINGS_BUTTON_RADIUS = 40
    let LANGUAGE_VIEW_SPACING = -10
    let LANGUAGE_VIEW_BOTTOM_PADDING = 10
    let INPUT_TYPE_TOP_PADDING = 5
    let INPUT_TYPE_LEADING_PADDING = 10
    let TOGGLE_FRAME_WIDTH = 100
    let TOGGLE_FRAME_HEIGHT = 40
    let TOGGLE_BOTTOM_PADDING = 10
    let SPANISH_SETTINGS_TEXT_SIZE = 30
    let ENGLISH_SPANISH_INPUT_TEXT_SIZE = 17
    let TOGGLE_COLOR = Color.red
    let SETTINGS_BOTTOM_PADDING = 55

    // saturation symbolic constants
    let SATURATED  = 1.0
    let UNSATURATED  = 0.0

    // animation symbolic constants
    let GENERAL_ANIMATION_DURATION = 0.2
    let SUBMIT_TEXT_SCALED = 1.2
    let SUBMIT_TEXT_UNSCALED  = 1.0
    let SPRING_ANIMATION_HEIGHT = -5
    let SPRING_DEFAULT_HEIGHT = 0

    // tutorial symbolic constants
    let TUTORIAL_CORNER_RADIUS = 10
    let TUTORIAL_BACKGROUND_COLOR = Color.white
    let TUTORIAL_SHADOW_RADIUS = 5
    let GENERAL_TUTORIAL_PADDING = 20
    let TOP_TUTORIAL_PADDING_ENDGAME = -75
    let TOP_TUTORIAL_PADDING_NORMAL = -325

