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
    }
    
    private func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let placesGroup = drop.grouped("places").grouped(AuthenticationMiddleware())
        
        placesGroup.post("all", handler: allPlaces)
        placesGroup.post("radius", handler: placesInRadius)
        placesGroup.post("info", ":merchant_id", handler: placeInfo)
        placesGroup.post("menu", ":merchant_id", handler: placeMenu)
    }

    
    //MARK: - Routes
    
    func allPlaces(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func placesInRadius(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func placeInfo(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func placeMenu(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
}
