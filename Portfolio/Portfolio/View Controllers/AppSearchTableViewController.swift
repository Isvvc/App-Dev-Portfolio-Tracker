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
    
    //MARK: Properties
    
    let appController = AppController()
    var searchResults: [AppRepresentation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadCellImage(_:)), name: .loadAppArtwork, object: nil)
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
        
        cell.imageView?.layer.cornerRadius = 7
        cell.imageView?.layer.masksToBounds = true
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: Search bar delegate

extension AppSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        searchResults = []
        tableView.reloadData()
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
