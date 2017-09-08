//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

open class SortableTableView:UITableView, UITableViewDataSource
{
    var containingView:UIView?
    var connectedSortableTableViews:Array<SortableTableView> = Array()
    var movingSortableItem:SortableTableViewItem?
    var ignoreIndexPath:IndexPath?
    var placeholderIndexPath:IndexPath?
    
    
    // StoredDataSourceFunctions
    
    
    var canEditRowAtIndexPath:((_ tableView: UITableView, _ indexPath: IndexPath) -> Bool)?
    
    
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
            self.delegate = self._sortableDelegate
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
    
    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.setupListeners()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupListeners()
    }
    
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
    
    
    
    func handleCancelMoveWillAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            // IF it's this table, make a hole for the returning item
            if (originalTableView == self)
            {
                if let originalIndexPath = userInfo["originalIndexPath"] as? IndexPath
                {
                    self.removePlaceholder()
                    self.insertPlaceholder(indexPath: originalIndexPath)
                }
            }
            // ELSE just smoothly reset the table to it's original state
            else
            {
                self.removePlaceholder()
            }
        }
    }
    
    func handleCancelMoveDidAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            if (originalTableView == self)
            {
                if let originalIndexPath = userInfo["originalIndexPath"] as? IndexPath
                {
                    self.placeholderIndexPath = nil
                    self.ignoreIndexPath = nil
                    self.reloadRows(at: [originalIndexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
    
    func onItemPickedUp(fromIndexPath:IndexPath)
    {
        print("onItemPickedUp")
        self.ignoreIndexPath = fromIndexPath
        self.placeholderIndexPath = fromIndexPath
        self.reloadRows(at: [fromIndexPath], with: .automatic)
    
    }
    
    func onItemExited()
    {
        print("onItemExited")
        print("before exit: \(self.tableView(self, numberOfRowsInSection: 0))")
        let oldIndexPath = self.placeholderIndexPath
        self.beginUpdates()
        self.removePlaceholder()
        print("after exit: \(self.tableView(self, numberOfRowsInSection: 0))")
        self.endUpdates()
        if let oldIndexPath = oldIndexPath
        {
            
            self._sortableDelegate?.sortableTableView?(self, draggedItemDidExitTableViewFromIndexPath: oldIndexPath)
        }
    }
    
    func onItemEntered(atIndexPath:IndexPath)
    {
        print("onItemEntered")
        self.beginUpdates()
        self.insertPlaceholder(indexPath: atIndexPath)
        self.endUpdates()
        self._sortableDelegate?.sortableTableView?(self, draggedItemDidEnterTableViewAtIndexPath: atIndexPath)
    }
    
    func onItemMovedWithin(newIndexPath: IndexPath)
    {
        print("onItemMovedWithin")
        self.beginUpdates()
        self.removePlaceholder()
        self.insertPlaceholder(indexPath: newIndexPath)
        self.endUpdates()
    }
    
    //------------------------------------------------------------------------------
    
    func onDropItemIntoTableView(atIndexPath:IndexPath)
    {
        print("onDropItemIntoTableView at indexPath: \(atIndexPath.row)")
        self.ignoreIndexPath = nil
        self.placeholderIndexPath = nil
        
        self.reloadRows(at: [atIndexPath], with: .automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func onReleaseItemFromTableView()
    {
        print("onReleaseItemFromTableView")
        self.ignoreIndexPath = nil
    }
    
    //------------------------------------------------------------------------------
    
    func removePlaceholder()
    {
        if let placeholderIndexPath = self.placeholderIndexPath
        {
            print("remove placeholder")
            self.placeholderIndexPath = nil
            self.deleteRows(at: [placeholderIndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(indexPath:IndexPath)
    {
        print("insertPlaceholder at \(indexPath.row)")
        if (indexPath.row == 0)
        {
            print("here")
        }
        self.placeholderIndexPath = indexPath
        self.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func movePlaceholder(from:IndexPath, to:IndexPath)
    {
        self.removePlaceholder()
        self.insertPlaceholder(indexPath: to)
    }
    
    //------------------------------------------------------------------------------
    
    func adjustedNumberOfRows(_ numberOfRows:Int) -> Int
    {
        var adjustedNumberOfRows = numberOfRows
        if let _ = self.placeholderIndexPath
        {
            adjustedNumberOfRows += 1
        }
        if let _ = self.ignoreIndexPath
        {
            adjustedNumberOfRows -= 1
        }
        return adjustedNumberOfRows
    }
    
    //------------------------------------------------------------------------------
    
    func adjustedIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        var adjustedIndexPathRow = indexPath.row
        
        if let ignoreIndexPathRow = self.ignoreIndexPath?.row
        {
            if (adjustedIndexPathRow >= ignoreIndexPathRow)
            {
                adjustedIndexPathRow -= 1
            }
        }
        
        if let placeholderIndexPathRow = self.placeholderIndexPath?.row
        {
            if (adjustedIndexPathRow >= placeholderIndexPathRow)
            {
                adjustedIndexPathRow += 1
            }
        }
        return IndexPath(row: adjustedIndexPathRow, section: indexPath.section)
    }
    
    //------------------------------------------------------------------------------
    
    func deAdjustedIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        var deAdjustedIndexPathRow = indexPath.row
        if let ignoreIndexPathRow = self.ignoreIndexPath?.row
        {
            if (deAdjustedIndexPathRow >= ignoreIndexPathRow)
            {
                deAdjustedIndexPathRow += 1
            }
        }
        
        if let placeholderIndexPathRow = self.placeholderIndexPath?.row
        {
            if (deAdjustedIndexPathRow >= placeholderIndexPathRow)
            {
                deAdjustedIndexPathRow -= 1
            }
        }
        return IndexPath(row: deAdjustedIndexPathRow, section: indexPath.section)
    }

    //------------------------------------------------------------------------------
    
    func setPlaceholder(_ indexPath:IndexPath)
    {
        print("setPlaceholder stub")
    }
    
    //------------------------------------------------------------------------------
    
    func placeholderCell() -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.isHidden = true
        return cell
    }

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
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath == self.placeholderIndexPath)
        {
            return self.placeholderCell()
        }
        print("cellForRowAt: \(self.deAdjustedIndexPath(indexPath).row)")
        return (self.sortableDataSource?.tableView(self, cellForRowAt: self.deAdjustedIndexPath(indexPath)))!
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let numberOfRows = self.sortableDataSource?.tableView(self, numberOfRowsInSection: section)
        {
            print("gettingNumberOfRows adjusted: \(self.adjustedNumberOfRows(numberOfRows)), regular: \(numberOfRows)")
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
    
    // Pass-Through DataSource methods
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let response = self._sortableDataSource?.tableView?(self, canEditRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForFooterInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let response = self._sortableDataSource?.tableView?(self, canMoveRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self._sortableDataSource?.sectionIndexTitles?(for: self)
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let response = self._sortableDataSource?.tableView?(self, sectionForSectionIndexTitle: title, at: index)
        {
            return response
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sortableDataSource?.tableView?(self, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self._sortableDataSource?.tableView?(self, commit: editingStyle, forRowAt: self.deAdjustedIndexPath(indexPath))
    }
}
