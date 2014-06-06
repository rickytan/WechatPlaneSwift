//
//  GameScene.swift
//  WechatPlane
//
//  Created by ricky on 14-6-4.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

import SpriteKit
import Foundation
import Swift

class GameScene: SKScene {
    let windowHeight = UIScreen.mainScreen().bounds.size.height

    var BG1 = SKSpriteNode()
    var BG2 = SKSpriteNode()

    // 分数
    var scoreLabel = SKLabelNode()
    var score = 0
    var adjustmentBg = 568

    // 玩家飞机
    var player = SKSpriteNode()
    // 子弹
    var bullet = SKSpriteNode()
    // 子弹数量
    var bulletSum = 0
    // 子弹样式
    var isBigBullet = false
    var isChangeBullet = false
    // 子弹速度
    var bulletSpeed = 25
    // 特殊子弹时间
    var bulletTiming = 900

    // 敌方飞机
    var foePlanes = NSMutableArray()

    // 添加飞机时机
    var bigPlan = 0
    var smallPlan = 0
    var mediumPlan = 0

    // 道具
    var prop: Props?
    // 添加道具时机
    var props = 0
    // 是否存在
    var isVisible = false

    var gameOverLabel: SKLabelNode?
    var restart: SKLabelNode?
    var isGameOver = false

    init(size: CGSize) {
        adjustmentBg = Int(windowHeight)
        TextureCache.sharedCache().addTexture("gameArts.plist")
        super.init(size: size)
    }

    func madeBullet() {

        bullet = SKSpriteNode(texture: TextureCache.sharedCache().textureByName(!isBigBullet ? "bullet1.png": "bullet2.png"))
        bullet.anchorPoint=CGPointMake(0.5,0.5);
        addChild(bullet)
    }

    func resetBullet() {

        if (isBigBullet && isChangeBullet) || (!isBigBullet && isChangeBullet) {
            bullet.removeFromParent()
            madeBullet()
            isChangeBullet = false;
        }

        bulletSpeed = Int(460 - (player.position.y + 50)) / 15;
        if bulletSpeed < 5 {
            bulletSpeed = 5
        }
        bullet.position = CGPointMake(player.position.x,player.position.y+50);
    }

