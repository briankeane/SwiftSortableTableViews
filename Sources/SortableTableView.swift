//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

open class SortableTableView:UITableView
{
    var movingSortableItem:SortableTableViewItem?
    var ignoreRow:Int?
    var placeholderRow:Int?
    
    var observers:Array<NSObjectProtocol> = Array()
    
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
            if let newValue = newValue
            {
                self.delegate = SortableTableViewDelegateAdapter(tableView: self, delegate: newValue)
            }
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
            if let newValue = newValue
            {
                self.dataSource = SortableTableViewDataSourceAdapter(tableView: self, dataSource: newValue)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.setupListeners()
    }
    
    //------------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
                    self.insertPlaceholder(atRow: originalRow)
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
                    self.reloadRows(at: [IndexPath(row: originalRow, section: 0)], with: UITableViewRowAnimation.automatic)
                    self._sortableDataSource?.sortableTableView?(self, itemMoveDidCancel: originalRow)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func onItemPickedUp(fromRow:Int)
    {
        self.ignoreRow = fromRow
        self.placeholderRow = fromRow
        self.reloadRows(at: [IndexPath(row: fromRow, section: 0)], with: .automatic)
        self._sortableDataSource?.sortableTableView?(self, itemWasPickedUp: fromRow)
    }
    
    //------------------------------------------------------------------------------
    
    func onItemExited()
    {
        let oldRow = self.placeholderRow
        self.beginUpdates()
        self.removePlaceholder()
        self.endUpdates()
        if let oldRow = oldRow
        {
            self._sortableDelegate?.sortableTableView?(self, draggedItemDidExitTableViewFromRow: oldRow)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func onItemEntered(atRow:Int)
    {
        self.beginUpdates()
        self.insertPlaceholder(atRow: atRow)
        self.endUpdates()
        self._sortableDelegate?.sortableTableView?(self, draggedItemDidEnterTableViewAtRow: atRow)
    }
    
    //------------------------------------------------------------------------------
    
    func onItemMovedWithin(newRow: Int)
    {
        self.beginUpdates()
        self.removePlaceholder()
        self.insertPlaceholder(atRow: newRow)
        self.endUpdates()
    }
    
    //------------------------------------------------------------------------------
    
    func onDropItemIntoTableView(atRow:Int)
    {
        self.ignoreRow = nil
        self.placeholderRow = nil
        
        self.reloadRows(at: [IndexPath(row: atRow, section: 0)], with: .automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func onReleaseItemFromTableView()
    {
        self.ignoreRow = nil
    }
    
    //------------------------------------------------------------------------------
    
    func removePlaceholder()
    {
        if let placeholderRow = self.placeholderRow
        {
            self.placeholderRow = nil
            self.deleteRows(at: [IndexPath(row: placeholderRow, section: 0)], with: .automatic)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(atRow:Int)
    {
        self.placeholderRow = atRow
        self.insertRows(at: [IndexPath(row: atRow, section: 0)], with: .automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func movePlaceholder(toRow:Int)
    {
        self.removePlaceholder()
        self.insertPlaceholder(atRow: toRow)
    }
    
    //------------------------------------------------------------------------------
    
    func convertFromDelegateRow(_ row:Int) -> Int
    {
        var adjustedRow = row
        
        if let ignoreRow = self.ignoreRow
        {
            if (adjustedRow >= ignoreRow)
            {
                adjustedRow -= 1
            }
        }
        
        if let placeholderRow = self.placeholderRow
        {
            if (adjustedRow >= placeholderRow)
            {
                adjustedRow += 1
            }
        }
        return adjustedRow
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
        return  deAdjustedRow
    }

    //------------------------------------------------------------------------------
    
    func placeholderCell() -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.isHidden = true
        return cell
    }
    
    // DELEGATES

    //------------------------------------------------------------------------------
    
    func canBePickedUp(fromRow:Int) -> Bool
    {
        // IF the delegate has impleneted canBePickedUp, use that
        if let sortableDataSource = sortableDataSource
        {
            let result = sortableDataSource.sortableTableView?(self, canBePickedUp: fromRow)
            if let result = result
            {
                return result
            }
        }
        // default to true
        return true
    }
}
