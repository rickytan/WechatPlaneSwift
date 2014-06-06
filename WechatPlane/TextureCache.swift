//
//  TexuteCache.swift
//  WechatPlane
//
//  Created by ricky on 14-6-4.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

import Foundation
import SpriteKit

var _textureCache: TextureCache?;

class TextureCache: NSObject {
    var nameDic = NSMutableDictionary()
    var _loadedFilenames = NSMutableSet()
    var _spriteFrames = NSMutableDictionary()
    var _spriteFramesAliases = NSMutableDictionary();

    init() {
        super.init();
    }
    class func sharedCache() -> TextureCache! {
        if _textureCache == nil {
            _textureCache = TextureCache();
        }
        return _textureCache;
    }

    func addTexture(plistFileName: String) {
        if !_loadedFilenames.member(plistFileName) {
            var fullPath = NSBundle.mainBundle().resourcePath.stringByAppendingPathComponent(plistFileName)
            var dict = NSDictionary(contentsOfFile: fullPath)

            var pngFileName = plistFileName.stringByDeletingPathExtension.stringByAppendingPathExtension("png")
            var texture = UIImage(named: pngFileName)
            addSpriteFramesWithDictionary(dict, texture: texture)

            _loadedFilenames.addObject(plistFileName)
        }
    }

    func addSpriteFramesWithDictionary(dictionary: NSDictionary, texture: UIImage) {
        var metadataDict: NSDictionary! = dictionary.valueForKey("metadata") as NSDictionary
        var framesDict = dictionary.valueForKey("frames") as NSDictionary
        var format = 0
        if metadataDict {
            format = metadataDict.objectForKey("format") as Int
        }

        assert(format >= 0 && format <= 3, "format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:")
        assert(format == 3, "Only support type 3!");
        // SpriteFrame info
        var rectInPixels = CGRect();
        var isRotated = false;
        var frameOffset = CGPoint();
        var originalSize = CGSize();

        for (frameDictKey : AnyObject, frameDict : AnyObject) in framesDict {
            var spriteSize = CGSizeFromString(frameDict["spriteSize"] as String)
            var spriteOffset = CGPointFromString(frameDict["spriteOffset"] as String)
            var spriteSourceSize = CGSizeFromString(frameDict["spriteSourceSize"] as String)
            var textureRect = CGRectFromString(frameDict["textureRect"] as String)
            var textureRotated = frameDict["textureRotated"] as Bool

            // get aliases
            var aliases = frameDict["aliases"]
            for alias in aliases {
                _spriteFramesAliases[alias] = frameDict
            }
            
            // set frame info
            rectInPixels = CGRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height)
            isRotated = textureRotated
            frameOffset = spriteOffset
            originalSize = spriteSourceSize

            UIGraphicsBeginImageContext(rectInPixels.size)
            texture.drawAtPoint(CGPointMake(
                -rectInPixels.origin.x,
                -rectInPixels.origin.y))
            var subImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            UIGraphicsBeginImageContext(originalSize)
            var context = UIGraphicsGetCurrentContext()
            if isRotated {
                CGContextRotateCTM(context, CGFloat(0.5 * M_PI))
            }
            subImage.drawAtPoint(frameOffset)
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var tex = SKTexture(image: image)
            _spriteFrames[frameDictKey as String] = tex
        }
    }

    func textureByName(name: String) -> SKTexture {
        var tex = _spriteFrames[name] as SKTexture!
        if !tex {
            var key = _spriteFramesAliases[name] as String
            tex = _spriteFrames[key] as SKTexture
        }
        return tex
    }
}