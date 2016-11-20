//
//  Location.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 20.11.16.
//
//

import Foundation
import Vapor
import HTTP

final class Location: NodeConvertible {
    
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        latitude = try node.extract("lat")
        longitude = try node.extract("lng")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "lat": latitude,
            "lng": longitude
            ])
    }
}
