//
//  MenuController.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor
import HTTP

final class MenuController: DropletConfigurable {
    
    weak var drop: Droplet?
    
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
    
    private func setupRoutes() {
        
        guard let drop = drop else {
            debugPrint("Drop is nil")
            return
        }
        
        let merchantGroup = drop.grouped("merchant")
        let protectedGroup = merchantGroup.grouped(AuthenticationMiddleware())
        
        let menuGroup = protectedGroup.grouped("menu")
        
        let categoryGroup = menuGroup.grouped("category")
        categoryGroup.post("create", handler: createCategory)
        categoryGroup.post("edit", handler: createCategory)
        categoryGroup.post("delete", handler: createCategory)
        
        
    }
    
    
    //MARK: - Category
    
    func createCategory(_ req: Request) throws -> ResponseRepresentable {
        
        guard let merchant = try req.merchant() else {
            throw Abort.custom(status: .badRequest, message: "Merchant required")
        }
        guard let categoryName = req.data["category_name"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Category name required")
        }
        guard let description = req.data["category_description"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Category description required")
        }
        let photoUrl = req.data["photo_url"]?.string
        
        var menuCategory = MenuCategory(name: categoryName,
                                        description: description,
                                        merchantId: merchant.id!,
                                        photoUrl: photoUrl)
        try menuCategory.save()
        
        return try JSON(node: ["error": false,
                               "message": "Category added",
                               "category" : menuCategory.makeJSON()])
    }
    
    func editCategory(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func deleteCategory(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    
    //MARK: - Items
    
    func createItem(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func editItem(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    func deleteItem(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
}
