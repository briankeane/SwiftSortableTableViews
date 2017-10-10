//
//  NSViewExtention.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/8/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

//extension CGRect
//{
//    func calculatedCenter() -> CGPoint?
//    {
//        return CGPointMake(NSMidX(self.frame), NSMidY(self.frame))
//    }
//}

extension NSView
{
    func setFrameCenter(_ center:CGPoint)
    {
        let centerX = center.x - self.frame.height/2
        let centerY = center.y - self.frame.width/2
        self.frame.origin = CGPoint(x: centerX, y: centerY)
    }

    var snapshot: NSImage {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage()
        image.addRepresentation(bitmapRep)
        bitmapRep.size = bounds.size.doubleScale()
        return image
    }
}

extension CGSize {
    func doubleScale() -> CGSize {
        return CGSize(width: width * 2, height: height * 2)
    }
}

extension CGRect {
    func originFromCenter(center: CGPoint) -> CGPoint
    {
        let originX = center.x - self.width/2
        let originY = center.y - self.height/2
        return CGPoint(x: originX, y: originY)
    }
}
