//
//  SwiftSortableTableviewDataSourceProtocol.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit

    @objc public protocol SortableTableViewDataSource:UITableViewDataSource
    {
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReceiveItem originalRow: Int, desiredRow:Int, receivingTableView:SortableTableView, transferringItem:Any?) -> Bool
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReleaseItem originalRow: Int, desiredRow:Int, receivingTableView:SortableTableView, transferringItem:Any?) -> Bool
        
        @objc optional func sortableTableView(_ tableView:SortableTableView, canBePickedUp row:Int) -> Bool
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReceiveItem originalRow: Int, newRow:Int, receivingTableView:SortableTableView, transferringItem:Any?)
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReleaseItem originalRow: Int, newRow:Int, receivingTableView:SortableTableView, transferringItem:Any?)
        
        @objc optional func sortableTableView(_ originalTableView:SortableTableView, itemMoveDidCancel originalRow:Int)
        
        @objc optional func sortableTableView(_ originalTableView:SortableTableView, itemWasPickedUp originalRow:Int)
        
        @objc optional func sortableTableView(_ tableView:SortableTableView, item forRow:Int) -> Any?
    }

#else
    import AVKit

    @objc public protocol SortableTableViewDataSource:NSTableViewDataSource
    {
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReceiveItem originalRow: Int, desiredRow:Int, receivingTableView:SortableTableView, transferringItem:Any?) -> Bool
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReleaseItem originalRow: Int, desiredRow:Int, receivingTableView:SortableTableView, transferringItem:Any?) -> Bool
        
        @objc optional func sortableTableView(_ tableView:SortableTableView, canBePickedUp row:Int) -> Bool
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReceiveItem originalRow: Int, newRow:Int, receivingTableView:SortableTableView, transferringItem:Any?)
        
        @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReleaseItem originalRow: Int, newRow:Int, receivingTableView:SortableTableView, transferringItem:Any?)
        
        @objc optional func sortableTableView(_ originalTableView:SortableTableView, itemMoveDidCancel originalRow:Int)
        
        @objc optional func sortableTableView(_ originalTableView:SortableTableView, itemWasPickedUp originalRow:Int)
        
        @objc optional func sortableTableView(_ tableView:SortableTableView, item forRow:Int) -> Any?
    }
#endif
