//
//  Order.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import Fluent
import HTTP

final class Order: Model {
    
    var id: Node?
    var customerId: Node
    var merchantId: Node
    var createdDate: Int        //Time from 1970
    var availabilityDate: Int   //Time from 1970
    var state: State
    
    var exists: Bool = false
    
    enum State: String {
        case unconfirmed = "unconfirmed"
        case approved = "approved"
        case declined = "declined"
        case completed = "completed"
    }
    
    init(customerId: Node, merchantId: Node, createdDate: Int, availabilityDate: Int, state: State = .unconfirmed) {
        self.customerId = customerId
        self.merchantId = merchantId
        self.createdDate = createdDate
        self.availabilityDate = availabilityDate
        self.state = state
    }
    
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        customerId = try node.extract("customer_id")
        merchantId = try node.extract("merchant_id")
        createdDate = try node.extract("created_date")
        availabilityDate = try node.extract("availability_date")
        state = State(rawValue: try node.extract("state"))!
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "customer_id": customerId,
            "merchant_id": merchantId,
            "created_date": createdDate,
            "availability_date": availabilityDate,
            "state": state.rawValue
            ])
    }
}


//MARK: - Preparation
extension Order {
    
    static func prepare(_ database: Database) throws {
        try database.create("orders") { users in
            users.id("_id")
            users.id("customer_id")
            users.id("merchant_id")
            users.int("created_date")
            users.int("availability_date")
            users.string("state")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("orders")
    }
}


//MARK: - Public Response

extension Order: PublicResponseRepresentable {
    
    func publicResponseNode() throws -> Node {
        
        var orderItemNodes = [Node]()
        var totalPrice = 0.0
        
        for item in try orderItems().all() {
            
            orderItemNodes.append(try item.publicResponseNode())
            
            guard let menuItem = try item.menuItem().get() else {
                throw Abort.custom(status: .continue, message: "Database connection failed")
            }
            totalPrice += menuItem.price * Double(item.quantity)
        }
        
        return try Node(node: [
            "_id": id,
            "customer_id": customerId,
            "merchant_id": merchantId,
            "created_date": createdDate,
            "availability_date": availabilityDate,
            "state": state.rawValue,
            "total_price": totalPrice,
            "order_items": Node.array(orderItemNodes)
            ])
    }
}


//MARK: - DB Relation
extension Order {
    
    func orderItems() -> Children<OrderItem> {
        return children("order_id", OrderItem.self)
    }
}


//MARK: - Request
extension Request {
    
    func order() throws -> Order {
        
        guard let orderId = parameters["order_id"]?.string ?? data["order_id"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Order id required")
        }
        
        guard let order = try Order.find(orderId) else {
            throw Abort.custom(status: .badRequest, message: "Order not found")
        }
        return order
    }
}


