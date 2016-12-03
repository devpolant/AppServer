//
//  CustomerController.swift
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

enum CustomerAuthError: Error {
    case invalidCredentials
    case loginExists
}

class CustomerController: DropletConfigurable {
    
    weak var drop: Droplet?
    
    //MARK: - DropletConfigurable
    
    required init(droplet: Droplet) {
        self.drop = droplet
    }
    
    func setup() {
        guard drop != nil else {
            debugPrint("Drop is nil")
            return
        }
        setupRoutes()
    }
    
    
    //MARK: - Routes
    
    private func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let auth = AuthMiddlewareFactory.shared.customerAuthMiddleware
        
        let userGroup = drop.grouped("customer")
            .grouped(auth)
            .grouped("auth")
        
        userGroup.post("register", handler: register)
        userGroup.post("login", handler: login)
        
        let protectedGroup = userGroup.grouped(AuthenticationMiddleware())
        
        protectedGroup.post("logout", handler: logout)
        protectedGroup.post("edit", handler: edit)
        protectedGroup.post("profile", handler: showProfile)
        
        let passwordGroup = protectedGroup.grouped("password")
        
        passwordGroup.post("change", handler: changePassword)
        //passwordGroup.post("forgot", handler: forgotPassword)
    }
    
    
    //MARK: - Auth
    
    func register(_ req: Request) throws -> ResponseRepresentable {
        
        guard let name = req.data["name"]?.string,
            let login = req.data["login"]?.string,
            let password = req.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        if let _ = try Customer.query().filter("login", login).first() {
            throw CustomerAuthError.loginExists
        }
        
        var user = Customer(name: name, login: login, password: password)
        user.token = self.token(for: user)
        
        try user.save()
        
        return try JSON(node: ["error": false,
                               "message": "Successfully registered",
                               "access_token" : user.token])
    }
    
    func login(_ req: Request) throws -> ResponseRepresentable {
        
        guard let login = req.data["login"]?.string,
            let password = req.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = APIKey(id: login, secret: password)
        try req.auth.login(credentials)
        
        guard let userId = try req.auth.user().id, var user = try Customer.find(userId) else {
            throw CustomerAuthError.invalidCredentials
        }
        
        user.token = self.token(for: user)
        do {
            try user.save()
        } catch {
            print(error)
        }
        
        return try JSON(node: ["error": false,
                               "message": "Successfully logged in",
                               "access_token" : user.token])
    }
    
    func showProfile(_ req: Request) throws -> ResponseRepresentable {
        
        let customer = try req.customer()
        
        return try JSON(node: ["error": false,
                               "profile": customer.publicResponseNode()])
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        
        var user = try req.customer()
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
    
    
    //MARK: - Edit
    
    func edit(_ req: Request) throws -> ResponseRepresentable {
        
        var user = try req.customer()
        
        var isChanged = false
        
        if let newName = req.data["name"]?.string {
            user.name = newName
            isChanged = true
        }
        
        if let newLogin = req.data["login"]?.string {
            
            if (try Customer.query().filter("login", newLogin).first()) != nil {
                throw CustomerAuthError.loginExists
            }
            user.login = newLogin
            isChanged = true
        }
        if isChanged {
            try user.save()
            return try JSON(node: ["error": false,
                                   "message": "Customer profile changed"])
        }
        throw Abort.custom(status: .badRequest, message: "No parameters")
    }
    
    func changePassword(_ req: Request) throws -> ResponseRepresentable {
        
        var user = try req.customer()
        
        guard let oldPassword = req.data["old_password"]?.string,
            let newPassword = req.data["new_password"]?.string else {
                throw Abort.custom(status: .badRequest, message: "Old and new passwords required")
        }
        
        //TODO: Validate password with regex.
        
        if user.isHashEqual(to: oldPassword) {
            
            user.updateHash(from: newPassword)
            try user.save()
            
            return try JSON(node: ["error": false,
                                   "message": "Password changed"])
        }
        throw Abort.custom(status: .badRequest, message: "Wrong password")
    }
    
    
    //MARK: - Token
    
    func token(for user: Customer) -> String {
        
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
