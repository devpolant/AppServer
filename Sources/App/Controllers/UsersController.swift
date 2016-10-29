//
//  UsersController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 24.10.16.
//
//

import Foundation
import Vapor
import HTTP

final class UsersController {
    
    func userLogin(_ request: Request) throws -> ResponseRepresentable {
        
        return JSON(["result": "true"])
    }
    
}
