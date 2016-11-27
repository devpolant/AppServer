//
//  MenuCategory.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor

final class MenuCategory: Model {
    
    var id: Node?
    var name: String
    var description: String
    var merchantId: Node
    var photoUrl: String?
    
    var exists: Bool = false
    
    
    init(name: String, description: String, merchantId: Node, photoUrl: String? = nil) {
        self.name = name
        self.description = description
        self.merchantId = merchantId
        self.photoUrl = photoUrl
    }
    
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        name = try node.extract("name")
        description = try node.extract("description")
        photoUrl = try node.extract("photo_url")
        merchantId = try node.extract("merchant_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "name": name,
            "description": description,
            "photo_url": photoUrl,
            "merchant_id": merchantId
            ])
    }
}


//MARK: - Preparation
extension MenuCategory {
    
    static func prepare(_ database: Database) throws {
        try database.create("menu_categories") { users in
            users.id("_id")
            users.string("name")
            users.string("description")
            users.string("photo_url")
            users.parent(Merchant.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("menu_categories")
    }
}
