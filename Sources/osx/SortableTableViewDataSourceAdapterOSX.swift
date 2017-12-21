//
//  SortableTableViewDataSourceAdapterOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

class SortableTableViewDataSourceAdapter: NSObject, NSTableViewDataSource
{
    var tableView:SortableTableView
    var dataSource:SortableTableViewDataSource
    
    init(tableView:SortableTableView, dataSource:SortableTableViewDataSource)
    {
        self.tableView = tableView
        self.dataSource = dataSource
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
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.adjustedNumberOfRows(self.dataSource.numberOfRows!(in: self.tableView))
    }
    
    //------------------------------------------------------------------------------
    
    // this is the shouldPickUp
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting?
    {
        // Check with delegate to see if it can be picked up
        if (self.dataSource.sortableTableView?(self.tableView, canBePickedUp: self.tableView.convertToDelegateRow(row)) == true)
        {
            
            let cell = self.tableView.view(atColumn: 0, row: row, makeIfNecessary: false)!
            // setup item with Handler
            
            let itemToTransfer = self.dataSource.sortableTableView?(self.tableView, item: row)
            
            let item = SortableTableViewItem(originalTableView: self.tableView, originalRow: self.tableView.convertToDelegateRow(row), cellSnapshot: NSImageView(image: self.tableView.createCellSnaphot(cell)), transferringItem:itemToTransfer)
            
            SortableTableViewHandler.sharedInstance().itemInMotion = item
            
            let pbItem = NSPasteboardItem()
            pbItem.setString("test", forType: kUTTypeText as String)
            return pbItem
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool
    {
        puts("writeRowsWith")
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([NSStringPboardType], owner: self)
        pboard.setData(data, forType: NSStringPboardType)

        
        return true
    }
    
    
    func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        print("updateDraggingItemsForDrag")
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        puts("sortDescriptorsDidChange")
    }
//
//    // DO NOT IMPLEMENT -- for cell based only
////    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
////
////    }

//
//    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String] {
//        <#code#>
//    }
//
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool
    {
        let row = self.tableView.placeholderRow!
        if let itemInMotion = SortableTableViewHandler.sharedInstance().itemInMotion
        {
            if (itemInMotion.originalTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, shouldReleaseItem: itemInMotion.originalRow, desiredRow: row, receivingTableView: self.tableView, transferringItem: itemInMotion.transferringItem) == true)
            {
                if (self.dataSource.sortableTableView?(itemInMotion.originalTableView, shouldReceiveItem: itemInMotion.originalRow, desiredRow: row, receivingTableView: self.tableView, transferringItem: itemInMotion.transferringItem) == true)
                {
                    self.dataSource.sortableTableView?(itemInMotion.originalTableView, willReceiveItem: itemInMotion.originalRow, newRow: row, receivingTableView: self.tableView, transferringItem: itemInMotion.transferringItem)
                    itemInMotion.originalTableView.sortableDataSource?.sortableTableView?(itemInMotion.originalTableView, willReleaseItem: itemInMotion.originalRow, newRow: row, receivingTableView: self.tableView, transferringItem: itemInMotion.transferringItem)
                    NotificationCenter.default.post(name: SortableTableViewEvents.dropItemDidAnimate, object: nil, userInfo:  nil)
                     return true
                }
            }
        }
        SortableTableViewHandler.sharedInstance().performCancelMove()
        return false
    }

    // This is used to move the placeholder.
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation
    {
        (tableView as? SortableTableView)?.onItemMovedWithin(newRow: row)
        return .every
    }
    
    
    
    
}
