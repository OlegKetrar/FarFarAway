//
//  GameScene.swift
//  FarFarAway
//
//  Created by Oleg Ketrar on 20.03.16.
//  Copyright (c) 2016 Oleg Ketrar. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 /*, RawRepresentable */ {

    case None   = 0

    case Hero   = 0b0001
    case Enemy  = 0b0010
    case Bullet = 0b0100
    case Rocket = 0b1000
}

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
        someLabel.fontSize  = 20
        someLabel.fontColor = labelColor
        someLabel.position  = CGPoint(x: someLabel.frame.width/2 + 20, y: someLabel.frame.height/2 + 20)

        addChild(someLabel)
        scoreLabel = someLabel

        let someLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        someLevelLabel.fontSize  = 20
        someLevelLabel.fontColor = labelColor
        someLevelLabel.position  = CGPoint(x: size.width - someLevelLabel.frame.width/2 + 20,
            y: size.height - someLevelLabel.frame.height/2 + 20)

        addChild(someLevelLabel)
        levelLabel = someLevelLabel

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
                SKAction.waitForDuration(0.2)
                ])
            ))
    }

    func updateEnemyAction() {

        let doubleLevel = NSTimeInterval(level)
        var duration = (0.2 * doubleLevel + 1.0) / doubleLevel

        if duration < 0.3 {
            duration = 0.3
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
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

        if enemyMoveDuration < 2.0 {
            enemyMoveDuration = 2.0
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

        addChild(collapse)

        enemy.removeFromParent()

        let animationAction = SKAction.animateWithTextures(enemyExplosionAnimationTextures,
            timePerFrame: 0.058, resize: false, restore: true)

        collapse.runAction(SKAction.sequence([
            animationAction,
            SKAction.removeFromParent()
            ]))

        // update score
        score += 10

        // update level
        if score % 200 == 0 {
            level += 1
            updateEnemyAction()
        }

        // update UI
        scoreLabel.text = "Score: \(score)"
        levelLabel.text = "Level: \(level)"
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

        case .Enemy where bCategory == .Hero:  // hero & enemy
            print("enemy & hero")

        case .Enemy where bCategory == .Enemy: // enemy & enemy
            print("enemy & enemy")

        default: // untracked
            return
        }
    }

    func didEndContact(contact: SKPhysicsContact) {

    }
}














