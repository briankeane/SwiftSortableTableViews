//
//  SortableTableViewOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa
import AVKit

public class SortableTableView: NSTableView
{
    var movingSortableItem:SortableTableViewItem?
    var ignoreRow:Int?
    var placeholderRow:Int?
    
    private var _sortableDataSource:SortableTableViewDataSource?
    private var _sortableDelegate:SortableTableViewDelegate?
    private var _sortableDataSourceAdapter:SortableTableViewDataSourceAdapter?
    private var _sortableDelegateAdapter:SortableTableViewDelegateAdapter?
    open var sortableDelegate:SortableTableViewDelegate?
    {
        get
        {
            return self._sortableDelegate
        }
        set
        {
            self._sortableDelegate = newValue
            
            if let newValue = newValue
            {
                self._sortableDelegateAdapter = SortableTableViewDelegateAdapter(tableView: self, delegate: newValue)
                self.delegate = self._sortableDelegateAdapter!
            }
            else
            {
                self._sortableDataSourceAdapter = nil
            }
        }
    }
    open var sortableDataSource:SortableTableViewDataSource?
    {
        get
        {
            return self._sortableDataSource
        }
        set
        {
            self._sortableDataSource = newValue
            if let newValue = newValue
            {
                self._sortableDataSourceAdapter = SortableTableViewDataSourceAdapter(tableView: self, dataSource: newValue)
                self.dataSource = self._sortableDataSourceAdapter!
            }
            else
            {
                self._sortableDataSourceAdapter = nil
            }
        }
    }
    
    public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        puts("draggingUpdated")
        puts("\(NSEvent.pressedMouseButtons)")
        return super.draggingUpdated(sender)
    }
    
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        puts("performDragOperation")
        return super.performDragOperation(sender)
    }
    
    public override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        super.concludeDragOperation(sender)
        puts("concludeDrag")
    }
    
    
    
    public override func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        puts("draggingSessionEnded")
        if (!SortableTableViewHandler.sharedInstance().itemDropInProgress)
        {
            SortableTableViewHandler.sharedInstance().performCancelMove()
        }
