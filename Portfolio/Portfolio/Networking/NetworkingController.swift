//
//  NetworkingController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class NetworkingController {
    
    private let baseiTunesURL = URL(string: "https://itunes.apple.com/")!
    
    func search(appName: String, completion: @escaping (Data?, Error?) -> Void) {
        let searchURL = baseiTunesURL.appendingPathComponent("search")
        var components = URLComponents(url: searchURL, resolvingAgainstBaseURL: true)
        let termQueryItem = URLQueryItem(name: "term", value: appName)
        let entityQueryItem = URLQueryItem(name: "entity", value: "software")
        components?.queryItems = [termQueryItem, entityQueryItem]
        
        guard let requestURL = components?.url else {
            NSLog("Error constructing search URL")
            return completion(nil, nil)
        }
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            completion(data, error)
        }.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let data = data else {
                NSLog("No data returned from image fetch request.")
                return completion(nil, nil)
            }
            
            let image = UIImage(data: data)
            completion(image, nil)
        }.resume()
    }
    
}
