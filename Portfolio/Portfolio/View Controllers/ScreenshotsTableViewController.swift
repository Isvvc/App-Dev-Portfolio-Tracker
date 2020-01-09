//
//  ScreenshotsTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ScreenshotsTableViewController: UITableViewController {

    @IBOutlet weak var addImageView: UIView!

    var screenshots: [Screenshot]?
    var app: App?
    var appController: AppController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        updateViews()
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

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateViews()
    }

    // MARK: Private

    private func updateViews() {
        addImageView.isHidden = !tableView.isEditing
    }

    private func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("Photo library is not available")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: Actions

    @IBAction func addImage(_ sender: Any) {
        presentImagePicker()
    }

}

// MARK: Image picker controller delegate

extension ScreenshotsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage,
            let app = app,
            let screenshot = appController?.add(screenshot: image,
                                                toApp: app,
                                                context: CoreDataStack.shared.mainContext) {
            screenshots?.append(screenshot)
            tableView.reloadData()
        }

        picker.dismiss(animated: true, completion: nil)
    }
}