//        NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveWillAnimate, object:nil, userInfo: ["originalTableView": self,
//                                            "originalRow": originalRow])
//        NotificationCenter.default.post(name: SortableTableViewEvents.cancelMoveDidAnimate, object: nil, userInfo: ["originalTableView": self,
//                                                                                                                    "originalRow": originalRow])

    }
    
    public override func draggingEnded(_ sender: NSDraggingInfo?) {
//        sender?.animatesToDestination = true
//        sender?.slideDraggedImage(to: NSPoint(x:0, y:0))
        puts("draggingEnded")
    }
    
    public override func mouseUp(with event: NSEvent) {
        puts("mouseUp")
        super.mouseUp(with: event)
        
    }
    
    public override func otherMouseUp(with event: NSEvent) {
        puts("otherMouseUp")
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        puts("rightMouseUp")
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDown(with: event)
        puts("mouseDragged")
    }
    
    public override func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        puts("draggingSession")
        
        if let pointInWindow = self.window?.convertFromScreen(CGRect(origin: screenPoint, size: .zero)).origin
        {
            let pointInTableView = self.convert(pointInWindow, from: nil)
            let row = self.row(at: pointInTableView)
            
            if (row >= 0)
            {
                if let view = self.view(atColumn: 0, row: row, makeIfNecessary: false)
                {
                    session.enumerateDraggingItems(options: .concurrent, for: self, classes: [NSPasteboardItem.self], searchOptions: [:]) { (item, index, stop) in
                        
                        let image = self.createCellSnaphot(view)
                        
                        // SortableItem is already set in pastboardForRow
//                        let sortableItem = SortableTableViewItem(originalTableView: self, originalRow: row, originalCenter: screenPoint, cellSnapshot: view, transferringItem: nil)
//                        
//                        SortableTableViewHandler.sharedInstance().itemInMotion = sortableItem
//                        
                        item.draggingFrame = NSMakeRect(item.draggingFrame.origin.x, item.draggingFrame.origin.y, image.size.width, image.size.height)
                        
                        let backgroundImageComponent = NSDraggingImageComponent(key: NSDraggingItem.ImageComponentKey(rawValue: "background"))
                        backgroundImageComponent.contents = image
                        backgroundImageComponent.frame = NSMakeRect(0, 0, image.size.width, image.size.height)
//
                        // override draggingImageCoponents
                        item.imageComponentsProvider = {
                            return [backgroundImageComponent]
                        }
                    }
                    session.animatesToStartingPositionsOnCancelOrFail = false
                    self.onItemPickedUp(fromRow: row)
                }
            }
            
            
            
        
        }
    }
    
    func createCellSnaphot(_ inputView:NSView) -> NSImage
    {
        inputView.canDrawSubviewsIntoLayer = true
        let image = NSImage(size: inputView.bounds.size)
        
        image.lockFocus()

        inputView.layer?.render(in: NSGraphicsContext.current!.cgContext)
        image.unlockFocus()
        
        // create a new view for shadows
        let snapshotView:NSView = NSImageView(image: image)
        (snapshotView as! NSImageView).sizeToFit()
        snapshotView.wantsLayer = true
        snapshotView.layer?.masksToBounds = false
        snapshotView.layer?.cornerRadius = 0.0
        snapshotView.layer?.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshotView.layer?.shadowRadius = 5.0
        snapshotView.layer?.shadowOpacity = 0.4
        snapshotView.layer?.bounds.size = snapshotView.fittingSize
        
        let newImage = NSImage(size: snapshotView.layer!.preferredFrameSize())
        newImage.lockFocus()
        snapshotView.layer?.render(in: NSGraphicsContext.current!.cgContext)
        newImage.unlockFocus()
        
        return newImage
    }

    //------------------------------------------------------------------------------
    
    /// MARK: Initializers

    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.setupListeners()
    }
    
    //------------------------------------------------------------------------------
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setupListeners()
    }
    
    //------------------------------------------------------------------------------
    
    func setupListeners()
    {
        let _ = SortableTableViewHandler.sharedInstance()
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.cancelMoveWillAnimate , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleCancelMoveWillAnimate(userInfo: userInfo)
                }
            }
        )
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.cancelMoveDidAnimate , object: nil, queue: .main)
            {
                (notification) -> Void in
                if let userInfo = notification.userInfo
                {
                    self.handleCancelMoveDidAnimate(userInfo: userInfo)
                }
            }
        )
        
        self.observers.append(
            NotificationCenter.default.addObserver(forName: SortableTableViewEvents.dropItemDidAnimate, object: nil, queue: .main)
            {
                (notification) -> Void in
                self.handleDropItemDidAnimate()
            }
        )
        
