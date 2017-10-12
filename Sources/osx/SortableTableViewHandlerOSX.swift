//
//  SortableTableViewHandlerOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

public class SortableTableViewHandler: NSObject
{
    public var sortableTableViews:[SortableTableView] = Array()
    public var containingView:NSView!
    
    public init(view:NSView, sortableTableViews:Array<SortableTableView>?=nil)
    {
        super.init()
        if let sortableTableViews = sortableTableViews
        {
            self.sortableTableViews = sortableTableViews
        }
        self.containingView = view
    }
}
