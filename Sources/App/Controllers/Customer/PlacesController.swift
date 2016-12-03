//
//  PlacesController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import HTTP
import Auth

/*
 * Places is merchants with their appropriate locations.
 */
class PlacesController: DropletConfigurable {
    
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
    
    private func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let customerAuth = AuthMiddlewareFactory.shared.customerAuthMiddleware
        
        let placesGroup = drop.grouped("customer")
            .grouped(customerAuth)
            .grouped(AuthenticationMiddleware())
            .grouped("places")
        
        placesGroup.post("all", handler: allPlaces)
        placesGroup.post("radius", handler: placesInRadius)
        placesGroup.post("info", ":merchant_id", handler: placeInfo)
        placesGroup.post("menu", ":merchant_id", handler: placeMenu)
    }

    
    //MARK: - Routes
    
    func allPlaces(_ req: Request) throws -> ResponseRepresentable {
        
        var merchantsJsonArray = [Node]()
        
        for merchant in try Merchant.query().all() {
            merchantsJsonArray.append(try merchant.publicResponseNode())
        }
        return try JSON(node: ["error": false,
                               "merchants": Node.array(merchantsJsonArray)])
    }
    
    func placesInRadius(_ req: Request) throws -> ResponseRepresentable {
        
        guard let radiusInMeters = req.data["radius"]?.double,
            let latitude = req.data["latitude"]?.double,
            let longitude = req.data["longitude"]?.double else {
            throw Abort.custom(status: .badRequest, message: "radius required")
        }
        let location = Location(latitude: latitude, longitude: longitude)
        
        var merchantsJsonArray = [Node]()
        
        let merchants = try Merchant.query().all().filter { merchant in
            return merchant.location.distance(to: location) <= radiusInMeters
        }
        
        for merchant in merchants {
            let node = try merchant.publicResponseNode()
            merchantsJsonArray.append(node)
        }
        
        return try JSON(node: ["error": false,
                               "merchants": Node.array(merchantsJsonArray)])
    }
    
    func placeInfo(_ req: Request) throws -> ResponseRepresentable {
        
        guard let merchantId = req.parameters["merchant_id"]?.string,
            let merchant = try Merchant.find(merchantId) else {
                throw Abort.custom(status: .badRequest, message: "Merchant id required")
        }
        
        return try JSON(node: ["error": false,
                               "merchant" : merchant.publicResponseNode()])
    }
    
    func placeMenu(_ req: Request) throws -> ResponseRepresentable {
        
        guard let merchantId = req.parameters["merchant_id"]?.string,
            let merchant = try Merchant.find(merchantId) else {
                throw Abort.custom(status: .badRequest, message: "Merchant id required")
        }
        
        var responseNodes = [Node]()
        
        for category in try merchant.menuCategories().all() {
            responseNodes.append(try category.makeNode())
        }
        return try JSON(node: ["error": false,
                               "menu_categories": Node.array(responseNodes)])
    }
    
}
