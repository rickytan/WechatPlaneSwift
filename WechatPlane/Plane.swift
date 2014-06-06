//
//  Plane.swift
//  WechatPlane
//
//  Created by ricky on 14-6-6.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

import Foundation
import SpriteKit

class Plane : SKSpriteNode {
    var _planeType = 0
    var _hp = 0
    var _speed = 0
}

enum propsType : Int {
    case propsTypeBomb      = 4
    case propsTypeBullet    = 5
}

class Props : SKNode {
    var _type: propsType
    var _prop: SKSpriteNode
    init(type: propsType) {
        _type = type

        var key = "enemy\(_type.toRaw())_fly_1.png"
        _prop = SKSpriteNode(texture: TextureCache.sharedCache().textureByName(key))
        _prop.position = CGPointMake(CGFloat(arc4random() % 268 + 23), 732)

        super.init()
    }

    func propAnimation() {
        var act1 = SKAction.moveToY(400, duration: 1.0)
        var act2 = SKAction.moveToY(402, duration: 0.1)
        var act3 = SKAction.moveToY(732, duration: 1.0)
        var act4 = SKAction.moveToY(-55, duration: 2.0)

        _prop.runAction(SKAction.sequence([act1, act2, act3, act4]))
    }
}