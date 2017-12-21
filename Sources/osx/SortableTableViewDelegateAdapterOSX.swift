//
//  SortableTableViewDelegateAdapterOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

class SortableTableViewDelegateAdapter: NSObject, NSTableViewDelegate
{
    var tableView:SortableTableView
    var delegate:SortableTableViewDelegate
    
    
    init(tableView:SortableTableView, delegate:SortableTableViewDelegate)
    {
        self.tableView = tableView
        self.delegate = delegate
    }
    
//    //------------------------------------------------------------------------------
//    
//    func convertToDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
//    {
//        let convertedRow = self.tableView.convertToDelegateRow(indexPath.row)
//        return IndexPath(row: convertedRow, section: 0)
//    }
//    
//    //------------------------------------------------------------------------------
//    
//    func convertFromDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
//    {
//        let convertedRow = self.tableView.convertFromDelegateRow(indexPath.row)
//        return IndexPath(row: convertedRow, section: 0)
//    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        self.delegate.tableViewColumnDidMove?(notification)
    }
    
    //------------------------------------------------------------------------------
    
    func tableViewColumnDidResize(_ notification: Notification) {
        self.delegate.tableViewColumnDidResize?(notification)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.delegate.tableViewSelectionDidChange?(notification)
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        self.delegate.tableViewSelectionDidChange?(notification)
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        if let result = self.delegate.selectionShouldChange?(in: self.tableView)
        {
            return result
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, shouldEdit: tableColumn, row: self.tableView.convertToDelegateRow(row))
        {
            return result
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, isGroupRow: self.tableView.convertToDelegateRow(row))
        {
            return result
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let result = self.delegate.tableView?(self.tableView, heightOfRow: self.tableView.convertToDelegateRow(row))
        {
            return result
        }
        return self.tableView.rowHeight
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return self.delegate.tableView?(self.tableView, rowViewForRow: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, shouldSelectRow: self.tableView.convertToDelegateRow(row))
        {
            return result
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, didDrag tableColumn: NSTableColumn) {
        puts("didDrag")
        self.delegate.tableView?(self.tableView, didDrag: tableColumn)
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        self.delegate.tableView?(self.tableView, didClick: tableColumn)
    }
    
//    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
//        if let result = self.delegate.tableView?(self.tableView, sizeToFitWidthOfColumn: column)
//        {
//            return result
//        }
//    }
    
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        self.delegate.tableView?(self.tableView, mouseDownInHeaderOf: tableColumn)
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
//        puts("didAdd")
        self.delegate.tableView?(self.tableView, didAdd: rowView, forRow: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, shouldSelect: tableColumn)
        {
            return result
        }
        return true
    }
    
    
    
    
    func tableView(_ tableView: NSTableView, didRemove rowView: NSTableRowView, forRow row: Int)
    {
//        puts("didRemove")
        self.delegate.tableView?(self.tableView, didRemove: rowView, forRow: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (row == self.tableView.placeholderRow)
        {
            return self.tableView.placeholderCell()
        }
        return self.delegate.tableView?(self.tableView, viewFor: tableColumn, row: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
        return self.delegate.tableView?(self.tableView, dataCellFor: tableColumn, row: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        return self.delegate.tableView?(self.tableView, typeSelectStringFor: tableColumn, row: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        self.delegate.tableView?(self.tableView, willDisplayCell: cell, for: tableColumn, row: self.tableView.convertToDelegateRow(row))
    }
    
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, shouldShowCellExpansionFor: tableColumn, row: self.tableView.convertToDelegateRow(row))
        {
            return result
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, shouldReorderColumn: columnIndex, toColumn: newColumnIndex)
        {
            return result
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
        if let result = self.delegate.tableView?(self.tableView, rowActionsForRow: self.tableView.convertToDelegateRow(row), edge: edge)
        {
            return result
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, shouldTrackCell cell: NSCell, for tableColumn: NSTableColumn?, row: Int) -> Bool {
        if let result = self.delegate.tableView?(self.tableView, shouldTrackCell: cell, for: tableColumn, row: self.tableView.convertToDelegateRow(row))
        {
           return result
        }
        return cell.isSelectable
    }
    
    // TODO: Later this should convert the IndexSet to delegate
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if let result = self.delegate.tableView?(self.tableView, selectionIndexesForProposedSelection: proposedSelectionIndexes)
        {
            return result
        }
        return proposedSelectionIndexes
    }

    // TODO: implement these
//    func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent, withCurrentSearch searchString: String?) -> Bool {
//        if let
//    }
//    
//    func tableView(_ tableView: NSTableView, nextTypeSelectMatchFromRow startRow: Int, toRow endRow: Int, for searchString: String) -> Int {
//
//    }
//    
    
    
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        if let result = self.delegate.tableView?(self.tableView, toolTipFor: cell, rect: rect, tableColumn: tableColumn, row: self.tableView.convertToDelegateRow(row), mouseLocation: mouseLocation)
        {
            return result
        }
        return ""
    }

    
}
