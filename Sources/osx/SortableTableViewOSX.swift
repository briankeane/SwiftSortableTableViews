//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/25/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa
import AVKit

open class SortableTableView: NSTableView, NSTableViewDelegate, NSTableViewDataSource
{
    var connectedSortableTableViews:[SortableTableView] = Array()
    var movingSortableItem:SortableTableViewItem?
    
    var observers:[NSObjectProtocol] = Array()
    
    var placeholderRow:Int?
    var ignoreRow:Int?
    
    private var _sortableDataSource:SortableTableViewDataSource?
    private var _sortableDelegate:SortableTableViewDelegate?
    open var sortableDelegate:SortableTableViewDelegate?
    {
        get
        {
            return self._sortableDelegate
        }
        set
        {
            self._sortableDelegate = newValue
            self.delegate = self
        }
    }
    open var sortableDataSource:SortableTableViewDataSource?
    {
        get
        {
            return self._sortableDataSource
        }
        set
        {
            self._sortableDataSource = newValue
            self.dataSource = self
        }
    }
    
    //------------------------------------------------------------------------------
    
    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.setupListeners()
    }
    
    //------------------------------------------------------------------------------
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setupListeners()
    }

    //------------------------------------------------------------------------------
    
    func setupListeners()
    {
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.cancelMoveWillAnimate , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleCancelMoveWillAnimate(userInfo: userInfo)
                }
            }
        )
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.cancelMoveDidAnimate , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleCancelMoveDidAnimate(userInfo: userInfo)
                }
            }
        )
    }
    
    //------------------------------------------------------------------------------
    
    func handleCancelMoveWillAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            // IF it's this table, make a hole for the returning item
            if (originalTableView == self)
            {
                if let originalRow = userInfo["originalRow"] as? Int
                {
                    self.removePlaceholder()
                    self.insertPlaceholder(row: originalRow)
                }
            }
                // ELSE just smoothly reset the table to it's original state
            else
            {
                self.removePlaceholder()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func handleCancelMoveDidAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            if (originalTableView == self)
            {
                if let originalRow = userInfo["originalRow"] as? Int
                {
                    self.placeholderRow = nil
                    self.ignoreRow = nil
                    self.reloadData(forRowIndexes: IndexSet(originalRow), columnIndexes: IndexSet(0))
                    self._sortableDataSource?.sortableTableView?(self, itemMoveDidCancel: originalIndexPath)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func onItemPickedUp(fromRow:Int)
    {
        self.ignoreRow = fromRow
        self.placeholderRow = fromRow
        self.reloadData(forRowIndexes: IndexSet(fromRow), columnIndexes: IndexSet(0))
    }
    
    func onItemExited()
    {
        let oldPlaceholderRow = self.placeholderRow
        self.beginUpdates()
        self.removePlaceholder()
        self.endUpdates()
        if let oldPlaceholderRow = oldPlaceholderRow
        {
            self._sortableDelegate?.sortableTableView?(self, draggedItemDidExitTableViewFromRow:: oldPlaceholderRow)
        }
    }
    
    
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
    
    //------------------------------------------------------------------------------
    
    func adjustedNumberOfRows(_ numberOfRows:Int) -> Int
    {
        var adjustedNumberOfRows = numberOfRows
        if let _ = self.placeholderRow
        {
            adjustedNumberOfRows += 1
        }
        if let _ = self.ignoreRow
        {
            adjustedNumberOfRows -= 1
        }
        return adjustedNumberOfRows
    }
    
    //------------------------------------------------------------------------------
    
    func onItemPickedUp(fromRow:Int)
    {
        self.ignoreRow = fromRow
        self.placeholderRow = fromRow
        self.reloadData(forRowIndexes: [fromRow], columnIndexes: [0])
        self._sortableDataSource?.sortableTableView?(self, itemWasPickedUp: fromRow)
    }
    
    //------------------------------------------------------------------------------
    
    func convertToDelegateRow(_ row:Int) -> Int
    {
        var deAdjustedRow = row
        if let ignoreRow = self.ignoreRow
        {
            if (deAdjustedRow >= ignoreRow)
            {
                deAdjustedRow += 1
            }
        }
        
        if let placeholderRow = self.placeholderRow
        {
            if (deAdjustedRow >= placeholderRow)
            {
                deAdjustedRow -= 1
            }
        }
        return deAdjustedRow
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if (row == self.placeholderRow)
        {
            return self.placeholderCell()
        }
        return self.sortableDelegate?.tableView?(tableView, viewFor: tableColumn, row: self.convertToDelegateRow(row))
    }
    
    //------------------------------------------------------------------------------
    
    public func numberOfRows(in tableView: NSTableView) -> Int
    {
        if let numberOfRows = self.sortableDataSource?.numberOfRows?(in: self)
        {
            return self.adjustedNumberOfRows(numberOfRows)
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    func placeholderCell() -> NSView
    {
        let cell = NSTableCellView()
        cell.isHidden = true
        return cell
    }
    
    //------------------------------------------------------------------------------
    
    func createCellSnaphot(_ inputView: NSView) -> NSView
    {
        let rep = inputView.bitmapImageRepForCachingDisplay(in: inputView.bounds)!
        inputView.cacheDisplay(in: inputView.bounds, to: rep)
        
        let image = NSImage(size: inputView.bounds.size)
        image.addRepresentation(rep)
        
        let cellSnapshot:NSView = NSImageView(image: image)
        cellSnapshot.frame = inputView.frame
        cellSnapshot.layer?.masksToBounds = false
        cellSnapshot.layer?.cornerRadius = 0.0
        cellSnapshot.layer?.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer?.shadowRadius = 5.0
        cellSnapshot.layer?.shadowOpacity = 0.4
        cellSnapshot.wantsLayer = true
        return cellSnapshot
    }
    
    //------------------------------------------------------------------------------
    
    func canBePickedUp(row:Int) -> Bool
    {
        // IF the delegate has impleneted canBePickedUp, use that
        if let sortableDataSource = sortableDataSource
        {
            let result = sortableDataSource.sortableTableView?(self, canBePickedUp: row)
            if let result = result
            {
                return result
            }
        }
        // default to true
        return true
    }
//
//    
//    open override func mouseDragged(with event: NSEvent) {
//        NSLog("dragged")
//        let mouseEvent = NSEvent.mouseLocation()
//        
//            NSLog("x:\(mouseEvent.x), y: \(mouseEvent.y)")
//        
//        
//        
//    }
    
    
    
    //------------------------------------------------------------------------------
    
}

