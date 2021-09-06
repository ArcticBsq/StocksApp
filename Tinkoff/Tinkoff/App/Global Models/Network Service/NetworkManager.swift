//
//  NetworkManager.swift
//  Tinkoff
//
//  Created by Илья Москалев on 03.09.2021.
//

import UIKit

class NetworkManager {
    
    static func shared() -> NetworkManager {
        return NetworkManager()
    }
    
    private init() { }
    
    func requestListOfQuotes(from section: String, completion: @escaping (([Stock]?, Error?) -> ())) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/list/\(section)?token=pk_e6e3fd3cc5fe46478329fb2c8016c533")
        
        let dataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                completion(nil, error)
                print("Network error!")
                return
            }

            
            guard let stocksList = try? JSONDecoder().decode(List.self, from: data) else {
                print("Couldn't decode JSON HERE")
                return
            }
            
            completion(stocksList, nil)
        }
        dataTask.resume()
    }
    
    func requestLogo(url: URL, completion: @escaping ((UIImage) -> ())) {
        URLSession.shared.dataTask(with: url) { data, resp, error in
            guard let data = data, error == nil else { return }
            
            guard let imageToCache = UIImage(data: data) else { return }
            completion(imageToCache)
            imageCache.setObject(imageToCache, forKey: url.absoluteString as NSString)
        }.resume()
    }
}
