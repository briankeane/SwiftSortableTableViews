# SwiftSortableTableViews

<p align="center">
	<img src="https://media.giphy.com/media/l378mOPG0tVskHjDq/giphy.gif" />
</p>

### Overview:
SwiftSortableTableViews are extensions of UITableViews that provide the ability to pick up and drag UITableViewCells from one table to another.  Sample Project at: [https://github.com/briankeane/SwiftSortableTableViewsExample](https://github.com/briankeane/SwiftSortableTableViewsExample)

### Installation
add this to your cocoapods target:
```
pod 'SwiftSortableTableViews', '~>0.0.4'
```

### Setup
Set the Class of your UITableView in storyboard to `SortableTableView`.  Then in your `viewDidLoad` method, create your SortableTableViews, assign them each a SortableTableViewDataSource and SortableTableViewDelegate, and create a SortableTableViewHandler, passing it your ViewController's view and an array of the SortableTableViews you'd like to use.

```
import SwiftSortableTableViews

class ViewController: UIViewController,SortableTableViewDelegate, SortableTableViewDataSource  {

    @IBOutlet weak var numbersTableView: SortableTableView!
    @IBOutlet weak var lettersTableView: SortableTableView!
    
    var sortableHandler:SortableTableViewHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numbersTableView.sortableDelegate = self
        self.numbersTableView.sortableDataSource = self
        
        self.lettersTableView.sortableDelegate = self
        self.lettersTableView.sortableDataSource = self
        
        self.sortableHandler = SortableTableViewHandler(view: self.view,
                                                        sortableTableViews: [
                                                            self.numbersTableView,
                                                            self.lettersTableView
                                                        ])
    }
```

### SortableTableViewDataSource

You must handle the transfer of a data source when an item is moved from one list two another.  SortableTableViewDataSource allows you to handle this in either the receiving table or the releasing table by providing one of two SortableTableViewDataSource functions:

1. `func sortableTableView(_ willReleaseItem )`

	* this function is called on the releasing SortableTableView

2. `func sortableTableView(_ willReceiveItem )`
	* this function is called on the receiving TableView

If an object is moved to a new indexPath within the same table, then modify the underlying data in this function:

`func sortableTableView(_ willDropItem )`


### Other DataSource functions:

`func sortableTableView(_ shouldReceiveItem ) -> Bool`

*  return `false` to cancel the move

`func sortableTableView(_ shouldReleaseItem ) -> Bool`

* return `false` to cancel the move

`func sortableTableView(_ canBePickedUp ) -> Bool`

* return `false` and the item cannot be picked up.

`func sortableTableView(_ itemWasPickedUp ) -> Bool`

* called on the item's original table just after pickup is completed

`func sortableTableView(_ itemMoveDidCancel ) -> Bool`

* called on the original table just after the move was cancelled.


### SortableTableViewDelegate

These functions are provided in addition to the usual UITableViewDelegate functions:

`func sortableTableView(_ draggedItemDidEnterTableViewAtIndexPath ) -> Bool`

* called when an item is dragged over the TableView


`func sortableTableView(_ draggedItemDidExitTableViewFromIndexPath ) -> Bool`

* called when an item is dragged over the TableView

### Limitations
1. When providing a cell in cellForRowAt, do not use the dequeueReusableCell(withIdentifier:) that specifies a "forIndexPath:" in it -- the cells will move around and providing a specified IndexPath will break internal consistency.
2. Only supports one Section per table for now.
