//
//  GameElements.swift
//  BeetleGame
//
//  Created by Adriano Rodrigues Vieira on 22/04/20.
//  Copyright © 2020 Adriano Rodrigues Vieira. All rights reserved.
//

import Foundation

import SpriteKit

struct  CollisionBitMask {
    static let BIRD_CATEGORY: UInt32 = 0x1 << 0     //1
    static let PILLAR_CATEGORY: UInt32 = 0x1 << 1   //10
    static let FLOWER_CATEGORY: UInt32 = 0x1 << 2   //100
    static let GROUND_CATEGORY: UInt32 = 0x1 << 3   //1000
}

struct Assets {
    static let COIN_SOUND = "CoinSound.mp3"
    static let PLAYER_ATLAS_FILE_NAME = "player"
    static let BACKGROUND_NAME = "background"
    static let BACKGROUND_FILE_NAME = "bg"
    static let WALLPAIR_NAME = "wallPair"
    
    static let BIRD_FILES = ["bird1", "bird2", "bird3", "bird4"]
    static let RESTART_BUTTON = "restart"
    static let PAUSE_BUTTON = "pause"
    static let LOGO = "logo"
    static let FLOWER = "flower"
    static let PILLER = "piller"
}

struct Fonts {
    static let SCORE = "HelveticaNeue-Bold"
    static let HIGHSCORE = "Helvetica-Bold"
    static let TAPTOPLAY = "HelveticaNeue"
}

struct Defaults {
    static let HIGHEST_SCORE = "highestScore"
}

struct GameTexts {
    static let TAPTOPLAY_LABEL = "Tap anywhere to play"
}

struct RandomNumbers {
    static func getARandomCGFloatInBounds(min: CGFloat, max: CGFloat) -> CGFloat {
        let randomNumber = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
        return randomNumber * (max - min) + min
    }
}
