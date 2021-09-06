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
    
    // Предзагрузка списка акций по выбранной категории
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
    
    // Загрузка и кэширование фото
    func requestLogo(url: URL, completion: @escaping ((UIImage) -> ())) {
        URLSession.shared.dataTask(with: url) { data, resp, error in
            guard let data = data, error == nil else { return }
            
            guard let imageToCache = UIImage(data: data) else { return }
            completion(imageToCache)
            imageCache.setObject(imageToCache, forKey: url.absoluteString as NSString)
        }.resume()
    }
}

// MARK: Caching image
extension UIImageView {
  func cacheImage(symbol: String){
    // 1. Making URL with symbol that we got
    guard let url = URL(string: "https://storage.googleapis.com/iex/api/logos/\(symbol).png") else { return }
    // 2. Setting imageView.image to nil because we want to load new image into it
    image = nil
    // 3. Looking for new image in imageCache dictionary
    // 3.1 If it exists than loading it as imageView.image
    if let imageFromCache = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
        self.image = imageFromCache
        print("Got it from cash")
        return
    // 3.2 If not, loading image from our URL
    } else {
    // and caching it inside of this method
        NetworkManager.shared().requestLogo(url: url) { image in
    // and setting in main queue imageView.image equal to image we got
            DispatchQueue.main.async {
                self.image = image
            }
        }
}}}
