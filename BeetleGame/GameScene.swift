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
    var repeateActionBird = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameStarted {
            if !isDied {
                enumerateChildNodes(withName: "background") { (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                    }
                }
            }
        }
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
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))
        
        self.bird = createBird()
        self.addChild(bird)
        
        let animateBird = SKAction.animate(with: self.birdSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeateActionBird = SKAction.repeatForever(animateBird)
    }
}

extension GameScene {
    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named: "player").textureNamed("bird1"))
        
        bird.size = CGSize(width: 50, height: 50)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        
        bird.physicsBody?.categoryBitMask = CollisionBitMask.BIRD_CATEGORY
        bird.physicsBody?.collisionBitMask = CollisionBitMask.BIRD_CATEGORY | CollisionBitMask.GROUND_CATEGORY
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.PILLAR_CATEGORY | CollisionBitMask.FLOWER_CATEGORY | CollisionBitMask.GROUND_CATEGORY
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        
        return bird
        
        
    }
}
