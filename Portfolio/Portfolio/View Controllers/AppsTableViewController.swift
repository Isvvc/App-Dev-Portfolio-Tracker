//
//  AppsTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import CoreData

class AppsTableViewController: UITableViewController {

    let appController = AppController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    lazy var fetchedResultsController: NSFetchedResultsController<App> = {
        let fetchRequest: NSFetchRequest<App> = App.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for apps frc: \(error)")
        }

        return frc
    }()

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath)
            as? AppTableViewCell else { return UITableViewCell() }

        let app = fetchedResultsController.object(at: indexPath)

        cell.nameLabel?.text = app.name
        if let bundleID = app.id {
            cell.artworkImageView.image = appController.retrieveImage(forKey: bundleID)
            cell.artworkImageView?.layer.cornerRadius = 10
            cell.artworkImageView?.layer.masksToBounds = true
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let app = fetchedResultsController.object(at: indexPath)

            var alertBody = "Are you sure you want to remove "
            if let appName = app.name {
                alertBody += "the app \(appName)?"
            } else {
                alertBody += "this app?"
            }
            alertBody += " Data saved in Portfolio will be lost."

            let alert = UIAlertController(title: "Confirm", message: alertBody, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.appController.delete(app: app, context: CoreDataStack.shared.mainContext)
            }

            alert.addAction(cancel)
            alert.addAction(delete)

            present(alert, animated: true, completion: nil)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: Actions

    @IBAction func addApp(_ sender: Any) {
        let message = "Would you like to search the App Store for you app, or create a new one manually?"
        let alert = UIAlertController(title: "New App",
                                      message: message,
                                      preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let search = UIAlertAction(title: "Search", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SearchApps", sender: self)
            }
        }
        let new = UIAlertAction(title: "Create New", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "AppDetails", sender: self)
            }
        }

        alert.addAction(cancel)
        alert.addAction(search)
        alert.addAction(new)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let appSearchVC = navigationController.viewControllers.first as? AppSearchTableViewController {
            appSearchVC.appController = appController
            appSearchVC.callbacks.append { apps in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }

                do {
                    try self.appController.create(apps: apps, context: CoreDataStack.shared.mainContext)
                } catch {
                    NSLog("Unable to add apps: \(error)")
                }
            }
        } else if let appDetailVC = segue.destination as? AppDetailTableViewController {
            appDetailVC.appController = appController
            if let indexPath = tableView.indexPathForSelectedRow {
                appDetailVC.app = fetchedResultsController.object(at: indexPath)
            } else {
                let alert = UIAlertController(title: "Enter the app's Bundle Identifier",
                                              message: nil,
                                              preferredStyle: .alert)

                var bundleIDTextField: UITextField?
                alert.addTextField { textField in
                    textField.placeholder = "com.example.app"
                    bundleIDTextField = textField
                }

                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                let done = UIAlertAction(title: "Done", style: .default) { _ in
                    guard let bundleID = bundleIDTextField?.text else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                        return
                    }
                    appDetailVC.bundleID = bundleID
                }

                alert.addAction(cancel)
                alert.addAction(done)

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}

// MARK: Fetched results controller delegate

extension AppsTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }

            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {

        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
    }
}
