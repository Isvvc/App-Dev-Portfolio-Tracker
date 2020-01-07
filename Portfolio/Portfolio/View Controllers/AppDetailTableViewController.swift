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

    var nameTextView: UITextView?
    var artworkImageView: UIImageView?
    var ageRatingLabel: UILabel?
    var appStoreButton: UIButton?
    var descriptionTextView: UITextView?

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
            nameTextView = cell.textView
            artworkImageView = cell.artworkImageView
        } else if let cell = cell as? LinkTableViewCell {
            ageRatingLabel = cell.ageRating
            appStoreButton = cell.appStoreButton
        } else if let cell = cell as? TextViewTableViewCell {
            descriptionTextView = cell.textView
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last,
            indexPath == lastVisibleIndexPath {
            loadAppInfo()
        }
    }

    // MARK: Private

    @objc private func openAppStore() {
        guard let appStoreURL = app?.appStoreURL else { return }
        UIApplication.shared.open(appStoreURL)
    }

    private func loadAppInfo() {
        guard let app = app else { return }

        if let bundleID = app.id {
            artworkImageView?.image = appController?.retrieveImage(forKey: bundleID)
            artworkImageView?.layer.cornerRadius = 20
            artworkImageView?.layer.masksToBounds = true
        }

        nameTextView?.text = app.name
        ageRatingLabel?.text = app.ageRating
        appStoreButton?.addTarget(self, action: #selector(openAppStore), for: .touchUpInside)
        descriptionTextView?.text = app.appDescription
    }

}
