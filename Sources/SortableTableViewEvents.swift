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
    public static let pickupAnimated         =   Notification.Name(rawValue: "STVPickupAnimated")
    public static let pickupWillAnimate      =   Notification.Name(rawValue: "STVPickupWillAnimate")
    public static let hoveredOverCellChanged =   Notification.Name(rawValue: "STVHoveredOverChanged")
    public static let cancelMoveWillAnimate  =   Notification.Name(rawValue: "STVCancelMoveWillAnimate")
    public static let cancelMoveDidAnimate   =   Notification.Name(rawValue: "STVCancelMoveDidAnimate")
    public static let dropItemDidAnimate     =   Notification.Name(rawValue: "STVDropItemDidAnimate")
    public static let dropItemWillAnimate    =   Notification.Name(rawValue: "STVDropItemWillAnimate")
}
