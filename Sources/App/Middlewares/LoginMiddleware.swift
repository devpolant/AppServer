//
//  LoginMiddleware.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 24.10.16.
//
//

import Foundation
import Vapor
import HTTP

final class LoginMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let _ = request.data["username"], let _ = request.data["password"] else {
            
            throw Abort.custom(status: .badRequest, message: "username and password required")
        }
        return try next.respond(to: request)
    }
}
