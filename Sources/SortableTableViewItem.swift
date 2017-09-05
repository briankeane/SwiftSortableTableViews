//
//  SortableTableViewItem.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

public class SortableTableViewItem
{
    var originalIndexPath:IndexPath!
    var originalTableView:SortableTableView!
    var originalCenter:CGPoint!
    var cellSnapshot:UIView!
    
    var hoveringIndexPath:IndexPath?
    var hoveringTableView:SortableTableView?
    
    
    init(originalTableView:SortableTableView!, originalIndexPath:IndexPath!, originalCenter:CGPoint = CGPoint(x: 0, y: 0), cellSnapshot:UIView!)
    {
        self.originalTableView = originalTableView
        self.originalIndexPath = originalIndexPath
        self.originalCenter = originalCenter
        self.cellSnapshot = cellSnapshot
    }
}
