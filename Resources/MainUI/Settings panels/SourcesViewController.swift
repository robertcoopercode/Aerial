//
//  SourcesViewController.swift
//  Aerial
//
//  Created by Guillaume Louel on 18/07/2020.
//  Copyright © 2020 Guillaume Louel. All rights reserved.
//

import Cocoa

class SourcesViewController: NSViewController {

    @IBOutlet var sourceOutlineView: NSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sourceOutlineView.dataSource = self
        sourceOutlineView.delegate = self
    }

    @IBAction func downloadAllClick(_ sender: NSButton) {
        print("download All from sources")

    }
}

extension SourcesViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    // item == nil means it's the "root" row of the outline view, which is not visible
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return SourceList.list[index]
        } else {
            return 0
        }
    }

    // Tell how many children each row has:
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return SourceList.list.count
        } else {
            return 0
        }
    }

    // Tell whether the row is expandable.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    // Set the content for each row/column element
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }

        let source = item as! Source

        switch columnIdentifier {
        case "isSelected":
            let cell = outlineView.makeView(withIdentifier:
                                                NSUserInterfaceItemIdentifier(rawValue: "isSelectedCell"), owner: self) as! CheckboxCellView
            cell.checkboxButton.state = source.isEnabled() ? .on : .off
            cell.delegate = self
            cell.item = item
            return cell

        case "valueColumn":
            let cell = outlineView.makeView(withIdentifier:
                                                NSUserInterfaceItemIdentifier(rawValue: "valueColumnCell"), owner: self) as! DescriptionCellView
            cell.titleLabel.stringValue = source.name
            cell.descriptionLabel.stringValue = source.description
            cell.lastUpdatedLabel.stringValue = "Last updated: " + source.lastUpdated()
            cell.imageScene1.isHidden = !source.scenes.contains(.landscape)
            cell.imageScene2.isHidden = !source.scenes.contains(.city)
            cell.imageScene3.isHidden = !source.scenes.contains(.space)
            cell.imageScene4.isHidden = !source.scenes.contains(.sea)

            return cell
        case "actionColumn":
            let cell = outlineView.makeView(withIdentifier:
                        NSUserInterfaceItemIdentifier(rawValue: columnIdentifier), owner: self) as! ActionCellView
            if source.type == .local {
                cell.actionButton.image = Aerial.getSymbol("folder")
            } else {
                cell.actionButton.image = Aerial.getSymbol("arrow.down.circle")
            }
            return cell

        default:
            let cell = outlineView.makeView(withIdentifier:
                        NSUserInterfaceItemIdentifier(rawValue: columnIdentifier), owner: self) as! NSTableCellView
            cell.textField?.stringValue = ""
            return cell
        }
    }
}

extension SourcesViewController: CheckboxCellViewDelegate {
    /// A delegate function where we can act on update from the checkbox in the "Is Selected" column
    func checkboxCellView(_ cell: CheckboxCellView, didChangeState state: NSControl.StateValue) {
        guard let item = cell.item as? Source else { return }

        // The row and its children are selected if state == .on
        item.setEnabled(state == .on)

        // This is more efficient than calling reload on every child since collapsed children are
        // not reloaded. They will be reloaded when they become visible
        sourceOutlineView.reloadItem(item, reloadChildren: true)
    }
}
