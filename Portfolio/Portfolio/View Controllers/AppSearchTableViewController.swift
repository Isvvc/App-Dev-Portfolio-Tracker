//
//  AppSearchTableViewController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppSearchTableViewController: UITableViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addAppsButton: UIBarButtonItem!
    
    //MARK: Properties
    
    let appController = AppController()
    var searchResults: [AppRepresentation] = []
    var selectedApps: [AppRepresentation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadCellImage(_:)), name: .loadAppArtwork, object: nil)
        
        updateViews()
    }
    
    @objc private func loadCellImage(_ notification:Notification) {
        let json = JSON(notification.userInfo as Any)
        guard let index = json["index"].int else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath)

        let app = searchResults[indexPath.row]
        cell.textLabel?.text = app.name
        cell.imageView?.image = app.artwork
        
        // App icons of size 512x512 have corner radius.
        // This value is based on the image height being 44.333
        // TODO: calculate the corner radius based on size of the imageView
        cell.imageView?.layer.cornerRadius = 7
        cell.imageView?.layer.masksToBounds = true
        
        cell.accessoryType = selectedApps.contains(where: { $0.bundleID == app.bundleID }) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.setSelected(false, animated: true)
        
        if cell.accessoryType == .none {
            selectedApps.append(searchResults[indexPath.row])
            cell.accessoryType = .checkmark
        } else {
            selectedApps.removeAll(where: { $0.bundleID == searchResults[indexPath.row].bundleID })
            cell.accessoryType = .none
        }
        
        updateViews()
    }
    
    //MARK: Private
    
    private func updateViews() {
        addAppsButton.isEnabled = selectedApps.count > 0
        addAppsButton.title = "Add App\(selectedApps.count > 1 ? "s" : "")"
    }
    
    //MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: Search bar delegate

extension AppSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        searchResults = []
        selectedApps = []
        tableView.reloadData()
        updateViews()
        appController.search(appName: searchTerm) { apps, error in
            if let error = error {
                NSLog("Error fetching search results: \(error)")
            }
            
            self.searchResults = apps
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
