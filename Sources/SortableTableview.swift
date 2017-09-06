//
//  SortableTableView.swift
//  SwiftSortableTableViews
//
//  Created by Brian D Keane on 9/4/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

open class SortableTableView:UITableView, UITableViewDataSource
{
    var containingView:UIView?
    var connectedSortableTableViews:Array<SortableTableView> = Array()
    var movingSortableItem:SortableTableViewItem?
    var indexPathInMotion:IndexPath?
    
    private var _sortableDataSource:SortableTableViewDataSource?
    open var sortableDelegate:SortableTableViewDelegate?
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
    
    func moveCellSnapshot(_ newCenter:CGPoint, disappear:Bool, onCompletion:@escaping (Bool) -> Void = {Void in })
    {
        if let cellSnapshot = self.movingSortableItem?.cellSnapshot
        {
            UIView.animate(withDuration: 0.25,
                           animations:
                {
                    () -> Void in
                    cellSnapshot.center = CGPoint(x: self.center.x, y: newCenter.y)
                    
                    if (disappear == true)
                    {
                        cellSnapshot.transform = CGAffineTransform.identity
                        cellSnapshot.alpha = 0.0
                    }
            },
            completion:
            {
                (finished) -> Void in
                if (disappear == true)
                {
                    cellSnapshot.removeFromSuperview()
                }
                onCompletion(finished)
            })
        }
        
    }
    
    //------------------------------------------------------------------------------
    
    func createCellSnapshot(_ inputView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    //------------------------------------------------------------------------------
    
    func cancelMove()
    {
        // send it back
        if let item = self.movingSortableItem
        {
            self.moveCellSnapshot(item.originalCenter, disappear: true)
            {
                (finished) -> Void in
                if (finished)
                {
                    self.movingSortableItem = nil
                    self.reloadData()
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func setPlaceholder(indexPath:IndexPath)
    {
        print("setPlaceholder stub")
    }

    //------------------------------------------------------------------------------
    
    func canBePickedUp(indexPath:IndexPath) -> Bool
    {
        return true
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (self.sortableDataSource?.tableView(self, cellForRowAt: indexPath))!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = self.sortableDataSource?.tableView(self, numberOfRowsInSection: section)
        {
            return numberOfRows
        }
        return 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let numberOfSections = self.sortableDataSource?.numberOfSections?(in: self)
        {
            return numberOfSections
        }
        return 0
    }
}
