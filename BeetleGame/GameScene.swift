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
    let coinSound = SKAction.playSoundFileNamed(Assets.COIN_SOUND, waitForCompletion: false)
    
    var score: Int = 0
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var taptoPlayLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var logoImage = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    //Criando o passaro para a animacao
    let birdAtlas = SKTextureAtlas(named: Assets.PLAYER_ATLAS_FILE_NAME)
    var birdSprites = Array<Any>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            isGameStarted = true
            bird.physicsBody?.affectedByGravity = true
            createPauseButton()
            
            logoImage.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImage.removeFromParent()
            })
            taptoPlayLabel.removeFromParent()
            
            bird.run(repeatActionBird)
            
            let spawn = SKAction.run {
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            }
            let delay = SKAction.wait(forDuration: 1.5)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
            attachVelocityAndImpulseToBird()
        } else {
            if !isDied {
                attachVelocityAndImpulseToBird()
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if isDied {
                if restartButton.contains(location) {
                    if UserDefaults.standard.object(forKey: Defaults.HIGHEST_SCORE) != nil {
                        let highScore = UserDefaults.standard.integer(forKey: Defaults.HIGHEST_SCORE)
                        
                        if highScore < Int(scoreLabel.text!)! {
                            UserDefaults.standard.set(scoreLabel.text, forKey: Defaults.HIGHEST_SCORE)
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: Defaults.HIGHEST_SCORE)
                    }
                    restartScene()
                }
            } else {
                if pauseButton.contains(location) {
                    if !isPaused {
                        isPaused = true
                        pauseButton.texture = SKTexture(imageNamed: Assets.PLAY_BUTTON)
                    } else {
                        isPaused = false
                        pauseButton.texture = SKTexture(imageNamed: Assets.PAUSE_BUTTON)
                    }
                }
            }
            
            
        }
    }
    
    func attachVelocityAndImpulseToBird() {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        let isBirdCollidedWithPillar = firstBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.PILLAR_CATEGORY || firstBody.categoryBitMask == CollisionBitMask.PILLAR_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY
        let isBirdCollidedWithGroundOrCell = firstBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.GROUND_CATEGORY || firstBody.categoryBitMask == CollisionBitMask.GROUND_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY
        let isBirdCollidedWithFlower = firstBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.FLOWER_CATEGORY
        let isFlowerCollidedWithBird = firstBody.categoryBitMask == CollisionBitMask.FLOWER_CATEGORY && secondBody.categoryBitMask == CollisionBitMask.BIRD_CATEGORY

        if  isBirdCollidedWithPillar || isBirdCollidedWithGroundOrCell {
            enumerateChildNodes(withName: Assets.WALLPAIR_NAME) { (node, error) in
                node.speed = 0
                self.removeAllActions()
            }
            if !isDied {
                isDied = true
                createRestartButton()
                pauseButton.removeFromParent()
                self.bird.removeAllActions()
            }
        } else if isBirdCollidedWithFlower {
            removeFlowerAndUpdateScoreAnimation(secondBody)
        } else if isFlowerCollidedWithBird {
            removeFlowerAndUpdateScoreAnimation(firstBody)
        }
        
    }
    
    func removeFlowerAndUpdateScoreAnimation(_ body: SKPhysicsBody) {
        run(coinSound)
        score += 1
        scoreLabel.text = "\(score)"
        body.node?.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameStarted {
            if !isDied {
                enumerateChildNodes(withName: Assets.BACKGROUND_NAME) { (node, error) in
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
            let background = SKSpriteNode(imageNamed: Assets.BACKGROUND_FILE_NAME)
            background.anchorPoint = CGPoint(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = Assets.BACKGROUND_NAME
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        birdSprites.append(birdAtlas.textureNamed(Assets.BIRD_FILES[0]))
        birdSprites.append(birdAtlas.textureNamed(Assets.BIRD_FILES[1]))
        birdSprites.append(birdAtlas.textureNamed(Assets.BIRD_FILES[2]))
        birdSprites.append(birdAtlas.textureNamed(Assets.BIRD_FILES[3]))
        
        self.bird = createBird()
        self.addChild(bird)
        
        let animateBird = SKAction.animate(with: self.birdSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        
        scoreLabel = createScoreLabel()
        self.addChild(scoreLabel)
        
        highScoreLabel = createHighscoreLabel()
        self.addChild(highScoreLabel)
        
        createLogo()
        
        taptoPlayLabel = createTapToPlayLabel()
        self.addChild(taptoPlayLabel)
    }
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
}

extension GameScene {
    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named: Assets.PLAYER_ATLAS_FILE_NAME).textureNamed(Assets.BIRD_FILES[0]))
        
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
    
    func createRestartButton() {
        restartButton = SKSpriteNode(imageNamed: Assets.RESTART_BUTTON)
        restartButton.size = CGSize(width: 100, height: 100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: Assets.PAUSE_BUTTON)
        pauseButton.size = CGSize(width: 40, height: 40)
        pauseButton.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseButton.zPosition = 6
        self.addChild(pauseButton)
    }
    
    func createScoreLabel() -> SKLabelNode {
        let scoreLabel = SKLabelNode()
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 50
        scoreLabel.fontName = Fonts.SCORE
        
        let scoreBackground = SKShapeNode()
        scoreBackground.position = CGPoint(x: 0, y: 0)
        
        let scoreBackgroundPathRoundedRect = CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100))
        scoreBackground.path = CGPath(roundedRect: scoreBackgroundPathRoundedRect, cornerWidth: 50, cornerHeight: 50, transform: nil)
        
        let scoreBackgroundColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255), alpha: CGFloat(0.2))
        
        scoreBackground.strokeColor = UIColor.clear
        scoreBackground.fillColor = scoreBackgroundColor
        scoreBackground.zPosition = -1
        scoreLabel.addChild(scoreBackground)
        
        return scoreLabel
    }
    
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLabel = SKLabelNode()
        highscoreLabel.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        
        var highestScoreNumber = 0
        if UserDefaults.standard.object(forKey: Defaults.HIGHEST_SCORE) != nil {
            highestScoreNumber = UserDefaults.standard.integer(forKey: Defaults.HIGHEST_SCORE)
        }
        highscoreLabel.text = "Highest Score: \(highestScoreNumber)"
        
        highscoreLabel.zPosition = 5
        highscoreLabel.fontSize = 15
        highscoreLabel.fontName = Fonts.HIGHSCORE
        
        return highscoreLabel
    }
    
    func createLogo() {
        logoImage = SKSpriteNode(imageNamed: Assets.LOGO)
        logoImage.size = CGSize(width: 272, height: 65)
        logoImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        logoImage.setScale(0.5)
        self.addChild(logoImage)
        logoImage.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createTapToPlayLabel() -> SKLabelNode {
        let tapToPlayLabel = SKLabelNode()
        //todo: tirar o 40 "hard-coded" e fazer de forma que o texto se adapte conforme a tela
        tapToPlayLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 40)
        tapToPlayLabel.text = GameTexts.TAPTOPLAY_LABEL
        tapToPlayLabel.fontColor = UIColor(red: 63/255, green: 79/255, blue: 14/255, alpha: 1.0)
        tapToPlayLabel.zPosition = 5
        tapToPlayLabel.fontSize = 20
        tapToPlayLabel.fontName = Fonts.TAPTOPLAY
        
        return tapToPlayLabel
    }
    
    func createWalls() -> SKNode {
        let flowerNode = SKSpriteNode(imageNamed: Assets.FLOWER)
        flowerNode.size = CGSize(width: 40, height: 40)
        flowerNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        flowerNode.physicsBody = SKPhysicsBody(rectangleOf: flowerNode.size)
        flowerNode.physicsBody?.affectedByGravity = false
        flowerNode.physicsBody?.isDynamic = false
        flowerNode.physicsBody?.categoryBitMask = CollisionBitMask.FLOWER_CATEGORY
        flowerNode.physicsBody?.collisionBitMask = 0
        flowerNode.physicsBody?.contactTestBitMask = CollisionBitMask.BIRD_CATEGORY
        flowerNode.color = SKColor.blue

        wallPair = SKNode()
        wallPair.name = Assets.WALLPAIR_NAME
        
        let topWall = createSpriteNodeWall(isBottom: false)
        let bottomWall = createSpriteNodeWall(isBottom: true)
        topWall.zRotation = CGFloat(Double.pi)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 1
        
        let randomPosition = RandomNumbers.getARandomCGFloatInBounds(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(flowerNode)
        
        wallPair.run(moveAndRemove)
        
        return wallPair
        
    }
    
    func createSpriteNodeWall(isBottom: Bool) -> SKSpriteNode {
        let wallXPosition = self.frame.width + 25
        let yPosition = isBottom ? -420 : 420
        let wallYPosition = self.frame.height / 2 + CGFloat(yPosition)
        
        let wall = SKSpriteNode(imageNamed: Assets.PILLER)
        wall.position  = CGPoint(x: wallXPosition, y: wallYPosition)
        wall.setScale(0.5)
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.categoryBitMask = CollisionBitMask.PILLAR_CATEGORY
        wall.physicsBody?.collisionBitMask = CollisionBitMask.BIRD_CATEGORY
        wall.physicsBody?.contactTestBitMask = CollisionBitMask.BIRD_CATEGORY
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.affectedByGravity = false
        
        return wall
    }
}
