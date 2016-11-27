//
//  OrderItem.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import Fluent

final class OrderItem: Model {
    
    var id: Node?
    var orderId: Node
    var menuItemId: Node
    var quantity: Int
    
    var exists: Bool = false
    
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        orderId = try node.extract("order_id")
        menuItemId = try node.extract("menu_item_id")
        quantity = try node.extract("quantity")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "order_id": orderId,
            "menu_item_id": menuItemId,
            "quantity": quantity
            ])
    }
}

//MARK: - Preparation
extension OrderItem {
    
    static func prepare(_ database: Database) throws {
        try database.create("order_items") { users in
            users.id("_id")
            users.id("order_id")
            users.id("menu_item_id")
            users.int("quantity")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("order_items")
    }
}


//MARK: - DB Relations
extension OrderItem {
    
    func order() throws -> Parent<Order> {
        return try parent(orderId)
    }
}


