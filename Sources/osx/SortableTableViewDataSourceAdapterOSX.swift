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

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting?
    {
        puts("pasteboardWriterForRow")
        if (self.dataSource.sortableTableView?(self.tableView, canBePickedUp: self.tableView.convertToDelegateRow(row)) == true)
        {
            puts("canBePickedUp")
            let item = NSPasteboardItem()
            item.setString("test", forType: kUTTypeText as String)
            return item
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
    
//
//    func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
//        <#code#>
//    }
//
//    // DO NOT IMPLEMENT -- for cell based only
////    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
////
////    }
//    
//    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
//        <#code#>
//    }
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
    

    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation
    {
        (tableView as? SortableTableView)?.onItemMovedWithin(newRow: row)
        return .every
    }
}
