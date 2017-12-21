//
//  SortableTableViewHandlerOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

public class SortableTableViewHandler: NSObject
{
    public var itemInMotion:SortableTableViewItem?
    public var itemDropInProgress:Bool = false
    
    public override init()
    {
        super.init()
        self.setupListeners()
    }
    
    func setupListeners()
    {
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.willPickUpItem, object: nil, queue: .main)
            {
                (notification) -> Void in
                if let dict = notification.userInfo
                {
                    if let sortableItem = dict["item"] as? SortableTableViewItem
                    {
                        self.itemInMotion = sortableItem
                    }
                }
            }
        )
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.cancelMoveDidAnimate, object: nil, queue: .main)
            {
                (notification) -> Void in
                self.itemInMotion = nil
            }
        )
    }
    
    func itemReleasedOverTableView(receivingTableView:SortableTableView, desiredRow:Int) -> Void
    {
        if let itemInMotion = self.itemInMotion
        {
            if (receivingTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, shouldReceiveItem: itemInMotion.originalRow, desiredRow: desiredRow, receivingTableView: receivingTableView, transferringItem: self.itemInMotion?.transferringItem) == true)
            {
                if (itemInMotion.originalTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, shouldReleaseItem: itemInMotion.originalRow, desiredRow: desiredRow, receivingTableView: receivingTableView, transferringItem: self.itemInMotion?.transferringItem) == true)
                {
                    return self.performMoveItem(receivingTableView: receivingTableView, newRow: desiredRow)
                }
            }
        }
        return self.performCancelMove()
    }
    
    func itemReleasedOverNothing()
    {
        self.performMoveCancelWillAnimate()
        self.performMoveCancelDidAnimate()
    }
    
    func performMoveItem(receivingTableView:SortableTableView, newRow:Int)
    {
        self.itemDropInProgress = true
        self.performDropItemWillAnimate(receivingTableView: receivingTableView, newRow: newRow)
        self.performDropItemDidAnimate()
        self.itemDropInProgress = false
    }
    
    func performCancelMove()
    {
        self.performMoveCancelWillAnimate()
        self.performMoveCancelDidAnimate()
    }
    
    func performMoveCancelWillAnimate()
    {
        // open the original spot
        if let itemInMotion = self.itemInMotion
        {
            itemInMotion.originalTableView.insertPlaceholder(atRow: itemInMotion.originalRow)
        }
        // send the notification so others can react
        NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveWillAnimate, object: nil, userInfo: ["originalTableView": itemInMotion?.originalTableView as Any,
                                                                                                                     "originalRow": itemInMotion?.originalRow as Any])
    }
    
    func performMoveCancelDidAnimate()
    {
        if let itemInMotion = self.itemInMotion
        {
            itemInMotion.originalTableView.removePlaceholder()
            itemInMotion.originalTableView.reloadData()
            self.itemInMotion = nil
            NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveDidAnimate, object: nil, userInfo: ["originalTableView": itemInMotion.originalTableView,
                                                                                                                        "originalRow": itemInMotion.originalRow])
        }
    }
    
    func performDropItemWillAnimate(receivingTableView:SortableTableView, newRow:Int)
    {
        if let itemInMotion = self.itemInMotion
        {
            receivingTableView.removePlaceholder()
            // tell the receiving table it's getting something
            receivingTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, willReceiveItem: itemInMotion.originalRow, newRow: newRow, receivingTableView: receivingTableView, transferringItem: itemInMotion.transferringItem)
            // tell the releasing table it's losing something
            itemInMotion.originalTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, willReleaseItem: itemInMotion.originalRow, newRow: newRow, receivingTableView: receivingTableView, transferringItem: itemInMotion.transferringItem)
            
            // announce to everyone
            NotificationCenter.default.post(name: SortableTableViewEvents.dropItemWillAnimate, object: nil, userInfo: nil)
        }
    }
    
    func performDropItemDidAnimate()
    {
        NotificationCenter.default.post(name: SortableTableViewEvents.dropItemDidAnimate, object: nil, userInfo: nil)
    }
    
    //------------------------------------------------------------------------------
    
    var observers:Array<NSObjectProtocol> = Array()
    
    //------------------------------------------------------------------------------
    
    func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //------------------------------------------------------------------------------
    
    deinit
    {
        self.removeObservers()
    }
    
    static var _instance:SortableTableViewHandler?
    
    public static func sharedInstance() -> SortableTableViewHandler
    {
        if let instance = self._instance
        {
            return instance
        }
        self._instance = SortableTableViewHandler()
        return self._instance!
    }
}
