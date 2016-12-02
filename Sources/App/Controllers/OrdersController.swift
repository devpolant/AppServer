//
//  OrdersController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import HTTP

class OrdersController: DropletConfigurable {
    
    weak var drop: Droplet?
    
    required init(droplet: Droplet) {
        self.drop = droplet
    }
    
    //MARK: - Setup
    
    func setup() {
        guard drop != nil else {
            debugPrint("Drop is nil")
            return
        }
        setupRoutes()
    }
    
    func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let customerAuth = AuthMiddlewareFactory.shared.customerAuthMiddleware
        let merchantAuth = AuthMiddlewareFactory.shared.merchantAuthMiddleware
        let auth = AuthenticationMiddleware()
        
        let ordersGroup = drop.grouped("orders")
        
        
        let merchant = ordersGroup.grouped("merchant")
            .grouped(merchantAuth)
            .grouped(auth)
        
        merchant.post("details", ":order_id", handler: orderDetails)
        
        merchant.post("list", handler: merchantOrders)
        merchant.post("approve", ":order_id", handler: approveOrder)
        merchant.post("decline", ":order_id", handler: declineOrder)
        merchant.post("complete", ":order_id", handler: completeOrder)
        
        
        let customer = ordersGroup.grouped("customer")
            .grouped(customerAuth)
            .grouped(auth)
        
        customer.post("details", ":order_id", handler: orderDetails)
        
        customer.post("list", handler: customerOrders)
        customer.post("create", handler: createOrder)
    }
    
    
    //MARK: - Details
    
    func orderDetails(_ req: Request) throws -> ResponseRepresentable {
        
        let order = try req.order()
        
        return try JSON(node: ["error": false,
                               "order": try order.publicResponseNode()])
    }
    
    
    //MARK: - Merchant
    
    func merchantOrders(_ req: Request) throws -> ResponseRepresentable {
        
        guard let merchant = try req.merchant() else {
            throw Abort.badRequest
        }
        var ordersJSONArray = [Node]()
        
        for order in try merchant.orders().all() {
            ordersJSONArray.append(try order.publicResponseNode())
        }
        return try JSON(node: ["error": false,
                               "orders": Node.array(ordersJSONArray)])
    }
    
    func approveOrder(_ req: Request) throws -> ResponseRepresentable {
        
        var order = try req.order()
        do {
            order.state = .approved
            try order.save()
        } catch {
            print(error)
        }
        return try JSON(node: ["error": false,
                               "message": "Order approved"])
    }
    
    func declineOrder(_ req: Request) throws -> ResponseRepresentable {
        
        var order = try req.order()
        do {
            order.state = .declined
            try order.save()
        } catch {
            print(error)
        }
        return try JSON(node: ["error": false,
                               "message": "Order declined"])
    }
    
    func completeOrder(_ req: Request) throws -> ResponseRepresentable {
        
        var order = try req.order()
        do {
            order.state = .completed
            try order.save()
        } catch {
            print(error)
        }
        return try JSON(node: ["error": false,
                               "message": "Order completed"])
    }
    
    
    //MARK: - Customer
    
    func customerOrders(_ req: Request) throws -> ResponseRepresentable {
        
        guard let customer = try req.customer() else {
            throw Abort.badRequest
        }
        var ordersJSONArray = [Node]()
        
        for order in try customer.orders().all() {
            ordersJSONArray.append(try order.publicResponseNode())
        }
        return try JSON(node: ["error": false,
                               "orders": Node.array(ordersJSONArray)])
    }
    
    func createOrder(_ req: Request) throws -> ResponseRepresentable {
        
        guard let customer = try req.customer(),
            let merchantId = req.data["merchant_id"]?.string,
            let merchant = try Merchant.find(merchantId),
            let orderDate = req.data["availability_date"]?.int,
            let items = req.data["items"]?.array else {
                throw Abort.badRequest
        }
        
        var order = Order(customerId: customer.id!,
                          merchantId: merchant.id!,
                          createdDate: Int(Date().timeIntervalSince1970),
                          availabilityDate: orderDate)
        do {
            try order.save()
        } catch {
            throw Abort.serverError
        }
        
        for jsonItem in items {
            guard let object = jsonItem.object else {
                continue
            }
            let menuItemId = object["item_id"]!.string!
            let quantity = object["quantity"]!.int!
            
            guard let menuItem = try MenuItem.find(menuItemId) else {
                continue
            }
            
            var orderItem = OrderItem(orderId: order.id!,
                                      menuItemId: menuItem.id!,
                                      quantity: quantity)
            do {
                try orderItem.save()
            } catch {
                throw Abort.serverError
            }
        }
        return try JSON(node: ["error": false,
                               "message": "Order created",
                               "order": order.publicResponseNode()])
    }
    
}

