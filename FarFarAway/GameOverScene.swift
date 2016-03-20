//
//  GameOverScene.swift
//  SpriteKitTest
//
//  Created by Oleg Ketrar on 19.03.16.
//  Copyright © 2016 Oleg Ketrar. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {

    let score: Int

    init(size: CGSize, score: Int) {

        self.score = score
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var retryButton: SKLabelNode!

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)

        // background
        backgroundColor = SKColor.redColor().colorWithAlphaComponent(0.5)

        // message
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "You Lose!"
        label.fontSize = 45
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        let button = SKLabelNode(fontNamed: "Chalkduster")
        button.text = "Retry"
        button.fontSize = 35
        button.fontColor = SKColor.whiteColor()
        button.position = CGPoint(x: size.width/2, y: label.frame.origin.y -
            button.frame.height - 20)
        addChild(button)

        retryButton = button

        // score button
        let scoreLabel = SKLabelNode(text: "score: \(score)")
        scoreLabel.horizontalAlignmentMode = .Center
        scoreLabel.fontName  = "Chalkduster"
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.fontSize  = 35
        scoreLabel.position  = CGPoint(x: size.width/2, y: size.height - scoreLabel.frame.height/2 - 100)

        addChild(scoreLabel)
    }

    deinit {
        print("game over scene deallocated")
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {

            let location = touch.locationInNode(self)

            if retryButton.containsPoint(location) {

                runAction(SKAction.runBlock() {
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    let scene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
        }
    }
}



