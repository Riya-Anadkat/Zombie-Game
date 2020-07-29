//
//  GameOverScene.swift
//  Zombie Game
//
//  Created by Riya Anadkat on 2020-07-28.
//  Copyright © 2020 Riya Anadkat. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    let restartLabel = SKLabelNode(fontNamed: "the bold font")
    
    override func didMove(to view: SKView) {
    
        
        let background = SKSpriteNode (imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
        background.zPosition = 0
        self.addChild(background)
        
        let endLabel = SKLabelNode(fontNamed: "the bold font")
        endLabel.text = "GAME OVER"
        endLabel.fontSize = 200
        endLabel.fontColor = SKColor.white
        endLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        endLabel.zPosition = 1
        self.addChild(endLabel)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "the bold font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width * 0.4, y: self.size.height * 0.6)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScoreSaved")
        if gameScore>highScore{
            highScore = gameScore
            defaults.set(highScore, forKey: "highScoreSaved")
            let newHighScoreLabel = SKLabelNode(fontNamed: "the bold font")
            newHighScoreLabel.text = "new high score"
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scalesSequence = SKAction.sequence([scaleUp, scaleDown])
            newHighScoreLabel.run(scalesSequence)
            newHighScoreLabel.fontSize = 30
            newHighScoreLabel.fontColor = SKColor.white
            newHighScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.63)
            newHighScoreLabel.zPosition = 1
            self.addChild(newHighScoreLabel)
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "the bold font")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 50
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width * 0.6, y: self.size.height * 0.6)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 80
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transitionScene = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transitionScene)
                
                
            }
            
        }
    }
}
