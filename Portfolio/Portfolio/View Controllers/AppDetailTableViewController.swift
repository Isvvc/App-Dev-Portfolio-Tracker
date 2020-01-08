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
    var app: App? {
        didSet {
            appStoreURL = app?.appStoreURL
            ratings = app?.userRatingCount
            bundleID = app?.id
        }
    }

    var appStoreURL: URL?
    var ratings: Int16?
    var bundleID: String?

    var editMode: Bool = true

    var nameTextView: UITextView?
    var artworkImageView: UIImageView?
    var ageRatingLabel: UILabel?
    var appStoreButton: UIButton?
    var descriptionTextView: UITextView?
    var ratingsLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if app != nil {
            toggleEditMode()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This is to make sure the text views have their height automatically adjusted
        tableView.beginUpdates()
        tableView.endUpdates()
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
            cell.textView.delegate = self
            cell.textView.tag = 0
            textViewDidEndEditing(cell.textView)
            nameTextView = cell.textView
            artworkImageView = cell.artworkImageView
        } else if let cell = cell as? LinkTableViewCell {
            ageRatingLabel = cell.ageRating
            appStoreButton = cell.appStoreButton
            ratingsLabel = cell.ratingsLabel
        } else if let cell = cell as? TextViewTableViewCell {
            cell.textView.delegate = self
            cell.textView.tag = 1
            textViewDidEndEditing(cell.textView)
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
            updateEditMode()
            tableView.beginUpdates()
            tableView.endUpdates()
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
            self.appStoreURL = url
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

        if app.userRatingCount > 0 {
            ratingsLabel?.text = "\(app.userRatingCount) Ratings"
        } else {
            ratingsLabel?.text = nil
        }

        nameTextView?.text = app.name
        ageRatingLabel?.text = app.ageRating
        descriptionTextView?.text = app.appDescription
    }

    @objc private func save() {
        let context = CoreDataStack.shared.mainContext
        guard let name = nameTextView?.text,
            let appDescription = descriptionTextView?.text,
            let bundleID = bundleID,
            !name.isEmpty,
            !appDescription.isEmpty else { return }

        if let app = app {
            appController?.update(app: app,
                                  name: name,
                                  ageRating: ageRatingLabel?.text,
                                  description: appDescription,
                                  appStoreURL: appStoreURL,
                                  bundleID: bundleID,
                                  userRatingCount: ratings,
                                  context: context)
        } else {
            appController?.create(appNamed: name,
                                  ageRating: ageRatingLabel?.text,
                                  description: appDescription,
                                  appStoreURL: appStoreURL,
                                  artworkURL: nil,
                                  bundleID: bundleID,
                                  userRatingCount: ratings,
                                  artwork: nil,
                                  context: context)
        }

        toggleEditMode()
    }

    @objc private func toggleEditMode() {
        editMode.toggle()
        updateEditMode()
    }

    private func updateEditMode() {
        nameTextView?.isEditable = editMode
        descriptionTextView?.isEditable = editMode
        if editMode {
            appStoreButton?.setTitle("Tap to edit app store link", for: .normal)
            appStoreButton?.removeTarget(self, action: #selector(openAppStore), for: .touchUpInside)
            appStoreButton?.addTarget(self, action: #selector(updateAppStoreLink), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(save))
        } else {
            appStoreButton?.setTitle("Open in App Store", for: .normal)
            appStoreButton?.removeTarget(self, action: #selector(updateAppStoreLink), for: .touchUpInside)
            appStoreButton?.addTarget(self, action: #selector(openAppStore), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(toggleEditMode))
        }
    }

}

// MARK: Text view delegate

extension AppDetailTableViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // Manual placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let placeholderText: String
            if textView.tag == 0 {
                placeholderText = "App Name"
            } else {
                placeholderText = "Description"
            }
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
}