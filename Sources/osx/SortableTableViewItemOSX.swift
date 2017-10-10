//
//  SortableTableViewItem.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/6/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import AVKit

public class SortableTableViewItem
{
    var originalRow:Int!
    var originalTableView:SortableTableView!
    var originalCenter:CGPoint!
    var cellSnapshot:NSView!
    
    var hoveredOverRow:Int?
    var hoveredOverTableView:SortableTableView?
    
    
    init(originalTableView:SortableTableView!, originalRow:Int!, originalCenter:CGPoint = CGPoint(x: 0, y: 0), cellSnapshot:NSView!)
    {
        self.originalTableView = originalTableView
        self.originalRow = originalRow
        self.hoveredOverRow = originalRow
        self.hoveredOverTableView = originalTableView
        self.originalCenter = originalCenter
        self.cellSnapshot = cellSnapshot
    }
}
