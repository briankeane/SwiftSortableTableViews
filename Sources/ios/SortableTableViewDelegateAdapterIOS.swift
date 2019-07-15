//
//  SortableTableViewDelegateAdapterIOS.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 10/10/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

class SortableTableViewDelegateAdapter: NSObject, UITableViewDelegate
{
    var tableView:SortableTableView
    var delegate:SortableTableViewDelegate
    
    init(tableView:SortableTableView, delegate:SortableTableViewDelegate)
    {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    //------------------------------------------------------------------------------
    
    func convertToDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        let convertedRow = self.tableView.convertToDelegateRow(indexPath.row)
        return IndexPath(row: convertedRow, section: 0)
    }
    
    //------------------------------------------------------------------------------
    
    func convertFromDelegateIndexPath(_ indexPath:IndexPath) -> IndexPath
    {
        let convertedRow = self.tableView.convertFromDelegateRow(indexPath.row)
        return IndexPath(row: convertedRow, section: 0)
    }
    
    //------------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
         self.delegate.tableView?(self.tableView, didSelectRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, didDeselectRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, didHighlightRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    {
        var convertedIndexPath:IndexPath?
        if let indexPath = indexPath
        {
            convertedIndexPath = self.convertToDelegateIndexPath(indexPath)
        }
        self.delegate.tableView?(self.tableView, didEndEditingRowAt: convertedIndexPath)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, didUnhighlightRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, canFocusRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, willBeginEditingRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let height = self.delegate.tableView?(self.tableView, heightForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return height
            
        }
        return tableView.rowHeight
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? // custom view for footer. will be adjusted to default or specified footer height
    {
        return self.delegate.tableView?(self.tableView, viewForFooterInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
    {
        return self.delegate.tableView?(self.tableView, viewForHeaderInSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if let result = self.delegate.tableView?(self.tableView, heightForFooterInSection: section)
        {
            return result
        }
        return UITableView.automaticDimension
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if let result = self.delegate.tableView?(self.tableView, heightForHeaderInSection: section)
        {
            return result
        }
        return UITableView.automaticDimension
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, shouldHighlightRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if let result = self.delegate.tableView?(self.tableView, willSelectRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, shouldShowMenuForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, accessoryButtonTappedForRowWith: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int // return 'depth' of row for hierarchies
    {
        if let result = self.delegate.tableView?(self.tableView, indentationLevelForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return 0
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if let result =  self.delegate.tableView?(self.tableView, willDeselectRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let result = self.delegate.tableView?(self.tableView, estimatedHeightForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return UITableView.automaticDimension
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    {
        if let result = self.delegate.tableView?(self.tableView, estimatedHeightForHeaderInSection: section)
        {
            return result
        }
        return UITableView.automaticDimension
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    {
        if let result = self.delegate.tableView?(self.tableView, estimatedHeightForFooterInSection: section)
        {
            return result
        }
        return UITableView.automaticDimension
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, shouldIndentWhileEditingRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return true
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        self.delegate.tableView?(self.tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        self.delegate.tableView?(self.tableView, willDisplayFooterView: view, forSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    {
        self.delegate.tableView?(self.tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    {
        self.delegate.tableView?(self.tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, willDisplay: cell, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, shouldUpdateFocusIn: context)
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
    {
        return self.delegate.tableView?(self.tableView, editActionsForRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self.delegate.tableView?(self.tableView, didEndDisplaying: cell, forRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if let result = self.delegate.tableView?(self.tableView, editingStyleForRowAt: self.convertToDelegateIndexPath(indexPath))
        {
            return result
        }
        return .delete
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return self.delegate.tableView?(self.tableView, titleForDeleteConfirmationButtonForRowAt: self.convertToDelegateIndexPath(indexPath))
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    {
        if let result = self.delegate.tableView?(self.tableView, canPerformAction: action, forRowAt: self.convertToDelegateIndexPath(indexPath), withSender: sender)
        {
            return result
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
    {
        self.delegate.tableView?(self.tableView, performAction: action, forRowAt: self.convertToDelegateIndexPath(indexPath), withSender: sender)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        self.delegate.tableView?(self.tableView, didUpdateFocusIn: context, with: coordinator)
    }
    
    //------------------------------------------------------------------------------
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if let result = self.delegate.tableView?(self.tableView, targetIndexPathForMoveFromRowAt: self.convertToDelegateIndexPath(sourceIndexPath), toProposedIndexPath: self.convertToDelegateIndexPath(proposedDestinationIndexPath))
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return proposedDestinationIndexPath
    }
    
    //------------------------------------------------------------------------------
    
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        if let result = self.delegate.indexPathForPreferredFocusedView?(in: self.tableView)
        {
            return self.convertFromDelegateIndexPath(result)
        }
        return nil
    }
    
}
