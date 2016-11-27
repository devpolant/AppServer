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
            
        let categoryGroup = merchantGroup.grouped("menu").grouped("category")
        categoryGroup.post("create", handler: createCategory)
        categoryGroup.post("edit", handler: createCategory)
        categoryGroup.post("delete", handler: createCategory)
    }
    
    
    //MARK: - Category
    
    func createCategory(_ req: Request) throws -> ResponseRepresentable {
        return ""
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
