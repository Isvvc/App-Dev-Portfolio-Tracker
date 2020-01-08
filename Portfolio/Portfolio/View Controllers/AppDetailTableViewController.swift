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
            myContributions = app?.contributions
            if let libraries = app?.mutableSetValue(forKey: "libraries") {
                self.libraries = libraries
            }
        }
    }

    var appStoreURL: URL?
    var ratings: Int16?
    var bundleID: String?
    var myContributions: String?
    var libraries: NSMutableSet = NSMutableSet()
    var librariesArray: [Library] {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let array = libraries.sortedArray(using: [sortDescriptor])
        return array.compactMap({ $0 as? Library })
    }

    var editMode: Bool = true
    var showMyContributions: Bool {
        return editMode || myContributions != nil
    }

    var nameTextView: UITextView?
    var artworkImageView: UIImageView?
    var ageRatingLabel: UILabel?
    var appStoreButton: UIButton?
    var descriptionTextView: UITextView?
    var ratingsLabel: UILabel?
    var contributionsTextView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()

        editMode = (app == nil)

        if let app = app {
            title = app.name
        } else {
            title = "New App"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        // This is to make sure the text views have their height automatically adjusted
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return showMyContributions ? 5 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == (showMyContributions ? 4 : 3) {
            if editMode {
                return librariesArray.count + 1
            } else {
                return librariesArray.count
            }
        }

        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "App Description"
        case showMyContributions ? 3 : -1:
            return "My Contributions"
        case showMyContributions ? 4 : 3:
            return "API/Libraries Used"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell

        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
                as? TitleTableViewCell else { return UITableViewCell() }
            cell.textView.delegate = self
            cell.textView.tag = 0
            if app == nil {
                cell.textView.text = ""
            }
            textViewDidEndEditing(cell.textView)
            nameTextView = cell.textView
            artworkImageView = cell.artworkImageView
            returnCell = cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
            as? LinkTableViewCell else { return UITableViewCell() }
            ageRatingLabel = cell.ageRating
            appStoreButton = cell.appStoreButton
            ratingsLabel = cell.ratingsLabel
            returnCell = cell
        case 2...(showMyContributions ? 3 : 2):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath)
                as? TextViewTableViewCell else { return UITableViewCell() }
                if indexPath.section == 2 {
                    cell.textView.delegate = self
                    cell.textView.tag = 1
                    if app == nil {
                        cell.textView.text = ""
                    }
                    textViewDidEndEditing(cell.textView)
                    descriptionTextView = cell.textView
                } else {
                    cell.textView.delegate = self
                    cell.textView.tag = 2
                    if app == nil {
                        cell.textView.text = ""
                    }
                    textViewDidEndEditing(cell.textView)
                    contributionsTextView = cell.textView
                }
            returnCell = cell
        default:
            if editMode && indexPath.row == librariesArray.count {
                returnCell = tableView.dequeueReusableCell(withIdentifier: "SelectLibraryCell", for: indexPath)
            } else {
                returnCell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
                let library = librariesArray[indexPath.row]
                returnCell.textLabel?.text = library.name
            }
        }

        return returnCell
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(editMode
            && indexPath.section == (showMyContributions ? 4 : 3)
            && indexPath.row == 1) {
            tableView.deselectRow(at: indexPath, animated: true)
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
        nameTextView?.textColor = UIColor.label
        ageRatingLabel?.text = app.ageRating
        descriptionTextView?.text = app.appDescription
        descriptionTextView?.textColor = UIColor.label
        contributionsTextView?.text = myContributions
        contributionsTextView?.textColor = UIColor.label
    }

    @objc private func save() {
        let context = CoreDataStack.shared.mainContext
        guard let name = nameTextView?.text,
            nameTextView?.textColor == UIColor.label,
            let appDescription = descriptionTextView?.text,
            descriptionTextView?.textColor == UIColor.label,
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
                                  contributions: myContributions,
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
            navigationController?.popViewController(animated: true)
        }

        toggleEditMode()
    }

    @objc private func toggleEditMode() {
        editMode.toggle()
        tableView.reloadData()
        updateEditMode()
    }

    private func updateEditMode() {
        nameTextView?.isEditable = editMode
        descriptionTextView?.isEditable = editMode
        contributionsTextView?.isEditable = editMode

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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let librariesVC = segue.destination as? LibrariesTableViewController {
            librariesVC.libraries = self.libraries
        }
    }

}

// MARK: Text view delegate

extension AppDetailTableViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        if textView.tag == 2 {
            myContributions = textView.text
        }
    }

    // Manual placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let placeholderText: String
            switch textView.tag {
            case 0:
                placeholderText = "App Name"
            case 1:
                placeholderText = "App Description"
            default:
                placeholderText = "My Contributions"
                myContributions = nil
            }
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
}
