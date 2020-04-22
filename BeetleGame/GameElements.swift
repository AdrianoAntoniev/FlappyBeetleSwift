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
