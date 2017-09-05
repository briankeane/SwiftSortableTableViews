//
//  SortableTableViewHandler.swift
//  SwiftSortableTableviews
//
//  Created by Brian D Keane on 9/5/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

public class SortableTableViewHandler:NSObject
{
    public var sortableTableViews:Array<SortableTableView> = Array()
    public var containingView:UIView!
    
    public init(view:UIView, sortableTableViews:Array<SortableTableView>?=nil)
    {
        super.init()
        if let sortableTableViews = sortableTableViews
        {
            self.sortableTableViews = sortableTableViews
        }
        self.containingView = view
        self.setupGestureRecognizer()
    }
    
    //------------------------------------------------------------------------------
    
    func sortableTableViewAtPoint(_ pointPressed:CGPoint) -> SortableTableView?
    {
        for sortableTableView in self.sortableTableViews
        {
            if sortableTableView.frame.contains(pointPressed)
            {
                return sortableTableView
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    open func setupGestureRecognizer()
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SortableTableViewHandler.screenLongPressed(_:)))
        longPress.minimumPressDuration = 0.3
        self.containingView.addGestureRecognizer(longPress)
    }
    
    @objc func screenLongPressed(_ gestureRecognizer:UILongPressGestureRecognizer)
    {
        let longPress = gestureRecognizer
        let pressedLocationInParentView = longPress.location(in: self.containingView)
        let tableViewPressed = self.sortableTableViewAtPoint(pressedLocationInParentView)
        
        switch longPress.state
        {
        case .began:
            print(tableViewPressed)
//            if let _ = tableViewPressed
//            {
//                print(tableViewPressed)
//            }
            
            
//        case .changed:
//            self.moveCellSnapshot(pressedLocationInParentView, disappear: false)
//            
//            //            self.movePlaceholderIfNecessary(pressedLocationInParentView)
//            
//        case .ended:
//            self.cancelMove()
//            //            self.handleDroppedItem(tableViewPressed, longPress:longPress)
//            print("ended")
        default:
            print("default")
        }
    }
    
    
    
}
