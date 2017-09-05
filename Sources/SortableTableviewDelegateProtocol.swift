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
    @objc optional func sortableTableView(_ releasingTableView: UITableView, shouldReceiveItemAtIndexPath originalIndexPath: IndexPath, desiredIndexPath:IndexPath) -> Bool
    
    @objc optional func sortableTableView(_ receivingTableView: UITableView, shouldReleaseItemToIndexPath originalIndexPath: IndexPath, desiredIndexPath:IndexPath) -> Bool
}

extension SortableTableViewDelegate
{
    func sortableTableView(_ releasingTableView: UITableView, shouldReceiveItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath) -> Bool
    {
        return true
    }
    
    func sortableTableView(_ receivingTableView: UITableView, shouldReleaseItem originalIndexPath: IndexPath, desiredIndexPath:IndexPath) -> Bool
    {
        return true
    }
}
