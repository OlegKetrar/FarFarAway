//
//  GameScene.swift
//  FarFarAway
//
//  Created by Oleg Ketrar on 20.03.16.
//  Copyright (c) 2016 Oleg Ketrar. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: Init

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    let labelColor = UIColor.blackColor()

    override func didMoveToView(view: SKView) {

        // MARK: - setup UI
        backgroundColor = UIColor.whiteColor()

        let someLabel = SKLabelNode(fontNamed: "Chalkduster")
        someLabel.text = "score: \(score)"
        someLabel.fontSize  = 15
        someLabel.fontColor = labelColor
        someLabel.position  = CGPoint(x: someLabel.frame.width/2 + 20, y: size.height - someLabel.frame.height/2 - 20)

        addChild(someLabel)
        scoreLabel = someLabel

        let someLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        someLevelLabel.text      = "level: \(level)"
        someLevelLabel.fontSize  = 15
        someLevelLabel.fontColor = labelColor
        someLevelLabel.position  = CGPoint(x: size.width - someLevelLabel.frame.width/2 - 20,
            y: size.height - someLevelLabel.frame.height/2 - 20)

        addChild(someLevelLabel)
        levelLabel = someLevelLabel

        // add control buttons
        let someLeftButton = SKLabelNode(fontNamed: "Chalkduster")
        someLeftButton.text = "Left"
        someLeftButton.fontColor = labelColor
        someLeftButton.fontSize  = 20.0
        someLeftButton.position = CGPoint(x: someLeftButton.frame.width/2 + 30, y: 50)

        addChild(someLeftButton)

        let someRightButton = SKLabelNode(fontNamed: "Chalkduster")
        someRightButton.text = "Right"
        someRightButton.fontColor = labelColor
        someRightButton.fontSize  = 20.0
        someRightButton.position = CGPoint(x: size.width - someLeftButton.frame.width/2 - 30, y: 50)

        addChild(someRightButton)

        // set animable texture
        let playerAnimatedAtlas = SKTextureAtlas(named: "PlayerAnimation")

        var playerAnimationTextures: [SKTexture] = []

        for i in 0..<playerAnimatedAtlas.textureNames.count {
            playerAnimationTextures.append(playerAnimatedAtlas.textureNamed("\(i+1)"))
        }

        // create hero spaceship
        let hero = SKSpriteNode(texture: playerAnimationTextures[0],
            color: UIColor.clearColor(), size: CGSize(width: 75, height: 75))

        hero.position = CGPoint(x: size.width / 2, y: hero.size.height / 2 + 20.0)

        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.categoryBitMask    = PhysicsCategory.Hero.rawValue
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy.rawValue
        hero.physicsBody?.collisionBitMask   = PhysicsCategory.None.rawValue
        hero.physicsBody?.usesPreciseCollisionDetection = true

        addChild(hero)
        playerShip = hero

        // add hero animation action
        playerShip.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(playerAnimationTextures,
                timePerFrame: 0.15,
                resize: false,
                restore: true)),
            withKey:"playerFly")

        // load enemies animation atlas
        for i in 0..<enemyAnimationAtlas.textureNames.count {
            enemyAnimationTextures.append(enemyAnimationAtlas.textureNamed("\(i+1)"))
        }

        // load enemy explosion animation atlas
        for i in 0..<enemyExplosionAnimationAtlas.textureNames.count {
            enemyExplosionAnimationTextures.append(enemyExplosionAnimationAtlas.textureNamed("1_\(i)"))
        }

        updateEnemyAction()

        // world physics 
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        // create gun 
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(actionShot),
                SKAction.waitForDuration(0.1)
                ])
            ))
    }

    func updateEnemyAction() {

        let doubleLevel = NSTimeInterval(level)
        var duration = (0.1 * doubleLevel + 5.0) / (5 * doubleLevel)

        if duration < 0.1 {
            duration = 0.1
        }

        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addEnemy),
                SKAction.waitForDuration(duration)
            ])),
            withKey: "createEnemy")
    }

    // MARK: - 

    weak var scoreLabel: SKLabelNode!
    weak var levelLabel: SKLabelNode!

    weak var playerShip: SKSpriteNode!

    var score: Int = 0
    var level: Int = 1

    // MARK: Input

    var moveLeft:  Bool = false
    var moveRight: Bool = false

    var leftOff:  Bool = false
    var rightOff: Bool = false

    var leftRect: CGRect {
        return CGRect(x: 0, y: 0, width: size.width/2 - 50, height: 100)
    }

    var rightRect: CGRect {
        return CGRect(x: size.width/2 + 50, y: 0, width: size.width/2 - 50, height: 100)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {

            let location = touch.locationInNode(self)

            if leftRect.contains(location) {
                moveLeft = true

                if moveRight {
                    moveRight = false
                    rightOff  = true
                }
            }

            if rightRect.contains(location) {
                moveRight = true

                if moveLeft {
                    moveLeft = false
                    leftOff  = true
                }
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {

            let location = touch.locationInNode(self)

            if leftRect.contains(location) {
                moveLeft = false
                leftOff  = false

                if rightOff {
                    moveRight = true
                }
            }

            if rightRect.contains(location) {
                moveRight = false
                rightOff  = false

                if leftOff {
                    moveLeft = true
                }
            }
        }
    }

    let dx: CGFloat = 5.0

    func updateMoving() {

        if moveLeft && moveRight {
            return
        }

        var offsetX: CGFloat = 0

        if moveLeft {
            offsetX -= dx
        }

        if moveRight {
            offsetX += dx
        }

        var playerPosition = playerShip.position
        playerPosition.x += offsetX

        let minX = playerShip.size.width / 2 + 10
        let maxX = size.width - playerShip.size.width / 2 - 10

        if playerPosition.x < minX {
            playerPosition.x = minX
        }
        else if playerPosition.x > maxX {
            playerPosition.x = maxX
        }
        
        playerShip.position = playerPosition
    }
   
    override func update(currentTime: CFTimeInterval) {
        updateMoving()
    }

    // MARK: - Shoot 

    func actionShot() {

        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.5)

        let startPosition = CGPoint(x: playerShip.position.x, y: playerShip.position.y)
        let endPosition   = CGPoint(x: startPosition.x, y: size.height + bullet.size.height)

        bullet.position  = startPosition
        bullet.zPosition = playerShip.zPosition - 1

        // physics
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: bullet.size.width/3,
            height: bullet.size.height/2))
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask    = PhysicsCategory.Bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy.rawValue
        bullet.physicsBody?.collisionBitMask   = PhysicsCategory.None.rawValue
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        addChild(bullet)

        let actionMove     = SKAction.moveTo(endPosition, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()

        bullet.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }

    // MARK: - Add enemies

    var enemyAnimationAtlas = SKTextureAtlas(named: "EnemyAnimation")
    var enemyAnimationTextures: [SKTexture] = []

    func addEnemy() {

        // create
        let enemySize = CGSize(width: 40, height: 40)
        let enemy = SKSpriteNode(texture: enemyAnimationTextures[0], color: UIColor.clearColor(), size: enemySize)

        enemy.zRotation = CGFloat(M_PI)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemySize.width / 2)
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.categoryBitMask    = PhysicsCategory.Enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet.rawValue | PhysicsCategory.Hero.rawValue
        enemy.physicsBody?.collisionBitMask   = PhysicsCategory.None.rawValue

        // enemy animation action
        let animationAction = SKAction.animateWithTextures(enemyAnimationTextures, timePerFrame: 0.08, resize: false, restore: true)
        enemy.runAction(SKAction.repeatActionForever(animationAction))

        // calc random position
        let startX = random(min: enemy.size.width / 2,
                            max: size.width - enemy.size.width / 2)

        let endX   = random(min: enemy.size.width / 2,
                            max: size.width - enemy.size.width / 2)

        enemy.position = CGPoint(x: startX, y: size.height + enemy.size.height / 2)

        // add to scene
        addChild(enemy)

        // calc random speed
        var enemyMoveDuration = NSTimeInterval(12.0 * (1.0 / (Double(level) + 2.0)))

        if enemyMoveDuration < 3.0 {
            enemyMoveDuration = 3.0
        }

        // set actions
        let actionMove = SKAction.moveTo(CGPoint(x: endX, y: -enemy.size.height / 2),
            duration: enemyMoveDuration )

        let actionMoveDone = SKAction.removeFromParent()

        enemy.runAction(SKAction.sequence([
            actionMove,
            actionMoveDone
            ])
        )
    }

    // MARK: Random generator

    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    // MARK: - Collision detection 

    let enemyExplosionAnimationAtlas = SKTextureAtlas(named: "EnemyExplosionAnimation")
    var enemyExplosionAnimationTextures: [SKTexture] = []

    func bulletDidCollideWithEnemy(bullet: SKSpriteNode, enemy: SKSpriteNode) {

        // 1. play sound
        // 2. remove bullet
        // 3. add collapse animation over enemy
        // 4. when animation complete: remove enemy
        // 5. remove collapse

        // 2
        bullet.removeFromParent()

        // 3 
        let collapse = SKSpriteNode(texture: enemyExplosionAnimationTextures[0],
            color: UIColor.clearColor(), size: enemy.size)

        collapse.setScale( random(min: 2, max: 3.5) )
        collapse.position  = enemy.position
        collapse.zPosition = enemy.zPosition + 1
        collapse.zRotation = random(min: 0.0, max: 1.0) * CGFloat(2 * M_PI)

        addChild(collapse)

        enemy.removeFromParent()

        let animationAction = SKAction.animateWithTextures(enemyExplosionAnimationTextures,
            timePerFrame: 0.058, resize: false, restore: true)

        collapse.runAction(SKAction.sequence([
            animationAction,
            SKAction.removeFromParent()
            ]))

        // update score

        if level > 5 {
            score += 5
        }
        else if level > 10 {
            score += 3
        }
        else if level > 20 {
            score += 1
        }
        else {
            score += 10
        }

        // update level
        if score % 200 == 0 {
            level += 1
            updateEnemyAction()
        }

        // update UI
        scoreLabel.text = "Score: \(score)"
        levelLabel.text = "Level: \(level)"

        scoreLabel.position = CGPoint(x: scoreLabel.frame.width/2 + 20, y: scoreLabel.position.y)
        levelLabel.position = CGPoint(x: size.width - levelLabel.frame.width/2 - 20, y: levelLabel.position.y)
    }

    func enemy(enemy enemy: SKSpriteNode, didCollideWithHero hero: SKSpriteNode) {

        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }

        let collapse = SKSpriteNode(texture: enemyExplosionAnimationTextures[0],
            color: UIColor.clearColor(), size: enemy.size)

        collapse.setScale( random(min: 4, max: 5) )
        collapse.position  = playerShip.position
        collapse.zPosition = max(playerShip.zPosition, enemy.zPosition) + 1
        collapse.zRotation = random(min: 0.0, max: 1.0) * CGFloat(2 * M_PI)

        addChild(collapse)

        enemy.removeFromParent()

        let animationAction = SKAction.animateWithTextures(enemyExplosionAnimationTextures,
            timePerFrame: 0.058, resize: false, restore: true)

        collapse.runAction(SKAction.sequence([
            animationAction,
            SKAction.removeFromParent()
            ]))

        runAction(SKAction.sequence([
            SKAction.waitForDuration(2.0),
            loseAction
            ])
        )
    }

    // MARK: SKPhysicsContactDelegate

    func didBeginContact(contact: SKPhysicsContact) {

        print("a = \(contact.bodyA.categoryBitMask)")
        print("b = \(contact.bodyB.categoryBitMask)")

        if contact.bodyA.categoryBitMask == UInt32.max || contact.bodyB.categoryBitMask == UInt32.max {
            print("category bit mask = all")
            return
        }

        guard let aCategory = PhysicsCategory(rawValue: contact.bodyA.categoryBitMask) else {
            fatalError("aaaa")
        }

        guard let bCategory = PhysicsCategory(rawValue: contact.bodyB.categoryBitMask) else {
            fatalError("bbb")
        }

        switch aCategory {

            // bullet & enemy
        case .Bullet where bCategory == .Enemy:
            print("bullet & enemy")

            if let aNode = contact.bodyA.node as? SKSpriteNode {

                if let bNode = contact.bodyB.node as? SKSpriteNode {
                    bulletDidCollideWithEnemy(aNode, enemy: bNode)
                }
            }

        case .Enemy  where bCategory == .Bullet:
            print("enemy & bullet")

            if let aNode = contact.bodyA.node as? SKSpriteNode {

                if let bNode = contact.bodyB.node as? SKSpriteNode {
                    bulletDidCollideWithEnemy(bNode, enemy: aNode)
                }
            }

        case .Enemy where bCategory == .Rocket:
            print("enemy & rocket")

        case .Rocket where bCategory == .Enemy: // enemy & rocket
            print("rocket & enemy")

        case .Hero where bCategory == .Enemy:
            print("hero & enemy")

            if let aNode = contact.bodyA.node as? SKSpriteNode {
                if let bNode = contact.bodyB.node as? SKSpriteNode {
                    enemy(enemy: bNode, didCollideWithHero: aNode)
                }
            }

        case .Enemy where bCategory == .Hero:  // hero & enemy
            print("enemy & hero")

            if let aNode = contact.bodyA.node as? SKSpriteNode {
                if let bNode = contact.bodyB.node as? SKSpriteNode {
                    enemy(enemy: aNode, didCollideWithHero: bNode)
                }
            }

        case .Enemy where bCategory == .Enemy: // enemy & enemy
            print("enemy & enemy")

        default: // untracked
            return
        }
    }

    func didEndContact(contact: SKPhysicsContact) {

    }
}














