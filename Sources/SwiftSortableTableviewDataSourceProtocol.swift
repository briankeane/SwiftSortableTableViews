//
//  SwiftSortableTableviewDataSourceProtocol.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SortableTableViewDataSource:UITableViewDataSource
{
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReceiveItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:UITableView) -> Bool
    
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReleaseItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:SortableTableView) -> Bool
    
    @objc optional func sortableTableView(_ tableView:SortableTableView, canBePickedUp indexPath:IndexPath) -> Bool
    
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReceiveItem originalIndexPath: IndexPath, newIndexPath:IndexPath, receivingTableView:UITableView)
    
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, willReleaseItem originalIndexPath: IndexPath, newIndexPath:IndexPath, receivingTableView:SortableTableView)

    @objc func sortableTableView(_ tableView:SortableTableView, willDropItem originalIndexPath:IndexPath, newIndexPath:IndexPath)
}
