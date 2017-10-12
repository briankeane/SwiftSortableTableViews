//
//  SortableTableViewDataSourceAdapterIOS.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

class SortableTableViewDataSourceAdapter: NSObject, UITableViewDataSource
{
    var tableView:SortableTableView
    var dataSource:SortableTableViewDataSource
    
    init(tableView:SortableTableView, dataSource:SortableTableViewDataSource)
    {
        self.tableView = tableView
        self.dataSource = dataSource
    }
    
    //------------------------------------------------------------------------------
    
    func convertToDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        let convertedRow = self.tableView.convertToDelegateRow(indexPath.row)
        return IndexPath(row: convertedRow, section: 0)
    }
    
    //------------------------------------------------------------------------------
    
    func convertFromDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        let convertedRow = self.tableView.convertFromDelegateRow(indexPath.row)
        return IndexPath(row: convertedRow, section: 0)
    }
    
    func adjustedNumberOfRows(_ numberOfRows:Int) -> Int
    {
        var adjustedNumberOfRows = numberOfRows
        if let _ = self.tableView.placeholderRow
        {
            adjustedNumberOfRows += 1
        }
        if let _ = self.tableView.ignoreRow
        {
            adjustedNumberOfRows -= 1
        }
        return adjustedNumberOfRows
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self.dataSource.tableView?(self.tableView, canEditRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self.dataSource.tableView?(self.tableView, canMoveRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let numberOfRows = self.dataSource.tableView(self.tableView, numberOfRowsInSection: section)
        
            return self.adjustedNumberOfRows(numberOfRows)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.dataSource.tableView?(self.tableView, titleForFooterInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource.tableView?(self.tableView, titleForHeaderInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.row == self.tableView.placeholderRow)
        {
            return self.tableView.placeholderCell()
        }
        return (self.dataSource.tableView(self.tableView, cellForRowAt: self.convertToDelegateIndexPath(indexPath)))
    }
    
    //------------------------------------------------------------------------------
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return self.dataSource.sectionIndexTitles?(for: self.tableView)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        self.dataSource.tableView?(self.tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        self.dataSource.tableView?(self.tableView, commit: editingStyle, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        if let response = self.dataSource.tableView?(self.tableView, sectionForSectionIndexTitle: title, at: index)
        {
            return response
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        if let numberOfSections = self.dataSource.numberOfSections?(in: self.tableView)
        {
            return numberOfSections
        }
        return 0
    }
    
    
}
