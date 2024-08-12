//
//  CartItem+CoreDataProperties.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/5.
//
//

import Foundation
import CoreData


extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var color: String?
    @NSManaged public var colorName: String?
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var number: String?
    @NSManaged public var price: String?
    @NSManaged public var size: String?
    @NSManaged public var stock: String?

}

extension CartItem : Identifiable {

}
