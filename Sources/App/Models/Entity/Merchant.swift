//
//  Merchant.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 20.11.16.
//
//

import Foundation
import Vapor
import Fluent
import Auth
import BCrypt
import HTTP

final class Merchant: Model, User {
    
    var id: Node?
    var login: String
    var hash: String
    var token: String = ""
    
    var businessName: String
    var country: String
    var city: String
    var address: String
    
    //Coordinates of merchant place.
    var latitude: Double
    var longitude: Double

    var exists: Bool = false
    
    
    init(login: String, password: String, businessName: String, country: String, city: String, address: String, latitude: Double, longitude: Double) {
        
        self.login = login
        self.hash = BCrypt.hash(password: password)
        
        self.businessName = businessName
        self.country = country
        self.city = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    //MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        
        id = try node.extract("_id")
        login = try node.extract("login")
        hash = try node.extract("hash")
        token = try node.extract("access_token")
        
        businessName = try node.extract("business_name")
        country = try node.extract("country")
        city = try node.extract("city")
        address = try node.extract("address")
        latitude = try node.extract("latitude")
        longitude = try node.extract("longitude")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "login": login,
            "hash": hash,
            "access_token": token,
            "business_name": businessName,
            "country": country,
            "city": city,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
            ])
    }
}


//MARK: - Public Response
extension Merchant: PublicResponseRepresentable {
    
    func publicResponseNode() throws -> Node {
        
        return try Node(node: [
            "_id": id,
            "login": login,
            "access_token": token,
            "business_name": businessName,
            "country": country,
            "city": city,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
            ])
    }
}


//MARK: - Preparation
extension Merchant {
    
    static func prepare(_ database: Database) throws {
        try database.create("merchants") { merchants in
            merchants.id("_id")
            merchants.string("login")
            merchants.string("hash")
            merchants.string("access_token")
            merchants.string("business_name")
            merchants.string("country")
            merchants.string("city")
            merchants.string("address")
            merchants.string("latitude")
            merchants.string("longitude")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("merchants")
    }
}


//MARK: - DB Relations
extension Merchant {
    
    func menuCategories() -> Children<MenuCategory> {
        return children("merchant_id", MenuCategory.self)
    }
    
    func orders() -> Children<Order> {
        return children("merchant_id", Order.self)
    }
}


//MARK: - Auth.User
extension Merchant: Auth.User {
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        
        var merchant: Merchant?
        
        switch credentials {
            
        case let id as Identifier:
            merchant = try Merchant.find(id.id)
            
        case let accessToken as AccessToken:
            merchant = try Merchant.query().filter("access_token", accessToken.string).first()
            
        case let apiKey as APIKey:
            do {
                if let tempUser = try Merchant.query().filter("login", apiKey.id).first() {
                    
                    if try BCrypt.verify(password: apiKey.secret, matchesHash: tempUser.hash) {
                        merchant = tempUser
                    }
                }
            }
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        
        guard let resultMerchant = merchant else {
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
        return resultMerchant
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Registration not supported")
    }
}


//MARK: - Request
extension Request {
    func merchant() throws -> Merchant? {
        return try auth.user() as? Merchant
    }
}

