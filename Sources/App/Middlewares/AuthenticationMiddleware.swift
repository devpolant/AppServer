//
//  AuthenticationMiddleware.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 06.11.16.
//
//

import Foundation

import Vapor
import HTTP

final class AuthenticationMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        print("check user token")
        
        guard let token = request.auth.header?.bearer else {
            throw Abort.custom(status: .badRequest, message: "Token is missing")
        }
        
        print("trying get logged in user")
        if let user = try request.auth.user() as? User {
            //logged in user -> check token
            
            print("user logged in")
            if user.token != token.string {
                throw Abort.custom(status: .badRequest, message: "Invalid token")
            }
        } else {
            try request.auth.login(token)
        }
        print("all is ok")
        return try next.respond(to: request)
        
    }
}
