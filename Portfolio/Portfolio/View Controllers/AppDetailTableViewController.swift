//
//  AppDetailTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import AVKit

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
            if let bundleID = app?.id {
                artwork = appController?.retrieveImage(forKey: bundleID)
                if let movieURL = appController?.filePath(forKey: bundleID, movie: true),
                    FileManager.default.fileExists(atPath: movieURL.path) {
                    demoMovieURL = movieURL
                }
            }
            deleteArtworkOnExit = false
        }
    }

    var appStoreURL: URL?
    var ratings: Int16?
    var bundleID: String?
    var myContributions: String?
    var artwork: UIImage?
    var demoMovieURL: URL?
    var libraries: NSMutableSet = NSMutableSet()
    var librariesArray: [Library] {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let array = libraries.sortedArray(using: [sortDescriptor])
        return array.compactMap({ $0 as? Library })
    }

    var appLoaded: Bool = false
    var deleteArtworkOnExit = true
    var editMode: Bool = true
    var showMyContributions: Bool {
        return editMode || myContributions != nil
    }

    var nameTextView: UITextView?
    var artworkImageView: UIImageView?
    var ageRatingButton: UIButton?
    var appStoreButton: UIButton?
    var descriptionTextView: UITextView?
    var ratingsButton: UIButton?
    var contributionsTextView: UITextView?
    var selectPhotoButton: UIButton?
    var selectMovieButton: UIButton?

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if deleteArtworkOnExit,
            let bundleID = bundleID {
            appController?.deleteImage(forKey: bundleID)
        }
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
        } else if section == 0 {
            if demoMovieURL != nil || editMode {
                return 3
            }
            return 2
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
            return libraries.count > 0 ? "API/Libraries Used" : nil
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
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
                cell.selectPhotoButton.addTarget(self, action: #selector(selectArtwork), for: .touchUpInside)
                selectPhotoButton = cell.selectPhotoButton
                returnCell = cell
            } else if indexPath.row == 1 {
                returnCell = tableView.dequeueReusableCell(withIdentifier: "ScreenshotsCell", for: indexPath)
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
                    as? LinkTableViewCell else { return UITableViewCell() }
                cell.ageRating.isHidden = true
                selectMovieButton = cell.appStoreButton
                cell.ratingsButton.isHidden = true
                returnCell = cell
            }
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
                as? LinkTableViewCell else { return UITableViewCell() }
            ageRatingButton = cell.ageRating
            ageRatingButton?.addTarget(self, action: #selector(setAgeRating), for: .touchUpInside)
            appStoreButton = cell.appStoreButton
            ratingsButton = cell.ratingsButton
            ratingsButton?.addTarget(self, action: #selector(setRatingsCount), for: .touchUpInside)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if editMode,
            indexPath.section == 2
                || indexPath.section == 3 {
            return 144
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if !appLoaded,
            let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last,
            indexPath == lastVisibleIndexPath {
            loadAppInfo()
            updateEditMode()
            tableView.beginUpdates()
            tableView.endUpdates()
            appLoaded = true
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

        artworkImageView?.image = artwork
        artworkImageView?.layer.cornerRadius = 20
        artworkImageView?.layer.masksToBounds = true

        if app.userRatingCount > 0 {
            ratingsButton?.setTitle("\(app.userRatingCount) Ratings", for: .disabled)
        } else {
            ratingsButton?.setTitle("", for: .disabled)
        }

        nameTextView?.text = app.name
        nameTextView?.textColor = UIColor.label
        ageRatingButton?.setTitle(app.ageRating, for: .disabled)
        ageRatingButton?.setTitle(app.ageRating, for: .normal)
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
                                  ageRating: ageRatingButton?.currentTitle,
                                  description: appDescription,
                                  appStoreURL: appStoreURL,
                                  bundleID: bundleID,
                                  userRatingCount: ratings,
                                  movieURL: demoMovieURL,
                                  contributions: myContributions,
                                  context: context)
        } else {
            appController?.create(appNamed: name,
                                  ageRating: ageRatingButton?.currentTitle,
                                  description: appDescription,
                                  appStoreURL: appStoreURL,
                                  artworkURL: nil,
                                  bundleID: bundleID,
                                  userRatingCount: ratings,
                                  artwork: nil,
                                  movieURL: demoMovieURL,
                                  contributions: myContributions,
                                  libraries: libraries,
                                  context: context)
            navigationController?.popViewController(animated: true)
        }

        if let artwork = artwork {
            appController?.store(artwork, forKey: bundleID)
        }
        deleteArtworkOnExit = false

        toggleEditMode()
    }

    @objc private func toggleEditMode() {
        editMode.toggle()
        descriptionTextView?.isScrollEnabled = editMode
        contributionsTextView?.isScrollEnabled = editMode
        appLoaded = false
        tableView.reloadData()
        updateEditMode()
    }

    private func updateEditMode() {
        nameTextView?.isEditable = editMode
        descriptionTextView?.isEditable = editMode
        descriptionTextView?.isScrollEnabled = editMode
        contributionsTextView?.isEditable = editMode
        contributionsTextView?.isScrollEnabled = editMode

        if editMode {
            appStoreButton?.setTitle("Tap to edit app store link", for: .normal)
            appStoreButton?.removeTarget(self, action: #selector(openAppStore), for: .touchUpInside)
            appStoreButton?.addTarget(self, action: #selector(updateAppStoreLink), for: .touchUpInside)
            selectMovieButton?.setTitle("Select Demo Video", for: .normal)
            selectMovieButton?.removeTarget(self, action: #selector(watchDemoMovie), for: .touchUpInside)
            selectMovieButton?.addTarget(self, action: #selector(selectMovie), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(save))
            ageRatingButton?.isEnabled = true
            ratingsButton?.isEnabled = true
            selectPhotoButton?.isHidden = false
        } else {
            appStoreButton?.setTitle("Open in App Store", for: .normal)
            appStoreButton?.removeTarget(self, action: #selector(updateAppStoreLink), for: .touchUpInside)
            appStoreButton?.addTarget(self, action: #selector(openAppStore), for: .touchUpInside)
            selectMovieButton?.setTitle("Watch Demo Video", for: .normal)
            selectMovieButton?.removeTarget(self, action: #selector(selectMovie), for: .touchUpInside)
            selectMovieButton?.addTarget(self, action: #selector(watchDemoMovie), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(toggleEditMode))
            ageRatingButton?.isEnabled = false
            ratingsButton?.isEnabled = false
            selectPhotoButton?.isHidden = true
        }
    }

    @objc private func setAgeRating() {
        let alert = UIAlertController(title: "Set Age Rating", message: nil, preferredStyle: .alert)

        var ageTextField: UITextField?
        alert.addTextField { textField in
            textField.placeholder = "4+"
            ageTextField = textField
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            guard let string = ageTextField?.text else { return }
            self.ageRatingButton?.setTitle(string, for: .disabled)
            self.ageRatingButton?.setTitle(string, for: .normal)
        }

        alert.addAction(cancel)
        alert.addAction(done)

        present(alert, animated: true, completion: nil)
    }

    @objc private func setRatingsCount() {
        let alert = UIAlertController(title: "Set Number of Ratings", message: nil, preferredStyle: .alert)

        var ageTextField: UITextField?
        alert.addTextField { textField in
            if let ratings = self.ratings {
                textField.text = "\(ratings)"
            }
            textField.placeholder = "5"
            ageTextField = textField
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) { _ in
            guard let string = ageTextField?.text,
                let ratings = Int16(string) else { return }
            self.ratings = ratings
            self.ratingsButton?.setTitle("\(ratings) Ratings", for: .disabled)
        }

        alert.addAction(cancel)
        alert.addAction(done)

        present(alert, animated: true, completion: nil)
    }

    @objc private func selectArtwork() {
        presentImagePicker()
    }

    @objc private func selectMovie() {
        presentImagePicker(video: true)
    }

    @objc private func watchDemoMovie() {
        if let videoURL = demoMovieURL {

            let player = AVPlayer(url: videoURL)

            let playerViewController = AVPlayerViewController()
            playerViewController.player = player

            present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }

    private func presentImagePicker(video: Bool = false) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("Photo library is not available")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        if video {
            imagePicker.mediaTypes = ["public.movie"]
        }

        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let librariesVC = segue.destination as? LibrariesTableViewController {
            librariesVC.libraries = self.libraries
        } else if let screenshotsVC = segue.destination as? ScreenshotsTableViewController,
            let screenshots = app?.screeenshots {
            let screenshotsArray = screenshots.sortedArray(using: []).compactMap({ $0 as? Screenshot })
            screenshotsVC.screenshots = screenshotsArray
            screenshotsVC.appController = appController
            screenshotsVC.app = app
        }
    }

}

// MARK: Text view delegate

extension AppDetailTableViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
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

// MARK: Image picker controller delegate

extension AppDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let movieURL = info[.mediaURL] as? URL {
            demoMovieURL = movieURL
        } else if let image = info[.originalImage] as? UIImage {
            artwork = image
            artworkImageView?.image = image
        }

        picker.dismiss(animated: true, completion: nil)
    }
}
