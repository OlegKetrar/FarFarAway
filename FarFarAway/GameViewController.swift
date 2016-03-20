//
//  GameViewController.swift
//  FarFarAway
//
//  Created by Oleg Ketrar on 20.03.16.
//  Copyright (c) 2016 Oleg Ketrar. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill

        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



