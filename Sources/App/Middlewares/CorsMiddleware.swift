//
//  CorsMiddleware.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 15.12.16.
//
//

import HTTP
import JSON
import Vapor

class CorsMiddleware: Middleware {
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let response: Response
        if request.isPreflight {
            response = "".makeResponse()
        } else {
            response = try chain.respond(to: request)
        }
        
        response.headers["Access-Control-Allow-Origin"] = /*request.headers["Origin"] ?? */ "*";
        response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, Origin, Content-Type, Accept, Access-Control-Allow-Origin, Authorization"
        response.headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, OPTIONS, DELETE, PATCH"
        
        return response
    }
}

extension Request {
    var isPreflight: Bool {
        return method == .options
            && headers["Access-Control-Request-Method"] != nil
    }
}
