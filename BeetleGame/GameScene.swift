//
//  GameScene.swift
//  BeetleGame
//
//  Created by Adriano Rodrigues Vieira on 22/04/20.
//  Copyright © 2020 Adriano Rodrigues Vieira. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameStarted: Bool = false
    var isDied: Bool = false
    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    
    var score: Int = 0
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var taptopPlayLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var logoImage = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    //Criando o passaro para a animacao
    let birdAtlas = SKTextureAtlas(named: "player")
    var birdSprites = Array<Any>()
    var bird = SKSpriteNode()
    var repeateActionBir = SKAction()
    
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    // fazendo os preparativos para criar a cena
    func createScene() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.GROUND_CATEGORY
        self.physicsBody?.collisionBitMask = CollisionBitMask.BIRD_CATEGORY
        self.physicsBody?.contactTestBitMask = CollisionBitMask.BIRD_CATEGORY
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    }
}
