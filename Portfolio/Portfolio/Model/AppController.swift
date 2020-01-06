//
//  AppController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppController {
    
    let networkingController = NetworkingController()
    
    func search(appName: String, completion: @escaping ([AppRepresentation], Error?) -> Void) {
        networkingController.search(appName: appName) { data, error in
            if let error = error {
                return completion([], error)
            }
            
            guard let data = data else {
                NSLog("No data returned from search")
                return completion([], nil)
            }
            
            do {
                let json = try JSON(data: data)
                guard let results = json["results"].array else {
                    return completion([], json["results"].error)
                }
                
                var apps: [AppRepresentation] = []
                
                for appJSON in results {
                    guard let name = appJSON["trackName"].string,
                        let artworkURL = appJSON["artworkUrl512"].url,
                        let ageRating = appJSON["contentAdvisoryRating"].string else { continue }
                    
                    let app = AppRepresentation(name: name, artworkURL: artworkURL, ageRating: ageRating)
                    
                    apps.append(app)
                }
                
                return completion(apps, nil)
            } catch {
                return completion([], error)
            }
        }
    }
}
