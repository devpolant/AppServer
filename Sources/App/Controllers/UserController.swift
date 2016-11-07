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
        
        
        let protectedGroup = userGroup.grouped(AuthenticationMiddleware())
        protectedGroup.post("logout", handler: logout)
        protectedGroup.post("edit", handler: edit)
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
        
        guard let userId = try req.auth.user().id, var user = try User.find(userId) else {
            throw Abort.custom(status: .notFound, message: "User not found")
        }
        
        user.token = self.token(for: user)
        do {
            try user.save()
        } catch {
            print(error)
        }
        
        return try JSON(node: ["message": "Logged in",
                               "access_token" : user.token])
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        
        if var user = try req.auth.user() as? User {
            
            do {
                user.token = ""
                try user.save()
                try req.auth.logout()
                
            } catch {
                print(error)
            }
            
            return try JSON(node: ["error": false,
                                   "message": "Logout succeded"])
        }
        throw Abort.badRequest
    }
    
    
    //MARK: - Edit
    
    func edit(_ req: Request) throws -> ResponseRepresentable {
        
        if let user = try req.auth.user() as? User {
            
            var newUser = User(user: user)
            var isChanged = false
            
            if let newName = req.data["name"]?.string {
                newUser.name = newName
                isChanged = true
            }
            
            if let newLogin = req.data["login"]?.string {
                if (try User.query().filter("login", newLogin).first()) != nil {
                    throw Abort.custom(status: .badRequest, message: "Such login already exist")
                }
                newUser.login = newLogin
                isChanged = true
            }
            if isChanged {
                newUser.token = user.token
                try user.delete()
                try newUser.save()
                return try newUser.makeJSON()
            }
            throw Abort.custom(status: .badRequest, message: "No parameters")
        }
        throw Abort.custom(status: .badRequest, message: "Invalid credentials")
    }
    
    
    //MARK: - Token
    
    func token(for user: User) -> String {
        
        let startDate = Date().toString()
        let endDate = Date().addingTimeInterval(24 * 60 * 60).toString()
        
        if let startDate = startDate, let endDate = endDate {
            return encode(["start": startDate, "end": endDate],
                          algorithm: .hs256(user.hash.data(using: .utf8)!))
        } else {
            debugPrint("wrong dates")
            return ""
        }
    }
    
    
}
