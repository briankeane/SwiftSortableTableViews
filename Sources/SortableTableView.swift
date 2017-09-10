//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

open class SortableTableView:UITableView, UITableViewDataSource, UITableViewDelegate
{
    var containingView:UIView?
    var connectedSortableTableViews:Array<SortableTableView> = Array()
    var movingSortableItem:SortableTableViewItem?
    var ignoreIndexPath:IndexPath?
    var placeholderIndexPath:IndexPath?
    
    var observers:Array<NSObjectProtocol> = Array()
    
    private var _sortableDataSource:SortableTableViewDataSource?
    private var _sortableDelegate:SortableTableViewDelegate?
    open var sortableDelegate:SortableTableViewDelegate?
    {
        get
        {
            return self._sortableDelegate
        }
        set
        {
            self._sortableDelegate = newValue
            self.delegate = self
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
            self.dataSource = self
        }
    }
    
    //------------------------------------------------------------------------------
    
    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.setupListeners()
    }
    
    //------------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    func handleCancelMoveWillAnimate(userInfo:[AnyHashable:Any])
    {
        if let originalTableView = userInfo["originalTableView"] as? SortableTableView
        {
            // IF it's this table, make a hole for the returning item
            if (originalTableView == self)
            {
                if let originalIndexPath = userInfo["originalIndexPath"] as? IndexPath
                {
                    self.removePlaceholder()
                    self.insertPlaceholder(indexPath: originalIndexPath)
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
                if let originalIndexPath = userInfo["originalIndexPath"] as? IndexPath
                {
                    self.placeholderIndexPath = nil
                    self.ignoreIndexPath = nil
                    self.reloadRows(at: [originalIndexPath], with: UITableViewRowAnimation.automatic)
                    self._sortableDataSource?.sortableTableView?(self, itemMoveDidCancel: originalIndexPath)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func onItemPickedUp(fromIndexPath:IndexPath)
    {
        print("onItemPickedUp")
        self.ignoreIndexPath = fromIndexPath
        self.placeholderIndexPath = fromIndexPath
        self.reloadRows(at: [fromIndexPath], with: .automatic)
        self._sortableDataSource?.sortableTableView?(self, itemWasPickedUp: fromIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    func onItemExited()
    {
        print("onItemExited")
        print("before exit: \(self.tableView(self, numberOfRowsInSection: 0))")
        let oldIndexPath = self.placeholderIndexPath
        self.beginUpdates()
        self.removePlaceholder()
        print("after exit: \(self.tableView(self, numberOfRowsInSection: 0))")
        self.endUpdates()
        if let oldIndexPath = oldIndexPath
        {
            
            self._sortableDelegate?.sortableTableView?(self, draggedItemDidExitTableViewFromIndexPath: oldIndexPath)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func onItemEntered(atIndexPath:IndexPath)
    {
        print("onItemEntered")
        self.beginUpdates()
        self.insertPlaceholder(indexPath: atIndexPath)
        self.endUpdates()
        self._sortableDelegate?.sortableTableView?(self, draggedItemDidEnterTableViewAtIndexPath: atIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    func onItemMovedWithin(newIndexPath: IndexPath)
    {
        print("onItemMovedWithin")
        self.beginUpdates()
        self.removePlaceholder()
        self.insertPlaceholder(indexPath: newIndexPath)
        self.endUpdates()
    }
    
    //------------------------------------------------------------------------------
    
    func onDropItemIntoTableView(atIndexPath:IndexPath)
    {
        print("onDropItemIntoTableView at indexPath: \(atIndexPath.row)")
        self.ignoreIndexPath = nil
        self.placeholderIndexPath = nil
        
        self.reloadRows(at: [atIndexPath], with: .automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func onReleaseItemFromTableView()
    {
        print("onReleaseItemFromTableView")
        self.ignoreIndexPath = nil
    }
    
    //------------------------------------------------------------------------------
    
    func removePlaceholder()
    {
        if let placeholderIndexPath = self.placeholderIndexPath
        {
            print("remove placeholder")
            self.placeholderIndexPath = nil
            self.deleteRows(at: [placeholderIndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func insertPlaceholder(indexPath:IndexPath)
    {
        print("insertPlaceholder at \(indexPath.row)")
        if (indexPath.row == 0)
        {
            print("here")
        }
        self.placeholderIndexPath = indexPath
        self.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //------------------------------------------------------------------------------
    
    func movePlaceholder(from:IndexPath, to:IndexPath)
    {
        self.removePlaceholder()
        self.insertPlaceholder(indexPath: to)
    }
    
    //------------------------------------------------------------------------------
    
    func adjustedNumberOfRows(_ numberOfRows:Int) -> Int
    {
        var adjustedNumberOfRows = numberOfRows
        if let _ = self.placeholderIndexPath
        {
            adjustedNumberOfRows += 1
        }
        if let _ = self.ignoreIndexPath
        {
            adjustedNumberOfRows -= 1
        }
        return adjustedNumberOfRows
    }
    
    //------------------------------------------------------------------------------
    
    func convertFromDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        var adjustedIndexPathRow = indexPath.row
        
        if let ignoreIndexPathRow = self.ignoreIndexPath?.row
        {
            if (adjustedIndexPathRow >= ignoreIndexPathRow)
            {
                adjustedIndexPathRow -= 1
            }
        }
        
        if let placeholderIndexPathRow = self.placeholderIndexPath?.row
        {
            if (adjustedIndexPathRow >= placeholderIndexPathRow)
            {
                adjustedIndexPathRow += 1
            }
        }
        return IndexPath(row: adjustedIndexPathRow, section: indexPath.section)
    }
    
    //------------------------------------------------------------------------------
    
    func convertToDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        var deAdjustedIndexPathRow = indexPath.row
        if let ignoreIndexPathRow = self.ignoreIndexPath?.row
        {
            if (deAdjustedIndexPathRow >= ignoreIndexPathRow)
            {
                deAdjustedIndexPathRow += 1
            }
        }
        
        if let placeholderIndexPathRow = self.placeholderIndexPath?.row
        {
            if (deAdjustedIndexPathRow >= placeholderIndexPathRow)
            {
                deAdjustedIndexPathRow -= 1
            }
        }
        return IndexPath(row: deAdjustedIndexPathRow, section: indexPath.section)
    }

    //------------------------------------------------------------------------------
    
    func setPlaceholder(_ indexPath:IndexPath)
    {
        print("setPlaceholder stub")
    }
    
    //------------------------------------------------------------------------------
    
    func placeholderCell() -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.isHidden = true
        return cell
    }

    //------------------------------------------------------------------------------
    
    func canBePickedUp(indexPath:IndexPath) -> Bool
    {
        // IF the delegate has impleneted canBePickedUp, use that
        if let sortableDataSource = sortableDataSource
        {
            let result = sortableDataSource.sortableTableView?(self, canBePickedUp: indexPath)
            if let result = result
            {
                return result
            }
        }
        // default to true
        return true
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath == self.placeholderIndexPath)
        {
            return self.placeholderCell()
        }
        print("cellForRowAt: \(self.convertToDelegateIndexPath(indexPath).row)")
        return (self.sortableDataSource?.tableView(self, cellForRowAt: self.convertToDelegateIndexPath(indexPath)))!
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let numberOfRows = self.sortableDataSource?.tableView(self, numberOfRowsInSection: section)
        {
            return self.adjustedNumberOfRows(numberOfRows)
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        if let numberOfSections = self.sortableDataSource?.numberOfSections?(in: self)
        {
            return numberOfSections
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Pass-Through DataSource methods
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self._sortableDataSource?.tableView?(self, canEditRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForHeaderInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self._sortableDataSource?.tableView?(self, titleForFooterInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        if let response = self._sortableDataSource?.tableView?(self, canMoveRowAt: indexPath)
        {
            return response
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return self._sortableDataSource?.sectionIndexTitles?(for: self)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let response = self._sortableDataSource?.tableView?(self, sectionForSectionIndexTitle: title, at: index)
        {
            return response
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        self._sortableDataSource?.tableView?(self, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        self._sortableDataSource?.tableView?(self, commit: editingStyle, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // delegate
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        print("heightForRowAt:  plainIndexPath: \(indexPath.row)   adjustedIndexPath: \(self.convertToDelegateIndexPath(indexPath).row)")
        if let height = self._sortableDelegate?.tableView?(self, heightForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            print("height: \(height)")
            return height
            
        }
        print("returning default height")
        return tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, willDisplay: cell, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        self._sortableDelegate?.tableView?(self, willDisplayHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        self._sortableDelegate?.tableView?(self, willDisplayFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, didEndDisplaying: cell, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    {
        self._sortableDelegate?.tableView?(self, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    {
        self._sortableDelegate?.tableView?(self, didEndDisplayingFooterView: view, forSection: section)
    }
    
    // Variable height support
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if let result = self._sortableDelegate?.tableView?(self, heightForHeaderInSection: section)
        {
            return result
        }
        return UITableViewAutomaticDimension
    }
   
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if let result = self._sortableDelegate?.tableView?(self, heightForFooterInSection: section)
        {
            return result
        }
        return UITableViewAutomaticDimension
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let result = self._sortableDelegate?.tableView?(self, estimatedHeightForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return UITableViewAutomaticDimension
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    {
        if let result = self._sortableDelegate?.tableView?(self, estimatedHeightForHeaderInSection: section)
        {
            return result
        }
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    {
        if let result = self._sortableDelegate?.tableView?(self, estimatedHeightForFooterInSection: section)
        {
            return result
        }
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
    {
        return self._sortableDelegate?.tableView?(self, viewForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? // custom view for footer. will be adjusted to default or specified footer height
    {
        return self._sortableDelegate?.tableView?(self, viewForFooterInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, accessoryButtonTappedForRowWith: self.convertToDelegateIndexPath(indexPath))
    }
    

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, shouldHighlightRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, didHighlightRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, didUnhighlightRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if let result = self._sortableDelegate?.tableView?(self, willSelectRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if let result =  self._sortableDelegate?.tableView?(self, willDeselectRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, didSelectRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, didDeselectRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    // Editing
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        if let result = self._sortableDelegate?.tableView?(self, editingStyleForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return .delete
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return self._sortableDelegate?.tableView?(self, titleForDeleteConfirmationButtonForRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
    {
        return self._sortableDelegate?.tableView?(self, editActionsForRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, shouldIndentWhileEditingRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return true
    }
    
    //------------------------------------------------------------------------------
    
    // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    {
        self._sortableDelegate?.tableView?(self, willBeginEditingRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    {
        var convertedIndexPath:IndexPath?
        if let indexPath = indexPath
        {
            convertedIndexPath = self.convertToDelegateIndexPath(indexPath)
        }
        self._sortableDelegate?.tableView?(self, didEndEditingRowAt: convertedIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    
    // Moving/reordering
    
    // Allows customization of the target row for a particular row as it is being moved/reordered
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if let result = self._sortableDelegate?.tableView?(self, targetIndexPathForMoveFromRowAt: self.convertToDelegateIndexPath(sourceIndexPath), toProposedIndexPath: self.convertToDelegateIndexPath(proposedDestinationIndexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return proposedDestinationIndexPath
    }
    
    // Indentation
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int // return 'depth' of row for hierarchies
    {
        if let result = self._sortableDelegate?.tableView?(self, indentationLevelForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return 0
    }
    
    // Copy/Paste.  All three methods must be implemented by the delegate.
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, shouldShowMenuForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, canPerformAction: action, forRowAt: self.convertToDelegateIndexPath(indexPath), withSender: sender)
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
    {
        self._sortableDelegate?.tableView?(self, performAction: action, forRowAt: self.convertToDelegateIndexPath(indexPath), withSender: sender)
    }
    
    //------------------------------------------------------------------------------
    
    // Focus
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, canFocusRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
    {
        if let result = self._sortableDelegate?.tableView?(self, shouldUpdateFocusIn: context)
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        self._sortableDelegate?.tableView?(self, didUpdateFocusIn: context, with: coordinator)
    }

    //------------------------------------------------------------------------------
    
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        if let result = self._sortableDelegate?.indexPathForPreferredFocusedView?(in: self)
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
}