//        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { (event) -> NSEvent? in
//            puts("mouseUp")
//            return nil
//        }
    }

    //------------------------------------------------------------------------------
    
    var observers:Array<NSObjectProtocol> = Array()
    
    //------------------------------------------------------------------------------
    
    func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //------------------------------------------------------------------------------
    
    deinit
    {
        self.removeObservers()
    }
    
    //------------------------------------------------------------------------------
    
    public override func draggingExited(_ sender: NSDraggingInfo?) {
        self.onItemExited()
    }
    
    func convertFromDelegateRow(_ row:Int) -> Int
    {
        var adjustedRow = row
        
        if let ignoreRow = self.ignoreRow
        {
            if (adjustedRow >= ignoreRow)
            {
                adjustedRow -= 1
            }
        }
        
        if let placeholderRow = self.placeholderRow
        {
            if (adjustedRow >= placeholderRow)
            {
                adjustedRow += 1
            }
        }
        return adjustedRow
    }
    
    //------------------------------------------------------------------------------
    
    func convertToDelegateRow(_ row:Int) -> Int
    {
        var deAdjustedRow = row
        
        if let ignoreRow = self.ignoreRow
        {
            if (deAdjustedRow >= ignoreRow)
            {
                deAdjustedRow += 1
            }
        }
        
        if let placeholderRow = self.placeholderRow
        {
            if (deAdjustedRow >= placeholderRow)
            {
                deAdjustedRow -= 1
            }
        }
        return  deAdjustedRow
    }
    
    func handleDropItemDidAnimate()
    {
        self.removePlaceholder()
        self.ignoreRow = nil
        self.reloadData()
    }
    
    //------------------------------------------------------------------------------
    
    func handleCancelMoveWillAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            // IF it's this table, make a hole for the returning item
            if (originalTableView == self)
            {
                if let originalRow = userInfo["originalRow"] as? Int
                {
                    self.removePlaceholder()
                    self.insertPlaceholder(atRow: originalRow)
                }
            }
                // ELSE just smoothly reset the table to it's original state
            else
            {
                self.removePlaceholder()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func handleCancelMoveDidAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            if (originalTableView == self)
            {
                if let originalRow = userInfo["originalRow"] as? Int
                {
                    self.placeholderRow = nil
                    self.ignoreRow = nil
                    
//                    self.animator().removeRows(at: IndexSet(integer: originalRow), withAnimation: NSTableViewAnimationOptions.slideUp)
                    self.reloadData()
                    self._sortableDataSource?.sortableTableView?(self, itemMoveDidCancel: originalRow)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func removePlaceholder()
    {
        if let placeholderRow = self.placeholderRow
        {
            self.placeholderRow = nil
            self.animator().removeRows(at: IndexSet(integer: placeholderRow), withAnimation: NSTableView.AnimationOptions.slideUp)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(atRow:Int)
    {
        var moveTo = atRow
        
        // enforce max
        if let dataSource = self.dataSource
        {
            if (moveTo > dataSource.numberOfRows!(in: self))
            {
                moveTo = dataSource.numberOfRows!(in: self)
            }
        }
        self.placeholderRow = moveTo
        self.animator().insertRows(at: IndexSet(integer: moveTo), withAnimation: .slideDown)
    }
    
    func onItemPickedUp(fromRow:Int)
    {
        puts("onItemPickedUp")
        self.ignoreRow = fromRow
        self.placeholderRow = fromRow
        
        // TODO: Make this work for the single row
        self.reloadData()
//        self.reloadData(forRowIndexes: IndexSet(integer: fromRow), columnIndexes: IndexSet(integer: 0))
        self._sortableDataSource?.sortableTableView?(self, itemWasPickedUp: fromRow)
    }

    //------------------------------------------------------------------------------
    
    func movePlaceholder(toRow:Int)
    {
        self.removePlaceholder()
        self.insertPlaceholder(atRow: toRow)
    }
    
    func onItemMovedWithin(newRow: Int)
    {
        self.beginUpdates()
        self.removePlaceholder()
        self.insertPlaceholder(atRow: newRow)
        self.endUpdates()
    }
    
    func onItemExited()
    {
        let oldRow = self.placeholderRow
        self.beginUpdates()
        self.removePlaceholder()
        self.endUpdates()
        if let oldRow = oldRow
        {
            self._sortableDelegate?.sortableTableView?(self, draggedItemDidExitTableViewFromRow: oldRow)
        }
    }
    
    //------------------------------------------------------------------------------
    
    override public func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
    }
    
    //------------------------------------------------------------------------------
    
    func canBePickedUp(fromRow:Int) -> Bool
    {
        // IF the delegate has implemeted canBePickedUp, use that
        if let sortableDataSource = sortableDataSource
        {
            let result = sortableDataSource.sortableTableView?(self, canBePickedUp: fromRow)
            if let result = result
            {
                return result
            }
        }
        // default to true
        return true
    }
    
    func placeholderCell() -> NSTableCellView
    {
        puts("placeholderCell()")
        let cell = NSTableCellView()
        cell.isHidden = true
        return cell
    }
    
    
}
