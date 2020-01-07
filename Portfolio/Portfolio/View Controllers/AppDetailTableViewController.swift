//
//  AppDetailTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class AppDetailTableViewController: UITableViewController {

    // MARK: Properties
    var appController: AppController?
    var app: App?

    var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "App Description"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String

        switch indexPath.section {
        case 0:
            cellIdentifier = "TitleCell"
        case 1:
            cellIdentifier = "LinkCell"
        default:
            cellIdentifier = "TextViewCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if let cell = cell as? TitleTableViewCell {
            if let appName = app?.name {
                cell.textView.text = appName
            }

            if let bundleID = app?.id {
                cell.artworkImageView.image = appController?.retrieveImage(forKey: bundleID)
                cell.artworkImageView.layer.cornerRadius = 20
                cell.artworkImageView.layer.masksToBounds = true
            }
        } else if let cell = cell as? LinkTableViewCell {
            cell.ageRating.text = app?.ageRating
            cell.appStoreButton.addTarget(self, action: #selector(openAppStore), for: .touchUpInside)
        } else if let cell = cell as? TextViewTableViewCell {
            cell.textView.text = app?.appDescription
        }

        return cell
    }

    // MARK: Private

    @objc private func openAppStore() {
        guard let appStoreURL = app?.appStoreURL else { return }
        UIApplication.shared.open(appStoreURL)
    }

}
