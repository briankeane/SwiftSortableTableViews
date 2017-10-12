//
//  SortableTableviewDelegateProtocol.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

    @objc public protocol SortableTableViewDelegate:UITableViewDelegate {
        @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidEnterTableViewAtRow row:Int)
        @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidExitTableViewFromRow row:Int)
    }

#else
    import AVKit
    
    @objc public protocol SortableTableViewDelegate:NSTableViewDelegate {
        @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidEnterTableViewAtRow row:Int)
        @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidExitTableViewFromRow row:Int)
    }
#endif
