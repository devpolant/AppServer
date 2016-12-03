//
//  VisitorsController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 03.12.16.
//
//

import Foundation
import Vapor
import HTTP

class VisitorsController: DropletConfigurable {
    
    weak var drop: Droplet?
    
    required init(droplet: Droplet) {
        self.drop = droplet
    }
    
    func setup() {
        guard drop != nil else {
            debugPrint("Drop is nil")
            return
        }
        setupRoutes()
    }
    
    
    //MARK: - Routes
    
    func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let auth = AuthMiddlewareFactory.shared.merchantAuthMiddleware
        
        let visitors = drop.grouped("merchant")
            .grouped("visitors")
            .grouped(auth)
            .grouped(AuthenticationMiddleware())
        
        visitors.post("set", handler: setVisitorsCount)
    }
    
    
    //MARK: - Visitors
    
    func setVisitorsCount(_ req: Request) throws -> ResponseRepresentable {
        
        guard var merchant = try req.merchant() else {
            throw Abort.custom(status: .badRequest, message: "Merchant required")
        }
        
        guard let visitorsCount = req.data["visitors_count"]?.int else {
            throw Abort.badRequest
        }
        
        merchant.visitorsCount = visitorsCount
        do {
            try merchant.save()
        } catch {
            print(error)
        }
        return try JSON(node: ["error": false,
                               "message": "Visitors updated"])
    }
    
}

