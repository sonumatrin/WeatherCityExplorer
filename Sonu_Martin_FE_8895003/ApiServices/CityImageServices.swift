//
//  CityImage.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 12/08/23.
//

import Foundation

class FetchCityImageService {
        func fetchCityImage(cityName: String, completion: @escaping (Data?) -> Void) {
            let url = "https://api.unsplash.com/search/photos"
            let unsplashApiKey = "iqXeuc283uP_8HFecLgYSiP7PbZrCzbFbVOcJgzd2kw"
            var urlComponents = URLComponents(string: url)!
            urlComponents.queryItems = [
                URLQueryItem(name: "query", value: cityName),
                URLQueryItem(name: "client_id", value: unsplashApiKey)
            ]
            
            let task = URLSession.shared.dataTask(with: urlComponents.url!) { data, response, error in
                if let data = data,let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.randomElement(),
                   let urls = firstResult["urls"] as? [String: String],
                   let imageUrl = urls["regular"],
                   let imageUrlObj = URL(string: imageUrl),
                   let imageData = try? Data(contentsOf: imageUrlObj) {
                    completion(imageData)
                } else {
                    completion(nil)
                }
            }
            task.resume()
        }
}

