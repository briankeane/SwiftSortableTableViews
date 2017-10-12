//
//  SortableTableViewOSX.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

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
                        
                        let image = self.createCellSnaphot(view)
                        
                        item.draggingFrame = NSMakeRect(item.draggingFrame.origin.x, item.draggingFrame.origin.y, image.size.width, image.size.height)
                        
                        let backgroundImageComponent = NSDraggingImageComponent(key: "background")
                        backgroundImageComponent.contents = image
                        backgroundImageComponent.frame = NSMakeRect(0, 0, image.size.width, image.size.height)
//
                        // override draggingImageCoponents
                        item.imageComponentsProvider = {
                            return [backgroundImageComponent]
                        }
                        
                    }
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

        inputView.layer?.render(in: NSGraphicsContext.current()!.cgContext)
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
        snapshotView.layer?.render(in: NSGraphicsContext.current()!.cgContext)
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
        self.register(forDraggedTypes: [kUTTypeText as String])
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
    
    func placeholderCell() -> NSTableCellView
    {
        puts("placeholderCell()")
        let cell = NSTableCellView()
        cell.isHidden = true
        return cell
    }
}
