//
//  GameScene.swift
//  Zombie Game
//
//  Created by Riya Anadkat on 2020-07-27.
//  Copyright © 2020 Riya Anadkat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameScore = 0
    let scoreLabel = SKLabelNode(fontNamed: "the bold font")
    
    let player = SKSpriteNode (imageNamed: "player")
    let arrowSound = SKAction.playSoundFileNamed("arrowSound.wav", waitForCompletion: false)
    
    let zombieSound = SKAction.playSoundFileNamed("zombieSound.wav", waitForCompletion: false)
    let playerSound = SKAction.playSoundFileNamed("playerSound.wav", waitForCompletion: false)
    
    struct physicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Arrow: UInt32 = 0b10 //2
        static let Zombie: UInt32 = 0b100 //4
        
    }
    
    
    //    func random () -> CGFloat {
    //        return CGFloat(Float(arc4random()) / 0xFFFFFFFFF)
    //    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        //return random() * (max - min) + min
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        // let playableWidth = size.height / maxAspectRatio
        let playableHeight = size.width / maxAspectRatio
        //let margin = (size.width - playableWidth)/2
        let margin = (size.height - playableHeight)/2
        //gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        gameArea = CGRect(x: 0, y: margin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode (imageNamed: "background")
        background.size = self.size
        //  background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
        background.zPosition = 0
        self.addChild(background)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Zombie
        
        
        player.setScale(0.15)
        player.position = CGPoint(x: self.size.width/1.1, y: self.size.height/2)
        player.zPosition = 2
        self.addChild(player)
        
        scoreLabel.text = "KILLS: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.64)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        startNewLevel()
        
        
        
    }
    func addScore(){
        gameScore += 1
        scoreLabel.text = "KILLS: \(gameScore)"
    }
    
    func fireArrow(){
        let arrow = SKSpriteNode (imageNamed: "arrow")
        arrow.setScale(0.10)
        arrow.position = CGPoint(x: player.position.x * 0.9, y: player.position.y * 1.07)
        //arrow.position = CGPoint(x: player.position, y: player.position * 1.25)
        //arrow.position = player.position
        arrow.zPosition = 1
        self.addChild(arrow)
        let moveArrow = SKAction.moveTo(x: 0 - arrow.size.width, duration: 1)
        //let moveArrow = SKAction.moveTo(0 + arrow.size.width, duration: 1)
        
        
        let deleteArrow =  SKAction.removeFromParent()
        let arrowSequence = SKAction.sequence([arrowSound, moveArrow, deleteArrow])
        arrow.run(arrowSequence)
        
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody!.affectedByGravity = false
        arrow.physicsBody!.categoryBitMask = physicsCategories.Arrow
        
        arrow.physicsBody!.collisionBitMask = physicsCategories.None
        arrow.physicsBody!.contactTestBitMask = physicsCategories.Zombie
        
        
    }
    
    func firstZombieMove(){
        let firstZombie = SKSpriteNode (imageNamed: "firstZombie")
        
        firstZombie.setScale(0.30)
        
        let firstStartPoint = CGPoint(x:0, y: random(min: gameArea.minY, max: gameArea.maxY))
        let firstEndPoint = CGPoint(x:self.size.width, y: random(min: gameArea.minY, max: gameArea.maxY))
        
        firstZombie.position = firstStartPoint
        
        
        
        firstZombie.zPosition = 2
        self.addChild(firstZombie)
        
        let moveFirstZombie = SKAction.move(to: firstEndPoint, duration: 4.5)
        
        
        //            SKAction.moveBy(x: self.size.width, y: random(min: gameArea.minY, max: gameArea.maxY), duration: 4)
        
        
        let deleteZombie =  SKAction.removeFromParent()
        let firstZombieSequence = SKAction.sequence([moveFirstZombie, deleteZombie])
        firstZombie.run(firstZombieSequence)
        
        
        let dx = firstEndPoint.x - firstStartPoint.x
        let dy = firstEndPoint.y - firstStartPoint.y
        let amountToRotateFirst = atan2(dy, dx)
        firstZombie.zRotation = amountToRotateFirst
        
        firstZombie.physicsBody = SKPhysicsBody(rectangleOf: firstZombie.size)
        firstZombie.physicsBody!.affectedByGravity = false
        
        firstZombie.physicsBody!.categoryBitMask = physicsCategories.Zombie
        firstZombie.physicsBody!.collisionBitMask = physicsCategories.None
        firstZombie.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Arrow
        
        
        
    }
    func secondZombieMove(){
        
        let secondZombie = SKSpriteNode (imageNamed: "secondZombie")
        let secondStartPoint = CGPoint(x:0, y: random(min: gameArea.minY, max: gameArea.maxY))
        let secondEndPoint = CGPoint(x:self.size.width, y: random(min: gameArea.minY, max: gameArea.maxY))
        
        secondZombie.setScale(0.30)
        secondZombie.position = secondStartPoint
        secondZombie.zPosition = 2
        self.addChild(secondZombie)
        
        let moveSecondZombie = SKAction.move(to: secondEndPoint, duration: 3.5)
        let deleteZombie =  SKAction.removeFromParent()
        let secondZombieSequence = SKAction.sequence([moveSecondZombie, deleteZombie])
        
        secondZombie.run(secondZombieSequence)
        
        let tx = secondEndPoint.x - secondStartPoint.x
        let ty = secondEndPoint.y - secondStartPoint.y
        let amountToRotateSecond = atan2(ty, tx)
        secondZombie.zRotation = amountToRotateSecond
        
        secondZombie.physicsBody = SKPhysicsBody(rectangleOf: secondZombie.size)
        secondZombie.physicsBody!.affectedByGravity = false
        secondZombie.physicsBody!.categoryBitMask = physicsCategories.Zombie
        secondZombie.physicsBody!.collisionBitMask = physicsCategories.None
        secondZombie.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Arrow
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Zombie{
            
            if body1.node != nil{
                run(playerSound)
                createBlood(createdPosition: body1.node!.position)
                
            }
            if body2.node != nil{
                createBlood(createdPosition: body2.node!.position)
                
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        if body1.categoryBitMask == physicsCategories.Arrow && body2.categoryBitMask == physicsCategories.Zombie{
            addScore()
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return
                }
                else{
                    createBlood(createdPosition: body1.node!.position)
                    
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    func createBlood(createdPosition: CGPoint){
        
        let blood = SKSpriteNode(imageNamed: "blood")
        
        blood.position = createdPosition
        blood.zPosition = 3
        self.addChild(blood)
        blood.setScale(0)
        let scaleIn = SKAction.scale(to: 0.3, duration: 0.1)
        let fadeout = SKAction.fadeOut(withDuration: 0.1)
        let deleteBlood = SKAction.removeFromParent()
        let bloodSequence = SKAction.sequence([zombieSound, scaleIn, fadeout, deleteBlood])
        
        blood.run(bloodSequence)
    }
    
    func startNewLevel(){
        let createFirstZombie = SKAction.run(firstZombieMove)
        let waitZombie = SKAction.wait(forDuration: 2)
        let createSecondZombie = SKAction.run(secondZombieMove)
        let createSequence = SKAction.sequence([waitZombie, createFirstZombie, waitZombie, createSecondZombie, waitZombie])
        let createZombieForever = SKAction.repeatForever(createSequence)
        self.run(createZombieForever)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireArrow()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location (in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.y - previousPointOfTouch.y
            player.position.y += amountDragged
            
            if player.position.y >= gameArea.maxY - player.size.height/2{
                player.position.y = gameArea.maxY - player.size.height/2
            }
            
            if player.position.y <= gameArea.minY + player.size.height/2 {
                player.position.y = gameArea.minY + player.size.height/2
            }
        }
    }
    
    
    
}
