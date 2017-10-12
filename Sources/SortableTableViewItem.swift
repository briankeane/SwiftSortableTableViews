//
//  SortableTableViewItem.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    public class SortableTableViewItem
    {
        var originalRow:Int!
        var originalTableView:SortableTableView!
        var originalCenter:CGPoint!
        var cellSnapshot:UIView!
        
        var hoveredOverRow:Int?
        var hoveredOverTableView:SortableTableView?
        
        
        init(originalTableView:SortableTableView!, originalRow:Int!, originalCenter:CGPoint = CGPoint(x: 0, y: 0), cellSnapshot:UIView!)
        {
            self.originalTableView = originalTableView
            self.originalRow = originalRow
            self.hoveredOverRow = originalRow
            self.hoveredOverTableView = originalTableView
            self.originalCenter = originalCenter
            self.cellSnapshot = cellSnapshot
        }
    }

#else

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

#endif
