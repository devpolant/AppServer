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
        
        let ordersGroup = drop.grouped("orders").grouped(AuthenticationMiddleware())
        
        ordersGroup.post("details", ":order_id", handler: orderDetails)
        
        let merchant = ordersGroup.grouped("merchant")
        merchant.post("list", handler: merchantOrders)
        merchant.post("approve", ":order_id", handler: approveOrder)
        merchant.post("decline", ":order_id", handler: declineOrder)
        merchant.post("complete", ":order_id", handler: completeOrder)
        
        let customer = ordersGroup.grouped("customer")
        customer.post("list", handler: customerOrders)
        customer.post("create", handler: createOrder)
    }
    
    
    //MARK: - Details
    
    func orderDetails(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    
    //MARK: - Merchant
    
    func merchantOrders(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func approveOrder(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func declineOrder(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func completeOrder(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    
    //MARK: - Customer
    
    func customerOrders(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func createOrder(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
}

