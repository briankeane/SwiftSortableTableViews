//
//  SortableTableViewHandlerOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/7/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import AVKit

public class SortableTableViewHandler:NSObject
{
    public var sortableTableViews:[SortableTableView] = Array()
    public var itemInMotion:SortableTableViewItem?
    public var containingView:NSView!
    public var mouseIsDown:Bool = false
    var eventMonitor:Any?
    
    public init(view:NSView, sortableTableViews:[SortableTableView]?=nil)
    {
        super.init()
        if let sortableTableViews = sortableTableViews
        {
            self.sortableTableViews = sortableTableViews
        }
        self.containingView = view
    
        self.setupGestureRecognizer()
    }
    
    func setupGestureRecognizer()
    {
//        self.containingView.window?.acceptsMouseMovedEvents = true
        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown])
        {
            (event) -> NSEvent in
            print("main monitior fired")
            if (self.containingView.bounds.contains(event.locationInWindow))
            {
                self.handleMouseEvent(event: event)
            } else { NSLog("not in window") }
            return event
        }
    }
    
    func handleMouseEvent(event:NSEvent)
    {
        let pressedLocationInParentView = event.locationInWindow
        let tableViewPressed = self.sortableTableViewAtPoint(pressedLocationInParentView)
        
        NSLog("tableViewPressed: \(tableViewPressed)")
        
        switch event.type
        {
        case .leftMouseDown:
            NSLog("leftMouseDown")
//            if let tableViewPressed = tableViewPressed
//            {
            
//                self.handleClickEventBegan(event: event, sortableTableViewPressed: tableViewPressed)
                while true {
                    let event = self.containingView.window!.nextEvent(matching: [.leftMouseUp, .leftMouseDragged])
                    if event?.type == .leftMouseDragged {
                        NSLog("dragged inside thing")
                    }
                    else if event?.type == .leftMouseUp {
                        
                        NSLog( "MyButton Mouse Up" )
                        
                        break
                    }
                }
//            }
            
        case .leftMouseDragged:
            NSLog("dragged")
            self.handleClickEventDragged(event: event)
        case .otherMouseDragged:
            NSLog("otherMouseDragged")
        case .leftMouseUp:
            NSLog("leftMouseUp")
        default:
            NSLog("default: \(event.type    )")
            
        }
    }
    
    
    //------------------------------------------------------------------------------
    
    func handleClickEventBegan(event:NSEvent, sortableTableViewPressed:SortableTableView)
    {
        let pointInTableView = sortableTableViewPressed.convert(event.locationInWindow, from: nil)
        let pressedRow = sortableTableViewPressed.row(at: pointInTableView)
        NSLog("pressed Row: \(pressedRow)")
        if (pressedRow >= 0)
        {
            if (sortableTableViewPressed.canBePickedUp(row: pressedRow))
            {
                self.pickupCell(atRow: pressedRow, event: event, sortableTableViewPressed: sortableTableViewPressed)
            }
        }
    }
    
    func handleClickEventDragged(event:NSEvent)
    {
        if let cellSnapshot = self.itemInMotion?.cellSnapshot
        {
            NSAnimationContext.runAnimationGroup(
                {
                    (context) -> Void in
                    let centerInContainerView = event.locationInWindow
                    let originInContainerView = cellSnapshot.frame.originFromCenter(center: centerInContainerView)
                    cellSnapshot.animator().frame.origin = originInContainerView
            },
                completionHandler:
                {
                    () -> Void in
         
            })
        }
    }
    
    func pickupCell(atRow:Int, event:NSEvent, sortableTableViewPressed:SortableTableView)
    {
        if let cell = sortableTableViewPressed.view(atColumn: 0, row: atRow, makeIfNecessary: false)
        {
            let cellSnapshot = self.createCellSnapshot(cell)
            
            let newOrigin = self.containingView.convert(cell.frame.origin, from: sortableTableViewPressed)
            
            cellSnapshot.frame.origin = newOrigin
            self.itemInMotion = SortableTableViewItem(originalTableView: sortableTableViewPressed, originalRow: atRow, originalCenter: cellSnapshot.frame.origin, cellSnapshot: cellSnapshot)
           
            cellSnapshot.alphaValue = 0.0
            self.containingView.addSubview(cellSnapshot, positioned: .above, relativeTo: nil)
//            self.containingView.addSubview(cellSnapshot)
            
            sortableTableViewPressed.onItemPickedUp(fromRow: atRow)
            
            NSAnimationContext.runAnimationGroup(
            {
                (context) -> Void in
                let centerInContainerView = event.locationInWindow
                let originInContainerView = cellSnapshot.frame.originFromCenter(center: centerInContainerView)
                cellSnapshot.animator().frame.origin = originInContainerView
                cellSnapshot.animator().alphaValue = 0.98
            },
            completionHandler:
            {
                () -> Void in
                NotificationCenter.default.post(name: SortableTableViewEvents.pickupAnimated, object: nil, userInfo: ["originalTableView": sortableTableViewPressed, atRow: atRow])
            })
        }
    }
    
    //------------------------------------------------------------------------------
    
    func sortableTableViewAtPoint(_ pointPressed:CGPoint) -> SortableTableView?
    {
        for sortableTableView in self.sortableTableViews
        {
            if (sortableTableView.frame.contains(sortableTableView.convert(pointPressed, from: self.containingView)))
            {
                return sortableTableView
            }
        }
        return nil
    }
    
    
    //------------------------------------------------------------------------------
    
    func createCellSnapshot(_ inputView: NSView) -> NSView
    {
        let image = inputView.snapshot
        
        let cellSnapshot:NSView = NSImageView(image: image)
        cellSnapshot.frame = inputView.frame
        cellSnapshot.layer?.masksToBounds = false
        cellSnapshot.layer?.cornerRadius = 0.0
        cellSnapshot.layer?.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer?.shadowRadius = 5.0
        cellSnapshot.layer?.shadowOpacity = 0.4
        cellSnapshot.wantsLayer = true
        return cellSnapshot
    }
}
