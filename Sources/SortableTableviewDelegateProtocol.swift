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
    
    /// defaults to true
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReceiveItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:UITableView) -> Bool
    
    @objc optional func sortableTableView(_ releasingTableView: SortableTableView, shouldReleaseItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:SortableTableView) -> Bool
    
    @objc optional func sortableTableView(_ tableView:SortableTableView, canBePickedUp indexPath:IndexPath) -> Bool
}
//
//extension SortableTableViewDelegate
//{
//    func sortableTableView(_ releasingTableView: SortableTableView, shouldReceiveItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:SortableTableView) -> Bool
//    {
//        return true
//    }
//    
//    func sortableTableView(_ releasingTableView: SortableTableView, shouldReleaseItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath, receivingTableView:SortableTableView) -> Bool
//    {
//        return true
//    }
//    func sortableTableView(_ tableView:SortableTableView, canBePickedUp indexPath:IndexPath) -> Bool
//    {
//        return true
//    }
//}
