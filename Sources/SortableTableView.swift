//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

open class SortableTableView:UITableView, UITableViewDataSource, UITableViewDelegate
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
            self.delegate = SortableTableViewDelegateAdapter(tableView: self, delegate: newValue)
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
    
    func canBePickedUp(indexPath:IndexPath) -> Bool
    {
        // IF the delegate has impleneted canBePickedUp, use that
        if let sortableDataSource = sortableDataSource
        {
            let result = sortableDataSource.sortableTableView?(self, canBePickedUp: indexPath)
            if let result = result
            {
                return result
            }
        }
        // default to true
        return true
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath == self.placeholderIndexPath)
        {
            return self.placeholderCell()
        }
        return (self.sortableDataSource?.tableView(self, cellForRowAt: self.convertToDelegateIndexPath(indexPath)))!
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let numberOfRows = self.sortableDataSource?.tableView(self, numberOfRowsInSection: section)
        {
            return self.adjustedNumberOfRows(numberOfRows)
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        if let numberOfSections = self.sortableDataSource?.numberOfSections?(in: self)
        {
            return numberOfSections
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Pass-Through DataSource methods
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self._sortableDataSource?.tableView?(self, canEditRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForHeaderInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForFooterInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self._sortableDataSource?.tableView?(self, canMoveRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return self._sortableDataSource?.sectionIndexTitles?(for: self)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let response = self._sortableDataSource?.tableView?(self, sectionForSectionIndexTitle: title, at: index)
        {
            return response
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        self._sortableDataSource?.tableView?(self, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        self._sortableDataSource?.tableView?(self, commit: editingStyle, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
}
