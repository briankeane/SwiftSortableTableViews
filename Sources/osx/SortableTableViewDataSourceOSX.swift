//
//  SortableTableViewDataSourceOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/6/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Cocoa

@objc public protocol SortableTableViewDataSource:NSTableViewDataSource
{
     @objc optional func sortableTableView(_ tableView:SortableTableView, canBePickedUp row:Int) -> Bool
    @objc optional func sortableTableView(_ originalTableView:SortableTableView, itemWasPickedUp originalRow:Int)
}
