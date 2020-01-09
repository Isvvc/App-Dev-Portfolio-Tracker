//
//  ScreenshotsTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ScreenshotsTableViewController: UITableViewController {

    var screenshots: [Screenshot]?
    var appController: AppController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenshots?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScreenshotCell", for: indexPath)
            as? ScreenshotTableViewCell else { return UITableViewCell() }

        if let screenshot = screenshots?[indexPath.row],
            let url = screenshot.url,
            let imageData = try? Data(contentsOf: url) {
            let image = UIImage(data: imageData)
            cell.screenshotImageView.image = image
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }

        return .none
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let screenshot = screenshots?[indexPath.row] {
                appController?.delete(screenshot: screenshot, context: CoreDataStack.shared.mainContext)
                screenshots?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

}
