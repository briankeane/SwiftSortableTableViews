//
//  SortableTableViewOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

extension NSView
{
    func imageRepresentation() -> NSImage
    {
//        let wasHidden = self.isHidden
//        let wantedLayer = self.wantsLayer
//        
//        self.isHidden = false
//        self.wantsLayer = true
//        
//        let image = NSImage(size: self.bounds.size)
//        image.lockFocus()
//        
//        let context = NSGraphicsContext.current()!.cgContext
//        self.layer?.render(in: context)
//        image.unlockFocus()
//        
//        self.wantsLayer = wantedLayer
//        self.isHidden = wasHidden
        return NSImage(data: self.dataWithPDF(inside: self.bounds))!
//        return image
    }
}

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
    
    func hi()
    {
        
    }
    
    
    
    public override func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        puts("draggingSession")
        
        if let pointInWindow = self.window?.convertFromScreen(CGRect(origin: screenPoint, size: .zero)).origin
        {
            let pointInTableView = self.convert(pointInWindow, from: nil)
            let row = self.row(at: pointInTableView)
            
            if (row >= 0)
            {
                if let view = self.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView
                {
                    session.enumerateDraggingItems(options: .concurrent, for: self, classes: [NSPasteboardItem.self], searchOptions: [:]) { (item, index, stop) in
                        
        
                        
                        // prepare context
                        let context = NSGraphicsContext.current()
                        context?.saveGraphicsState()
                        
                        // offset to account for shadow
                        let imageOffset:CGFloat = 5
                        
                        // supply a background image
                        let contentSize = item.draggingFrame.size
                        let imageSize = NSMakeSize(contentSize.width, contentSize.height + imageOffset)
                        let image = NSImage(size: imageSize)
                        image.lockFocus()
                        
                        // define a shadow
                        let shadow = NSShadow()
                        shadow.shadowColor = NSColor.lightGray.withAlphaComponent(0.2)
                        shadow.shadowOffset = NSMakeSize(imageOffset, -imageOffset)
                        shadow.shadowBlurRadius = 3
                        shadow.set()
                        
                        // define content frame
                        let contentFrame = NSMakeRect(0, imageOffset, contentSize.width, contentSize.height)
                        var contentPath = NSBezierPath(rect: contentFrame)
                        
                        // draw content border and shadow
                        NSColor.lightGray.withAlphaComponent(1.0).set()
                        contentPath.stroke()
                        context?.restoreGraphicsState()
                        
                        // fill content
                        NSColor.white.set()
                        contentPath = NSBezierPath(rect: NSInsetRect(contentFrame, 1, 1))
                        contentPath.fill()
                        
                        view.layer?.render(in: NSGraphicsContext.current()!.cgContext)
                        
                        image.unlockFocus()
                        
                        // update the dragging item frame to accomodate larger image
                        item.draggingFrame = NSMakeRect(item.draggingFrame.origin.x , item.draggingFrame.origin.y, imageSize.width, imageSize.height)
                        
                        // define additional image component for drag
                        
                        

                        let backgroundImageComponent = NSDraggingImageComponent(key: "background")
                        backgroundImageComponent.contents = image
                        backgroundImageComponent.frame = NSMakeRect(0, 0, image.size.width, image.size.height)
//
                        // override draggingImageCoponents
                        item.imageComponentsProvider = {
                            return [backgroundImageComponent]
                        }
                        
                    }
                }
            }
        }
    }
    
    func createCellSnaphot(_ inputView:NSView) -> NSImage
    {
        inputView.canDrawSubviewsIntoLayer = true
        let image = NSImage(size: inputView.bounds.size)
        
        image.lockFocus()
//        let ctx:CGContext = NSGraphicsContext.current()!.graphicsPort
        inputView.layer?.render(in: NSGraphicsContext.current()!.cgContext)
        image.unlockFocus()
        return image
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
                    self.removeRows(at: IndexSet(integer: originalRow), withAnimation: NSTableViewAnimationOptions.slideUp)
                    
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
            self.removeRows(at: IndexSet(integer: placeholderRow), withAnimation: NSTableViewAnimationOptions.slideUp)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(atRow:Int)
    {
        self.placeholderRow = atRow
        self.insertRows(at: IndexSet(integer: atRow), withAnimation: .slideDown)
    }

    //------------------------------------------------------------------------------
    
    func movePlaceholder(toRow:Int)
    {
        self.removePlaceholder()
        self.insertPlaceholder(atRow: toRow)
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
        // IF the delegate has impleneted canBePickedUp, use that
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
}
