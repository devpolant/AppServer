//
//  UserController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 30.10.16.
//
//


import Foundation
import Vapor
import Auth
import Cookies
import BCrypt

class UserController {
    
    weak var drop: Droplet?
    
    init(droplet: Droplet) {
        debugPrint("initializing UserController")
        self.drop = droplet
    }
    
    func setup() {
        guard drop != nil else {
            debugPrint("Drop is nil")
            return
        }
        
        setupAuth()
        setupRoutes()
    }
    
    private func setupAuth() {
        
        let auth = AuthMiddleware(user: User.self) { value in
            return Cookie(
                name: "vapor-auth",
                value: value,
                expires: Date().addingTimeInterval(60 * 60 * 5), // 5 hours
                secure: true,
                httpOnly: true
            )
        }
        drop?.addConfigurable(middleware: auth, name: "auth")
    }
    
    private func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        drop.group("users") { users in
            
            users.post("register") { req in
                
                guard let name = req.data["name"]?.string,
                    let login = req.data["login"]?.string,
                    let password = req.data["password"]?.string else {
                        throw Abort.badRequest
                }
                var user = User(name: name, login: login, password: password)
                user.token = self.token(for: user)
                
                try user.save()
                return try user.makeJSON()
            }
            
            users.post("login") { req in
                
                guard let login = req.data["login"]?.string,
                    let password = req.data["password"]?.string else {
                        throw Abort.badRequest
                }
                
                let credentials = APIKey(id: login, secret: password)
                try req.auth.login(credentials)
                
                if let user = try req.auth.user() as? User {
                    
                    print("user did logged in")
                    print(user.token)
                    
                    user.token = self.token(for: user)
                    let node = ["message": "Logged in",
                                "access_token" : user.token]
                    
                    return try JSON(node: node)
                }
                throw Abort.badRequest
            }
            
            users.post("logout") { req in
                
                guard let token = req.auth.header?.bearer else {
                    throw Abort.notFound
                }
                
                if let user = try User.query().filter("access_token", token.string).first() {
                    user.token = ""
                    throw Abort.custom(status: .accepted, message: "Logout success")
                }
                throw Abort.badRequest
            }
            
            let protect = ProtectMiddleware(error:
                Abort.custom(status: .forbidden, message: "Not authorized.")
            )
            users.group(protect) { secure in
            }
            //            users.group(protect) { secure in
            //                secure.get("secure") { req in
            //                    return try req.user()
            //                }
            //            }
        }
    }
    
    func token(for user: User) -> String {
        return encode(["hash":user.hash], algorithm: .hs256("secret".data(using: .utf8)!))
    }
}