    func gameRestart() {
        self.removeAllChildren()

        BG1 = SKSpriteNode(texture: TextureCache.sharedCache().textureByName("background_2.png"))
        BG1.anchorPoint = CGPointMake(0.5, 1)
        BG1.position = CGPointMake(160, Float(adjustmentBg))

        BG2 = SKSpriteNode(texture: TextureCache.sharedCache().textureByName("background_2.png"))
        BG2.anchorPoint = CGPointMake(0.5, 1)
        BG2.position = CGPointMake(160, Float(adjustmentBg) + 568)

        scoreLabel = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.fontSize = 18
        scoreLabel.position = CGPointMake(40, windowHeight - 40)
        scoreLabel.zPosition = 4
        scoreLabel.text = "0000"

        player = SKSpriteNode(texture: TextureCache.sharedCache().textureByName("hero_fly_1.png"))
        player.position = CGPointMake(160, 50)
        var playerActionArray = [
            TextureCache.sharedCache().textureByName("hero_fly_1.png"),
            TextureCache.sharedCache().textureByName("hero_fly_2.png")]
        player.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerActionArray, timePerFrame: 0.1)))

        bullet = SKSpriteNode(texture: TextureCache.sharedCache().textureByName(!isBigBullet ? "bullet1.png": "bullet2.png"))
        bullet.anchorPoint=CGPointMake(0.5,0.5);


        addChild(BG1)
        addChild(BG2)
        addChild(scoreLabel)
        addChild(player)
        addChild(bullet)

        foePlanes.removeAllObjects()
        madeBullet()
        resetBullet()
        score = 0
        scoreLabel.text = "0000"
        isGameOver = false
    }

    func boundLayerPos(newPos: CGPoint) -> CGPoint {
        var retval = newPos
        retval.x = player.position.x + newPos.x
        retval.y = player.position.y + newPos.y

        if retval.x >= 286 {
            retval.x = 286
        } else if retval.x <= 33 {
            retval.x = 33
        }

        if retval.y >= windowHeight - 50 {
            retval.y = windowHeight - 50
        } else if retval.y <= 43 {
            retval.y = 43
        }

        return retval;
    }

    override func didMoveToView(view: SKView) {
        gameRestart()
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var touchLocation = touch.locationInNode(self)
        var oldTouchLocation = touch.previousLocationInNode(self)
        var translation = CGPointMake(
            touchLocation.x - oldTouchLocation.x,
        touchLocation.y - oldTouchLocation.y);
        if !isGameOver {
            player.position = boundLayerPos(translation)
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !isGameOver {
            return
        }

        var touch = touches.anyObject() as UITouch
        var touchLocation = touch.locationInNode(self)
        if CGRectContainsPoint(restart!.frame, touchLocation) {
            gameRestart()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (!isGameOver) {
            backgrouneScroll()
            firingBullets()
            addFoePlane()
            moveFoePlane()
            collisionDetection()
            makeProps()
            bulletTimingUpdate()
        }
    }

    func makeProps() {
        props++
        if props > 1520 {
            prop = Props(type: (arc4random() % 2) == 0 ? propsType.propsTypeBomb : propsType.propsTypeBullet)
            addChild(prop!._prop)
            prop!.propAnimation()
            props = 0;
            isVisible = true;
        }
        
    }

    func bulletTimingUpdate() {
        if isBigBullet {
            if bulletTiming > 0 {
                bulletTiming--
            }
            else {
                isBigBullet = false
                isChangeBullet = true
                bulletTiming = 900
            }
        }
    }

    // 造大飞机
    func makeBigFoePlane() -> Plane {
        var bigFoePlane = Plane(texture: TextureCache.sharedCache().textureByName("enemy2_fly_1.png"))
        bigFoePlane.position = CGPointMake(CGFloat(Int(arc4random() % 210) + 55), 732)
        var playerActionArray = [
            TextureCache.sharedCache().textureByName("enemy2_fly_1.png"),
            TextureCache.sharedCache().textureByName("enemy2_fly_2.png")]
        bigFoePlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerActionArray, timePerFrame: 0.1)))
        bigFoePlane._hp = 30
        bigFoePlane._planeType = 2
        bigFoePlane._speed = Int(arc4random() % 2) + 2
        return bigFoePlane;
    }

    // 造中飞机
    func makeMediumFoePlane() -> Plane {
        var bigFoePlane = Plane(texture: TextureCache.sharedCache().textureByName("enemy3_fly_1.png"))
        bigFoePlane.position = CGPointMake(CGFloat(Int(arc4random() % 268) + 23), 732)
        bigFoePlane._hp = 15
        bigFoePlane._planeType = 3
        bigFoePlane._speed = Int(arc4random() % 3) + 2
        return bigFoePlane;
    }

    // 造小飞机
    func makeSmallFoePlane() -> Plane {
        var bigFoePlane = Plane(texture: TextureCache.sharedCache().textureByName("enemy1_fly_1.png"))
        bigFoePlane.position = CGPointMake(CGFloat(Int(arc4random() % 240) + 17), 732)
        bigFoePlane._hp = 1
        bigFoePlane._planeType = 1
        bigFoePlane._speed = Int(arc4random() % 4) + 2
        return bigFoePlane;
    }

    func addFoePlane() {
        bigPlan++;
        smallPlan++;
        mediumPlan++;

        if (bigPlan > 500) {
            var foePlane = makeBigFoePlane()
            foePlane.zPosition = 3
            addChild(foePlane)
            foePlanes.addObject(foePlane)
            bigPlan = 0;
        }

        if (mediumPlan>400) {
            var foePlane = makeMediumFoePlane()
            foePlane.zPosition = 3
            addChild(foePlane)
            foePlanes.addObject(foePlane)
            mediumPlan = 0;
        }

        if (smallPlan>45) {
            var foePlane = makeSmallFoePlane()
            foePlane.zPosition = 3
            addChild(foePlane)
            smallPlan = 0;
        }

    }

    func moveFoePlane() {
        var i = 0
        for _ in foePlanes {
            var foePlane = foePlanes[i] as Plane
            foePlane.position = CGPointMake(foePlane.position.x, foePlane.position.y - foePlane.speed)
            if foePlane.position.y < -75 {
                foePlanes.removeObject(foePlane)
                foePlane.removeFromParent()
            }
        }
    }

    func firingBullets() {
        bullet.position = CGPointMake(bullet.position.x, bullet.position.y + CGFloat(bulletSpeed))

        if (bullet.position.y > windowHeight - 20) {
            resetBullet()
        }
    }

    func backgrouneScroll() {
        adjustmentBg--

        if (adjustmentBg <= 0) {
            adjustmentBg = 568
        }

        BG1.position = CGPointMake(160, Float(adjustmentBg))
        BG2.position = CGPointMake(160, Float(adjustmentBg) + 568)
    }

    func loadResources() -> NSDictionary {
        return NSDictionary(contentsOfFile: "gameArts-hd.plist");
    }

    func collisionDetection() {
        // 子弹跟敌机
        var bulletRec = bullet.frame;
        for var i=0; i < foePlanes.count; ++i {
            var foePlane = foePlanes[i] as Plane

            if (CGRectIntersectsRect(bulletRec, foePlane.frame)) {
                resetBullet()
                fowPlaneHitAnimation(foePlane)
                foePlane._hp = foePlane._hp - (isBigBullet ? 2 : 1)
                if (foePlane._hp <= 0) {
                    fowPlaneBlowupAnimation(foePlane)
                    foePlanes.removeObject(foePlane)
                }
            }
        }

        // 飞机跟打飞机
        var playerRec = player.frame;
        playerRec.origin.x += 25;
        playerRec.size.width -= 50;
        playerRec.origin.y -= 10;
        playerRec.size.height -= 10;
        for var i=0; i < foePlanes.count; ++i {
            var foePlane = foePlanes[i] as Plane
            if (CGRectIntersectsRect(playerRec, foePlane.frame)) {
                gameOver()
                playerBlowupAnimation()
                fowPlaneBlowupAnimation(foePlane)
                foePlanes.removeObject(foePlane)
            }
        }

        // 飞机跟道具

        if (isVisible) {
            var playerRec1 = player.frame;
            var propRec = prop!._prop.frame;
            if (CGRectIntersectsRect(playerRec1, propRec)) {
                prop!._prop.removeAllActions()
                prop!._prop.removeFromParent()
                isVisible = false

                if (prop!._type == propsType.propsTypeBullet) {
                    isBigBullet = true;
                    isChangeBullet = true;
                }else if (prop!._type == propsType.propsTypeBomb) {
                    for var i=0; i < foePlanes.count; ++i {
                        var foePlane = foePlanes[i] as Plane
                        fowPlaneBlowupAnimation(foePlane)
                    }
                    foePlanes.removeAllObjects()
                }
            }
        }
    }

    func fowPlaneHitAnimation(foePlane: Plane) {
        if (foePlane._planeType == 3) {
            if (foePlane._hp == 13) {
                var playerActionArray = [
                    TextureCache.sharedCache().textureByName("enemy3_hit_1.png"),
                    TextureCache.sharedCache().textureByName("enemy3_hit_2.png")]
                foePlane.removeAllActions()
                foePlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerActionArray, timePerFrame: 0.1)))
            }
        } else if (foePlane._planeType == 2) {
            if (foePlane._hp==20) {
                var playerActionArray = [
                    TextureCache.sharedCache().textureByName("enemy2_hit_1.png")]
                foePlane.removeAllActions()
                foePlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerActionArray, timePerFrame: 0.1)))
            }
        }
    }

    // 爆炸动画
    func fowPlaneBlowupAnimation(foePlane: Plane) {
        var forSum = 0
        if (foePlane._planeType == 3) {
            forSum = 4;
            score+=6000;
        }else if (foePlane._planeType  == 2) {
            score+=30000;
            forSum = 7;
        }else if (foePlane._planeType  == 1) {
            forSum = 4;
            score+=1000;
        }

        scoreLabel.text = "\(score)"

        foePlane.removeAllActions()

        var foePlaneActionArray = NSMutableArray()

        for var i = 1; i <= forSum; i++ {
            var key = "enemy\(foePlane._planeType)_blowup_\(i).png"
            //从内存池中取出Frame
            var tex = TextureCache.sharedCache().textureByName(key)
            //添加到序列中
            foePlaneActionArray.addObject(tex)
        }
        foePlane.runAction(SKAction.sequence([
            SKAction.animateWithTextures(foePlaneActionArray, timePerFrame: 0.1),
            SKAction.runBlock({foePlane.removeFromParent()})]
            ))
    }

    func gameOver() {

        isGameOver = true
        for var i=0; i < self.children.count; ++i {
            var node = self.children[i] as SKNode
            node.removeAllActions()
        }

        gameOverLabel = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        gameOverLabel!.text = "GameOver"
        gameOverLabel!.position = CGPointMake(160, 300)
        gameOverLabel!.zPosition = 4
        addChild(gameOverLabel)

        restart = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        restart!.text = "restart"
        restart!.fontSize = 30
        restart!.fontColor = UIColor.whiteColor()
        restart!.position = CGPointMake(160, 200)
        restart!.zPosition = 4
        addChild(restart)
    }

    func playerBlowupAnimation() {
        var foePlaneActionArray = SKTexture[]()

        for var i = 1; i <= 4; i++ {
            var key = "hero_blowup_\(i).png"
            //从内存池中取出Frame
            var frame = TextureCache.sharedCache().textureByName(key)
            //添加到序列中
            foePlaneActionArray += frame
        }
        player.runAction(SKAction.animateWithTextures(foePlaneActionArray, timePerFrame: 0.1))
    }
}
