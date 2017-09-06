//
//  SortableTableViewHandler.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/5/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

public class SortableTableViewHandler:NSObject
{
    public var sortableTableViews:Array<SortableTableView> = Array()
    public var containingView:UIView!
    
    public var itemInMotion:SortableTableViewItem?
    
    public init(view:UIView, sortableTableViews:Array<SortableTableView>?=nil)
    {
        super.init()
        if let sortableTableViews = sortableTableViews
        {
            self.sortableTableViews = sortableTableViews
        }
        self.containingView = view
        self.setupGestureRecognizer()
    }
    
    //------------------------------------------------------------------------------
    
    func sortableTableViewAtPoint(_ pointPressed:CGPoint) -> SortableTableView?
    {
        for sortableTableView in self.sortableTableViews
        {
            if sortableTableView.frame.contains(pointPressed)
            {
                return sortableTableView
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    open func setupGestureRecognizer()
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SortableTableViewHandler.screenLongPressed(_:)))
        longPress.minimumPressDuration = 0.3
        self.containingView.addGestureRecognizer(longPress)
    }
    
    //------------------------------------------------------------------------------
    
    @objc func screenLongPressed(_ gestureRecognizer:UILongPressGestureRecognizer)
    {
        let longPress = gestureRecognizer
        let pressedLocationInParentView = longPress.location(in: self.containingView)
        let tableViewPressed = self.sortableTableViewAtPoint(pressedLocationInParentView)
        
        switch longPress.state
        {
        case .began:
            if let tableViewPressed = tableViewPressed
            {
                self.handleLongPressBegan(longPress:longPress, sortableTableViewPressed:tableViewPressed)
            }
            
        case .changed:
            if let _ = self.itemInMotion
            {
                self.moveCellSnapshot(pressedLocationInParentView, disappear: false)
            }
            
//        case .ended:
//            self.cancelMove()
//            //            self.handleDroppedItem(tableViewPressed, longPress:longPress)
//            print("ended")
        default:
            print("default")
        }
    }
    
    //------------------------------------------------------------------------------
    
    func handleLongPressBegan(longPress:UILongPressGestureRecognizer, sortableTableViewPressed:SortableTableView)
    {
        let pointInTableView = longPress.location(in: sortableTableViewPressed)
        let pressedIndexPath = sortableTableViewPressed.indexPathForRow(at: pointInTableView)
        if let pressedIndexPath = pressedIndexPath
        {
            if (sortableTableViewPressed.canBePickedUp(indexPath: pressedIndexPath))
            {
                self.pickupCell(atIndexPath: pressedIndexPath, longPress: longPress, sortableTableViewPressed: sortableTableViewPressed)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func pickupCell(atIndexPath:IndexPath, longPress:UILongPressGestureRecognizer, sortableTableViewPressed:SortableTableView)
    {
        if let cell = sortableTableViewPressed.cellForRow(at: atIndexPath)
        {
            let cellSnapshot = self.createCellSnapshot(cell)
            self.itemInMotion = SortableTableViewItem(originalTableView: sortableTableViewPressed, originalIndexPath: atIndexPath, originalCenter: cellSnapshot.center, cellSnapshot: cellSnapshot)
            cellSnapshot.center = self.containingView.convert(cell.center, from: sortableTableViewPressed)
            cellSnapshot.alpha = 0.0
            self.containingView.addSubview(cellSnapshot)
            
            UIView.animate(withDuration: 0.25, animations:
            {
                cellSnapshot.center = CGPoint(x: sortableTableViewPressed.center.x, y: longPress.location(in: self.containingView).y)
                cellSnapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                cellSnapshot.alpha = 0.98
            },
            completion:
            {
                (finished) -> Void in
                if (finished)
                {
                    //broadcast that item pickup has been animated
                   NotificationCenter.default.post(name: SortableTableViewEvents.pickupAnimated, object: nil, userInfo: ["originalTableView":sortableTableViewPressed,
                        "originalIndexPath": atIndexPath])
                }
            })
        }
    }
    
    func moveCellSnapshot(_ newCenter:CGPoint, disappear:Bool, onCompletion:@escaping (Bool) -> Void = {Void in })
    {
        if let cellSnapshot = self.itemInMotion?.cellSnapshot
        {
            UIView.animate(withDuration: 0.25,
                           animations:
            {
                cellSnapshot.center = CGPoint(x: self.containingView.center.x, y: newCenter.y)
                    
                if (disappear == true)
                {
                    cellSnapshot.transform = CGAffineTransform.identity
                    cellSnapshot.alpha = 0.0
                }
            },
            completion:
            {
                (finished) -> Void in
                if (disappear == true)
                {
                    cellSnapshot.removeFromSuperview()
                    self.itemInMotion = nil
                }
                onCompletion(finished)
            })
        }
    }
    //------------------------------------------------------------------------------
    
    func createCellSnapshot(_ inputView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}
