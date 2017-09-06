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
    
    var observers:Array<NSObjectProtocol> = Array()
    
    private var _sortableDataSource:SortableTableViewDataSource?
    open var sortableDelegate:SortableTableViewDelegate?
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
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.pickupAnimated , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleItemPickedUp(userInfo: userInfo)
                }
            }
        )
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.hoveredOverCellChanged , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleHoveredOverChanged(userInfo: userInfo)
                }
            }
        )
    }
    
    func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit
    {
        self.removeObservers()
    }
    
    func handleItemPickedUp(userInfo:[AnyHashable:Any]?)
    {
        if let originalTableView = userInfo?["originalTableView"] as? SortableTableView
        {
            if (originalTableView == self)
            {
                if let originalIndexPath = userInfo?["originalIndexPath"] as? IndexPath
                {
                    self.ignoreIndexPath = originalIndexPath
                    self.placeholderIndexPath = originalIndexPath
                    self.reloadData()
                }
            }
        }
    }
    
    func handleHoveredOverChanged(userInfo:[AnyHashable:Any]?)
    {
        if let userInfo = userInfo
        {
            // IF it has left this tableView
            if ((userInfo["hoveredOverTableView"] == nil) && (self.placeholderIndexPath != nil))
            {
                print("removing placeholder")
                self.removePlaceholder()
            }
            // ELSE IF it has entered this tableView
            else if (((userInfo["hoveredOverTableView"] as? SortableTableView) == self) && (self.placeholderIndexPath == nil))
            {
                print("enteredTableview")
                if let hoveredOverIndexPath = userInfo["hoveredOverIndexPath"] as? IndexPath
                {
                    self.insertPlaceholder(indexPath: hoveredOverIndexPath)
                }
            }
            // ELSE IF it has moved within this tableView
            else if (((userInfo["hoveredOverTableView"] as? SortableTableView) == self) && (self.placeholderIndexPath != nil))
            {
                print("moved within tableView")
                if let hoveredOverIndexPath = userInfo["hoveredOverIndexPath"] as? IndexPath
                {
                    self.movePlaceholder(from: self.placeholderIndexPath!, to: hoveredOverIndexPath)
                }
            }
            // ELSE IF it exited this tableView
            else if ((userInfo["hoveredOverTableView"] == nil) && (self.placeholderIndexPath != nil))
            {
                print("exited tableView")
                self.removePlaceholder()
            }
            
        }
    }
    
    //------------------------------------------------------------------------------
    
    func removePlaceholder()
    {
        if let placeholderIndexPath = self.placeholderIndexPath
        {
            self.placeholderIndexPath = nil
            self.deleteRows(at: [placeholderIndexPath], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(indexPath:IndexPath)
    {
        self.placeholderIndexPath = indexPath
        self.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func movePlaceholder(from:IndexPath, to:IndexPath)
    {
        self.removePlaceholder()
        self.insertPlaceholder(indexPath: to)
    }
    
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
    
    func setPlaceholder(_ indexPath:IndexPath)
    {
        print("setPlaceholder stub")
    }
    
    func placeholderCell() -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.isHidden = true
        return cell
    }

    //------------------------------------------------------------------------------
    
    func canBePickedUp(indexPath:IndexPath) -> Bool
    {
        return true
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath == self.placeholderIndexPath)
        {
            return self.placeholderCell()
        }
        
        return (self.sortableDataSource?.tableView(self, cellForRowAt: self.adjustedIndexPath(indexPath)))!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = self.sortableDataSource?.tableView(self, numberOfRowsInSection: section)
        {
            return self.adjustedNumberOfRows(numberOfRows)
        }
        return 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let numberOfSections = self.sortableDataSource?.numberOfSections?(in: self)
        {
            return numberOfSections
        }
        return 0
    }
}
