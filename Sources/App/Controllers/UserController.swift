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
import HTTP

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
        
        let userGroup = drop.grouped("users")
        
        userGroup.post("register", handler: register)
        userGroup.post("login", handler: login)
        userGroup.post("logout", handler: logout)
    }
    
    
    //MARK: - Auth
    
    func register(_ req: Request) throws -> ResponseRepresentable {
        
        guard let name = req.data["name"]?.string,
            let login = req.data["login"]?.string,
            let password = req.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        if let _ = try User.query().filter("login", contains: login).first() {
            throw Abort.custom(status: .conflict, message: "User already exist")
        }
        
        var user = User(name: name, login: login, password: password)
        user.token = self.token(for: user)
        
        try user.save()
        return try user.makeJSON()
    }
    
    func login(_ req: Request) throws -> ResponseRepresentable {
        
        guard let login = req.data["login"]?.string,
            let password = req.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = APIKey(id: login, secret: password)
        try req.auth.login(credentials)
        
        guard let userId = try req.auth.user().id, let user = try User.find(userId) else {
            throw Abort.custom(status: .notFound, message: "User not found")
        }
        
        var newUser = User(user: user)
        newUser.token = self.token(for: user)
        
        try user.delete()
        try newUser.save()
        
        return try JSON(node: ["message": "Logged in",
                               "access_token" : newUser.token])
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        
        guard let token = req.auth.header?.bearer else {
            throw Abort.notFound
        }
        
        if let user = try User.query().filter("access_token", token.string).first() {
            
            var logoutedUser = User(user: user)
            
            try logoutedUser.save()
            try req.auth.logout()
            
            return try JSON(node: ["error": false,
                                   "message": "Logout succeded"])
        }
        throw Abort.badRequest
    }
    
    
    //MARK: - Token
    
    func token(for user: User) -> String {
        return encode(["hash":user.hash], algorithm: .hs256("secret".data(using: .utf8)!))
    }
}
