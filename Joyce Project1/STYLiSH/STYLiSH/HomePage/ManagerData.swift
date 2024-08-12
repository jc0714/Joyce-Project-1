//
//  ManagerData.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/18.
//

import Foundation
import Alamofire

protocol MarketManagerDelegate: AnyObject {
    func manager(_ manager: MarketManager, didGet marketingHots: [MarketHots])
    func manager(_ manager: MarketManager, didFailWith error: Error)
}

class MarketManager {
    
    weak var delegate: MarketManagerDelegate?
    
    func getMarketingHots() {
        let urlString = "https://api.appworks-school.tw/api/1.0/marketing/hots"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if String(data: data, encoding: .utf8) != nil {
                    //print(jsonString)
                } else {
                    print("Failed to convert data to string")
                }
                
                let decoder = JSONDecoder()
                let marketingHotsResponse = try decoder.decode(MarketingHotsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGet: marketingHotsResponse.data)
                }
                
                
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
}

struct MarketingHotsResponse: Codable {
    let data: [MarketHots]
}

struct MarketHots: Codable {
    let title: String
    let products: [Product]
}

struct MarketVariant: Codable {
    let colorCode: String
    let size: String
    let stock: Int

    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case size, stock
    }
}

struct ColorVariant: Codable {
    let code: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case code, name
    }
}
