//
//  GameOverScene.swift
//  SpriteKitTest
//
//  Created by Oleg Ketrar on 19.03.16.
//  Copyright © 2016 Oleg Ketrar. All rights reserved.
//

import Foundation
import SpriteKit

final class GameOverScene: SKScene {
    let score: Int
    weak var retryButton: SKLabelNode!

    init(size: CGSize, score: Int) {
        self.score = score
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // background
        backgroundColor = SKColor.red.withAlphaComponent(0.5)

        // message
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "You Lose!"
        label.fontSize = 45
        label.fontColor = .white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        let button = SKLabelNode(fontNamed: "Chalkduster")
        button.text = "Retry"
        button.fontSize = 35
        button.fontColor = .white
        button.position = CGPoint(x: size.width/2, y: label.frame.origin.y -
            button.frame.height - 20)
        addChild(button)

        retryButton = button

        // score button
        let scoreLabel = SKLabelNode(text: "score: \(score)")
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontName  = "Chalkduster"
        scoreLabel.fontColor = .white
        scoreLabel.fontSize  = 35
        scoreLabel.position  = CGPoint(x: size.width/2, y: size.height - scoreLabel.frame.height/2 - 100)

        addChild(scoreLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = touch.location(in: self)

            if retryButton.contains(location) {

                run(SKAction.run {
                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                    let scene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition:reveal)
                })
            }
        }
    }

    deinit {
        print("game over scene deallocated")
    }
}
