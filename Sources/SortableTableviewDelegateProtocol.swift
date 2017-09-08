//
//  SortableTableviewDelegateProtocol.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SortableTableViewDelegate:UITableViewDelegate {
    @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidEnterTableViewAtIndexPath indexPath:IndexPath)
    @objc optional func sortableTableView(_ tableView:SortableTableView, draggedItemDidExitTableViewFromIndexPath indexPath:IndexPath)
}
