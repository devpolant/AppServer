//
//  MenuItem.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import Fluent
import HTTP

final class MenuItem: Model {
    
    var id: Node?
    var name: String
    var description: String
    var photoUrl: String?
    var price: Double
    
    var menuCategoryId: Node
    
    var exists: Bool = false
    
    
    init(name: String, description: String, photoUrl: String? = nil, price: Double, menuCategoryId: Node) {
        self.name = name
        self.description = description
        self.photoUrl = photoUrl
        self.price = price
        self.menuCategoryId = menuCategoryId
    }
    
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        name = try node.extract("name")
        description = try node.extract("description")
        photoUrl = try node.extract("photo_url")
        price = try node.extract("price")
        menuCategoryId = try node.extract("menu_category_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "name": name,
            "description": description,
            "photo_url": photoUrl,
            "price": price,
            "menu_category_id": menuCategoryId
            ])
    }
}


//MARK: - Preparation
extension MenuItem {
    
    static func prepare(_ database: Database) throws {
        try database.create("menu_items") { users in
            users.id("_id")
            users.string("name")
            users.string("description")
            users.string("photo_url")
            users.string("price")
            users.id("menu_category_id", optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("menu_items")
    }
}


//MARK: - DB Relations

extension MenuItem {
    func category() throws -> Parent<MenuCategory> {
        return try parent(menuCategoryId)
    }
}


//MARK: - Request
extension Request {
    
    func menuItem() throws -> MenuItem {
        
        guard let itemId = data["item_id"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Menu item id required")
        }
        guard let menuItem = try MenuItem.find(itemId) else {
            throw Abort.custom(status: .badRequest, message: "Menu item not found")
        }
        return menuItem
    }
}

