//
//  AuthMiddlewareFactory.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 02.12.16.
//
//

import Foundation
import Vapor
import Auth
import Cookies
import HTTP

class AuthMiddlewareFactory {
    
    static let shared = AuthMiddlewareFactory()
    
    private init() { }
    
    var customerAuthMiddleware: AuthMiddleware<Customer> {
        
        return AuthMiddleware(user: Customer.self) { value in
            return Cookie(
                name: "vapor-auth",
                value: value,
                expires: Date().addingTimeInterval(60 * 60 * 24), // 24 hours
                secure: true,
                httpOnly: true
            )
        }
    }
    
    var merchantAuthMiddleware: AuthMiddleware<Merchant> {
        
        return AuthMiddleware(user: Merchant.self) { value in
            return Cookie(
                name: "vapor-auth",
                value: value,
                expires: Date().addingTimeInterval(60 * 60 * 24), // 24 hours
                secure: true,
                httpOnly: true
            )
        }
    }
    
}
