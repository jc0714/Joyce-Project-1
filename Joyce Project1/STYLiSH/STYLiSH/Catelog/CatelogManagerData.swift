//
//  CatelogManagerData.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/25.
//

import Foundation
import Alamofire

protocol CatelogProductManagerDelegate: AnyObject {
    func manager(_ manager: CatelogProductManager, didGetProducts products: CatelogProductResponse)
    func manager(_ manager: CatelogProductManager, didFailWith error: Error)
}

class CatelogProductManager {
    weak var delegate: CatelogProductManagerDelegate?

    func fetchProducts(from urlString: String) {
        AF.request(urlString).responseDecodable(of: CatelogProductResponse.self) { response in
            switch response.result {
            case .success(let womenProductResponse):
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGetProducts: womenProductResponse)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                }
            }
        }
    }

    func getWomenProducts() {
        let urlString = "https://api.appworks-school.tw/api/1.0/products/women"
        fetchProducts(from: urlString)
    }
    func moreWomenProducts() {
        let urlString = "https://api.appworks-school.tw/api/1.0/products/women?paging=1"
        fetchProducts(from: urlString)
    }

    func getMenProducts(){
        let urlString = "https://api.appworks-school.tw/api/1.0/products/men"
        fetchProducts(from: urlString)
    }

    func getAccessoriesProducts(){
        let urlString = "https://api.appworks-school.tw/api/1.0/products/accessories"
        fetchProducts(from: urlString)
    }
}


struct CatelogProductResponse: Codable {
    let data: [Product]
    let nextPaging: Int?

    enum CodingKeys: String, CodingKey {
        case data
        case nextPaging = "next_paging"
    }
}

struct Product: Codable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let price: Int
    let texture: String
    let wash: String
    let place: String
    let note: String
    let story: String
    let mainImage: String
    let images: [String]
    let variants: [Variant]
    let colors: [Color]
    let sizes: [String]

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, price, texture, wash, place, note, story, mainImage = "main_image", images, variants, colors, sizes
    }
}

struct Variant: Codable {
    let colorCode: String
    let size: String
    let stock: Int

    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case size, stock
    }
}

struct Color: Codable {
    let code: String
    let name: String
}
