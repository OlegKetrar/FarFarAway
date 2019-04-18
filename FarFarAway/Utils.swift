//
//  Utils.swift
//  FarFarAway
//
//  Created by Oleg Ketrar on 20.03.16.
//  Copyright © 2016 Oleg Ketrar. All rights reserved.
//

import Foundation
import QuartzCore

// MARK: Physics

enum PhysicsCategory: UInt32 {

    case None   = 0

    case Hero   = 0b0001
    case Enemy  = 0b0010
    case Bullet = 0b0100
    case Rocket = 0b1000
}

// MARK: Vector math

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {

    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }

    func normalized() -> CGPoint {
        return self / length()
    }
}
