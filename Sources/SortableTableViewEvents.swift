//
//  SortableTableViewEvents.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/6/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct SortableTableViewEvents
{
    /// userInfo: "originalTableView", "originalIndexPath"
    public static let pickupAnimated       =   Notification.Name(rawValue: "STVPickupAnimated")
}
