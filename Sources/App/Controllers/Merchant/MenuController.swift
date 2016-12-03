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

class MenuController: DropletConfigurable {
    
    weak var drop: Droplet?
    
    required init(droplet: Droplet) {
        self.drop = droplet
    }
    
    //MARK: - Setup
    
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
        
        let merchantAuth = AuthMiddlewareFactory.shared.merchantAuthMiddleware
        
        let menuGroup = drop.grouped("merchant")
            .grouped(merchantAuth)
            .grouped(AuthenticationMiddleware())
            .grouped("menu")
        
        let categoryGroup = menuGroup.grouped("category")
        
        categoryGroup.post("list", handler: categoriesList)
        categoryGroup.post("items", ":category_id", handler: categoryItemsList)
        categoryGroup.post("create", handler: createCategory)
        categoryGroup.post("edit", handler: editCategory)
        categoryGroup.post("delete", handler: deleteCategory)
        
        let menuItemsGroup = menuGroup.grouped("item")
        
        menuItemsGroup.post("create", handler: createItem)
        menuItemsGroup.post("edit", handler: editItem)
        menuItemsGroup.post("delete", handler: deleteItem)
    }
    
    
    //MARK: Menu List
    
    func categoriesList(_ req: Request) throws -> ResponseRepresentable {
        
        guard let merchant = try req.merchant() else {
            throw Abort.custom(status: .badRequest, message: "Merchant required")
        }
        var responseNodes = [Node]()
        
        for category in try merchant.menuCategories().all() {
            responseNodes.append(try category.makeNode())
        }
        return try JSON(node: ["error": false,
                               "menu_categories": Node.array(responseNodes)])
    }
    
    func categoryItemsList(_ req: Request) throws -> ResponseRepresentable {
        
        guard let categoryId = req.parameters["category_id"]?.string,
            let category = try MenuCategory.find(categoryId) else {
            throw Abort.custom(status: .badRequest, message: "Category id required")
        }
        var responseNodes = [Node]()
        
        for menuItem in try category.menuItems().all() {
            responseNodes.append(try menuItem.makeNode())
        }
        return try JSON(node: ["error": false,
                               "menu_items": Node.array(responseNodes)])
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
        
        var menuCategory = try req.menuCategory()
        
        var isChanged = false
        
        if let categoryName = req.data["category_name"]?.string {
            menuCategory.name = categoryName
            isChanged = true
        }
        if let categoryDescription = req.data["category_description"]?.string {
            menuCategory.description = categoryDescription
            isChanged = true
        }
        if let photo = req.data["photo_url"]?.string {
            menuCategory.photoUrl = photo
            isChanged = true
        }
        if isChanged {
            try menuCategory.save()
            
            return try JSON(node: ["error": false,
                                   "message": "Category edited",
                                   "category" : menuCategory.makeJSON()])
        }
        throw Abort.custom(status: .badRequest, message: "No parameters")
    }
    
    func deleteCategory(_ req: Request) throws -> ResponseRepresentable {
        
        let menuCategory = try req.menuCategory()
    
        try DataManager.shared.deleteMenuCategory(menuCategory)
        
        return try JSON(node: ["error": false,
                               "message": "Category deleted"])
    }
    
    
    //MARK: - Menu Items
    
    func createItem(_ req: Request) throws -> ResponseRepresentable {
        
        let menuCategory = try req.menuCategory()
        
        guard let name = req.data["name"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Menu item name required")
        }
        guard let description = req.data["description"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Menu item description required")
        }
        guard let price = req.data["price"]?.double else {
            throw Abort.custom(status: .badRequest, message: "Menu item price required")
        }
        let photoUrl = req.data["photo_url"]?.string
        
        
        var menuItem = MenuItem(name: name,
                                description: description,
                                photoUrl: photoUrl,
                                price: price,
                                menuCategoryId: menuCategory.id!)
        try menuItem.save()
        
        return try JSON(node: ["error": false,
                               "message": "Menu item added",
                               "menu_item" : menuItem.makeJSON()])
    }
    
    func editItem(_ req: Request) throws -> ResponseRepresentable {
        
        var menuItem = try req.menuItem()
        
        var isChanged = false
        
        if let name = req.data["name"]?.string {
            menuItem.name = name
            isChanged = true
        }
        
        if let categoryDescription = req.data["description"]?.string {
            menuItem.description = categoryDescription
            isChanged = true
        }
        if let photo = req.data["photo_url"]?.string {
            menuItem.photoUrl = photo
            isChanged = true
        }
        if let photo = req.data["price"]?.double {
            menuItem.price = photo
            isChanged = true
        }
        if isChanged {
            try menuItem.save()
            
            return try JSON(node: ["error": false,
                                   "message": "Menu item edited",
                                   "menu_item" : menuItem.makeJSON()])
        }
        throw Abort.custom(status: .badRequest, message: "No parameters")
    }
    
    func deleteItem(_ req: Request) throws -> ResponseRepresentable {
        
        let menuItem = try req.menuItem()
        try menuItem.delete()
        
        return try JSON(node: ["error": false,
                               "message": "Menu item deleted"])
    }
    
}
