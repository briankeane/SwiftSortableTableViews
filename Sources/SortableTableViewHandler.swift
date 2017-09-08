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
                
                // IF hovering has changed at all
                if (self.hoveringHasChanged(longPress: longPress))
                {
                    let oldHoveredOverTableView = self.itemInMotion?.hoveredOverTableView
                    
                    self.itemInMotion?.hoveredOverIndexPath = tableViewPressed?.indexPathForRow(at: (tableViewPressed!.convert(pressedLocationInParentView, from: self.containingView)))
                    self.itemInMotion?.hoveredOverTableView = tableViewPressed
                    
                    // IF a tableView was exited:
                    if let exitedTableView = self.itemExitedTableView(oldTableView: oldHoveredOverTableView, newTableView: tableViewPressed)
                    {
                        exitedTableView.onItemExited()
                    }
                    
                    // IF a tableView was entered:
                    if let enteredTableView = self.itemEnteredTableView(oldTableView: oldHoveredOverTableView, newTableView: tableViewPressed)
                    {
                        if let hoveredOverIndexPath = self.itemInMotion?.hoveredOverIndexPath
                        {
                            enteredTableView.onItemEntered(atIndexPath: hoveredOverIndexPath)
                        }
                        
                    }
                    
                    // IF the hoveredOver cell changed within the tableView
                    if let activeTableView = self.indexPathChangedWithinTableView(oldTableView: oldHoveredOverTableView, newTableView: tableViewPressed)
                    {
                        if let hoveredOverIndexPath = self.itemInMotion?.hoveredOverIndexPath
                        {
                            activeTableView.onItemMovedWithin(newIndexPath: hoveredOverIndexPath)
                        }
                    }
                }
            }
        case .ended:
            self.handleLongPressEnded(longPress: longPress)
            print("ended")
        default:
            print("default")
        }
    }
    
    func itemExitedTableView(oldTableView:SortableTableView?, newTableView:SortableTableView?) -> SortableTableView?
    {
        if (oldTableView != newTableView)
        {
            return oldTableView
        }
        return nil
    }
    
    func itemEnteredTableView(oldTableView:SortableTableView?, newTableView:SortableTableView?) -> SortableTableView?
    {
        if (oldTableView != newTableView)
        {
            return newTableView
        }
        return nil
    }
    
    func indexPathChangedWithinTableView(oldTableView:SortableTableView?, newTableView:SortableTableView?) -> SortableTableView?
    {
        if ((oldTableView == newTableView))
        {
            return oldTableView
        }
        return nil
    }
    
    
    
    //------------------------------------------------------------------------------
    
    func handleLongPressEnded(longPress:UILongPressGestureRecognizer)
    {
        let pressedLocationInParentView = longPress.location(in: self.containingView)
        let tableViewPressed = self.sortableTableViewAtPoint(pressedLocationInParentView)
        var pressedIndexPath:IndexPath?
        if let tableViewPressed = tableViewPressed
        {
            let pointInTableView = longPress.location(in: tableViewPressed)
            pressedIndexPath = tableViewPressed.indexPathForRow(at: pointInTableView)
        }
        
        if let itemInMotion = self.itemInMotion
        {
            // IF released over nothing
            if ((tableViewPressed == nil) || (pressedIndexPath == nil))
            {
                self.cancelMove()
            }
            // ELSE IF denied by either SortableTable delegate
            else if (!self.canBeReleased(itemInMotion.originalTableView, originalIndexPath: itemInMotion.originalIndexPath, desiredIndexPath: pressedIndexPath!, receivingTableView: tableViewPressed!))
            {
                self.cancelMove()
            }
            // ELSE OK to Drop!
            else
            {
                // if moving within the same tableView
                if (tableViewPressed! == itemInMotion.originalTableView)
                {
                    // call move delegate
                    tableViewPressed!.sortableDataSource?.sortableTableView(tableViewPressed!, willDropItem: itemInMotion.originalIndexPath, newIndexPath: pressedIndexPath!)
                    
                    
                    // animate drop
                    let newCell = tableViewPressed!.cellForRow(at: pressedIndexPath!)
                    let newCenter = newCell!.center
                    let newCenterInContainerView = self.containingView.convert(newCenter, from: tableViewPressed!)
                    
                    tableViewPressed!.onDropItemIntoTableView(atIndexPath: pressedIndexPath!)
                    NotificationCenter.default.post(name: SortableTableViewEvents.dropItemWillAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                                                                                                                              "originalIndexPath": itemInMotion.originalIndexPath,
                                                                                                                              "newTableView": tableViewPressed!,
                                                                                                                              "newIndexPath": pressedIndexPath!])
                    self.moveCellSnapshot(newCenterInContainerView, disappear: true, onCompletion:
                    {
                        (finished) in
                        NotificationCenter.default.post(name: SortableTableViewEvents.dropItemDidAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                                                                                                                                  "originalIndexPath": itemInMotion.originalIndexPath,
                                                                                                                                  "newTableView": tableViewPressed!,
                                                                                                                                  "newIndexPath": pressedIndexPath!])
                    })
                }
                // ELSE dropping from one table to another
                else
                {
                    // call delegate functions
                    tableViewPressed?.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, willReleaseItem: itemInMotion.originalIndexPath, newIndexPath: pressedIndexPath!, receivingTableView: tableViewPressed!)
                    itemInMotion.originalTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, willReceiveItem: itemInMotion.originalIndexPath, newIndexPath: pressedIndexPath!, receivingTableView: tableViewPressed!)
                    
                    
                    let newCell = tableViewPressed!.cellForRow(at: pressedIndexPath!)
                    let newCenter = newCell!.center
                    let newCenterInContainerView = self.containingView.convert(newCenter, from: tableViewPressed!)
                    
                    tableViewPressed!.onDropItemIntoTableView(atIndexPath: pressedIndexPath!)
                    itemInMotion.originalTableView.onReleaseItemFromTableView()
                    
                    self.moveCellSnapshot(newCenterInContainerView, disappear: true, onCompletion:
                    {
                        (finished) in
                        NotificationCenter.default.post(name: SortableTableViewEvents.dropItemDidAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                                                                                                                                   "originalIndexPath": itemInMotion.originalIndexPath,
                                                                                                                                   "newTableView": tableViewPressed!,
                                                                                                                                   "newIndexPath": pressedIndexPath!])
                    })
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func canBeReleased(_ releasingTableView: SortableTableView, originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:SortableTableView) -> Bool
    {
        if let canBeReleased = releasingTableView.sortableDataSource?.sortableTableView?(releasingTableView, shouldReleaseItem: originalIndexPath, desiredIndexPath: desiredIndexPath, receivingTableView: receivingTableView)
        {
            if (canBeReleased == false)
            {
                return false
            }
        }
        if let canBeReceived = receivingTableView.sortableDataSource?.sortableTableView?(releasingTableView, shouldReceiveItem: originalIndexPath, desiredIndexPath: desiredIndexPath, receivingTableView: receivingTableView)
        {
            if (canBeReceived == false)
            {
                return false
            }
        }
        return true
    }
    
    //------------------------------------------------------------------------------
    
    func cancelMove()
    {
        if let itemInMotion = self.itemInMotion
        {
            // Notify so that tables can adjust
            NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveWillAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                 "originalIndexPath": itemInMotion.originalIndexPath,
                ])
            
            self.moveCellSnapshot(itemInMotion.originalCenter, disappear: true, onCompletion:
            {
                (finished) -> Void in
                if (finished)
                {
                    NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveDidAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                                                                                                                                "originalIndexPath": itemInMotion.originalIndexPath
                                                                                                                                ])
                }
            })
        }
    }
    
    //------------------------------------------------------------------------------
    
    func hoveringHasChanged(longPress:UILongPressGestureRecognizer) -> Bool
    {
        let pressedLocationInParentView = longPress.location(in: self.containingView)
        let tableViewPressed = self.sortableTableViewAtPoint(pressedLocationInParentView)
        var pressedIndexPath:IndexPath?
        if let tableViewPressed = tableViewPressed
        {
            let pointInTableView = longPress.location(in: tableViewPressed)
            pressedIndexPath = tableViewPressed.indexPathForRow(at: pointInTableView)
        }
        
        return ((self.itemInMotion?.hoveredOverTableView != tableViewPressed) ||
                (self.itemInMotion?.hoveredOverIndexPath != pressedIndexPath))
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
            self.itemInMotion = SortableTableViewItem(originalTableView: sortableTableViewPressed, originalIndexPath: atIndexPath, originalCenter: self.containingView.convert(cell.center, from: sortableTableViewPressed), cellSnapshot: cellSnapshot)
            cellSnapshot.center = self.containingView.convert(cell.center, from: sortableTableViewPressed)
            cellSnapshot.alpha = 0.0
            self.containingView.addSubview(cellSnapshot)
            
            sortableTableViewPressed.onItemPickedUp(fromIndexPath: atIndexPath)

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
    
    //------------------------------------------------------------------------------
    
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
