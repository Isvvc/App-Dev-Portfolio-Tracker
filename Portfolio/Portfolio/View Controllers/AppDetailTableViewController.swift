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

    @objc private func updateAppStoreLink() {
        print("Update App Store link.")

        let alert = UIAlertController(title: "Update Link", message: nil, preferredStyle: .alert)

        var urlTextField: UITextField?
        alert.addTextField { textField in
            textField.placeholder = "App Store URL"
            urlTextField = textField
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            guard let urlString = urlTextField?.text,
                let url = URL(string: urlString)else { return }
            print(url)
            // TODO: Set the URL
        }

        alert.addAction(cancel)
        alert.addAction(done)

        present(alert, animated: true, completion: nil)
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
        descriptionTextView?.text = app.appDescription

        appStoreButton?.addTarget(self, action: #selector(openAppStore), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(updateAppStoreLink))
        appStoreButton?.addGestureRecognizer(longPress)
    }

}
