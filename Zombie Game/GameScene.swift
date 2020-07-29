//
//  GameScene.swift
//  Zombie Game
//
//  Created by Riya Anadkat on 2020-07-27.
//  Copyright © 2020 Riya Anadkat. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    let tapToBegin = SKLabelNode(fontNamed: "the bold font")
    
    var levelNumber = 0
    var livesNumber = 3
   // var numberOfArrows = 10
    
    let scoreLabel = SKLabelNode(fontNamed: "the bold font")
    let livesLabel = SKLabelNode(fontNamed: "the bold font")
    let levelLabel = SKLabelNode(fontNamed: "the bold font")
    //let numberOfArrowsLabel = SKLabelNode(fontNamed: "the bold font")
    
    let player = SKSpriteNode (imageNamed: "player")
    
    let arrowSound = SKAction.playSoundFileNamed("arrowSound.wav", waitForCompletion: false)
    let zombieSound = SKAction.playSoundFileNamed("zombieSound.wav", waitForCompletion: false)
//    let playerSound = SKAction.playSoundFileNamed("playerSound.wav", waitForCompletion: false)
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    var currentGameState = gameState.preGame
    
    struct physicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Arrow: UInt32 = 0b10 //2
        static let Zombie: UInt32 = 0b100 //4
        
    }
    
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        //return random() * (max - min) + min
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let margin = (size.height - playableHeight)/2
        gameArea = CGRect(x: 0, y: margin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        gameScore = 0
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode (imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
        background.zPosition = 0
        self.addChild(background)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Zombie
        
        
        player.setScale(0.15)
//        player.position = CGPoint(x: self.size.width/1.1, y: self.size.height/2)
        player.position = CGPoint(x: self.size.width + player.size.width, y: self.size.height/2)
        player.zPosition = 2
        self.addChild(player) 
        
        scoreLabel.text = "KILLS: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        //scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.64)
        scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height + scoreLabel.frame.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "LIVES: 3"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        //livesLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.64)
        livesLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height + livesLabel.frame.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        levelLabel.text = "LEVEL: \(levelNumber)"
        levelLabel.fontSize = 50
        levelLabel.fontColor = SKColor.white
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        //levelLabel.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.64)
        levelLabel.position = CGPoint(x: self.size.width * 0.9, y: self.size.height + levelLabel.frame.height)
        levelLabel.zPosition = 100
        self.addChild(levelLabel)
        
        let moveToScreen = SKAction.moveTo(y: self.size.height * 0.64, duration: 0.3)
        levelLabel.run(moveToScreen)
        livesLabel.run(moveToScreen)
        scoreLabel.run(moveToScreen)
        
        tapToBegin.text = "tap to begin"
        tapToBegin.fontSize = 100
        tapToBegin.fontColor = SKColor.white
        tapToBegin.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        tapToBegin.zPosition = 100
        tapToBegin.alpha = 0
        self.addChild(tapToBegin)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        tapToBegin.run(fadeIn)
    
    }
    func startGame(){
        currentGameState = gameState.inGame
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction =  SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, deleteAction])
        tapToBegin.run(deleteSequence)
        
        let movePlayerToScreen = SKAction.moveTo(x: self.size.width/1.1, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([movePlayerToScreen, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    
    func loseLives(){
        livesNumber -= 1
        livesLabel.text = "LIVES: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scalesSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scalesSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }

    }
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "KILLS: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
    }
    func runGameOver(){
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Arrow"){
            (arrow, stop) in
            arrow.removeAllActions()
        }
        self.enumerateChildNodes(withName: "FirstZombie"){
            (firstZombie, stop) in
            firstZombie.removeAllActions()
        }
        self.enumerateChildNodes(withName: "SecondZombie"){
                  (secondZombie, stop) in
                  secondZombie.removeAllActions()
              }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChange = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChange, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transitionTime = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: transitionTime)
        
         
    }
    
    func fireArrow(){
        let arrow = SKSpriteNode (imageNamed: "arrow")
        arrow.name = "Arrow"
        
        arrow.setScale(0.10)
        arrow.position = CGPoint(x: player.position.x * 0.9, y: player.position.y * 1.07)
        //arrow.position = CGPoint(x: player.position, y: player.position * 1.25)
        //arrow.position = player.position
        arrow.zPosition = 1
        self.addChild(arrow)
        let moveArrow = SKAction.moveTo(x: 0 - arrow.size.width, duration: 1)
        
        
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
        firstZombie.name = "FirstZombie"
        
        let firstStartPoint = CGPoint(x:0, y: random(min: gameArea.minY, max: gameArea.maxY))
        let firstEndPoint = CGPoint(x:self.size.width, y: random(min: gameArea.minY, max: gameArea.maxY))
        
        firstZombie.position = firstStartPoint
        
        
        
        firstZombie.zPosition = 2
        self.addChild(firstZombie)
        
        let moveFirstZombie = SKAction.move(to: firstEndPoint, duration: 4.5)
        
        let deleteZombie =  SKAction.removeFromParent()
        let loseALife = SKAction.run(loseLives)
        let firstZombieSequence = SKAction.sequence([moveFirstZombie, deleteZombie, loseALife])
        if currentGameState == gameState.inGame{
            firstZombie.run(firstZombieSequence)
        }
        
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
        secondZombie.name = "SecondZombie"
        
        secondZombie.position = secondStartPoint
        secondZombie.zPosition = 2
        self.addChild(secondZombie)
        
        let moveSecondZombie = SKAction.move(to: secondEndPoint, duration: 3.5)
        let deleteZombie =  SKAction.removeFromParent()
        let loseALife = SKAction.run(loseLives)
        let secondZombieSequence = SKAction.sequence([moveSecondZombie, deleteZombie, loseALife])
        if currentGameState == gameState.inGame{
            secondZombie.run(secondZombieSequence)
        }
        
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
                createBlood(createdPosition: body1.node!.position)
                
            }
            if body2.node != nil{
                createBlood(createdPosition: body2.node!.position)
                
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
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
        levelNumber += 1
        levelLabel.text = "LEVEL: \(levelNumber)"
        
        if self.action(forKey: "creatingZombies") != nil{
            self.removeAction(forKey: "creatingZombies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1
        case 2: levelDuration = 0.8
        case 3: levelDuration = 0.5
        case 4: levelDuration = 0.3
        default:
            levelDuration = 0.5
            print("Error. Can't find level duration.")
            
        }
        let createFirstZombie = SKAction.run(firstZombieMove)
        let waitZombie = SKAction.wait(forDuration: levelDuration)
        let createSecondZombie = SKAction.run(secondZombieMove)
        let createSequence = SKAction.sequence([waitZombie, createFirstZombie, waitZombie, createSecondZombie, waitZombie])
        let createZombieForever = SKAction.repeatForever(createSequence)
        self.run(createZombieForever, withKey: "creatingZombies")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireArrow()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location (in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.y - previousPointOfTouch.y
            
            if currentGameState == gameState.inGame{
                player.position.y += amountDragged
            }
            
            if player.position.y >= gameArea.maxY - player.size.height/2{
                player.position.y = gameArea.maxY - player.size.height/2
            }
            
            if player.position.y <= gameArea.minY + player.size.height/2 {
                player.position.y = gameArea.minY + player.size.height/2
            }
        }
    }
    
    
    
}
