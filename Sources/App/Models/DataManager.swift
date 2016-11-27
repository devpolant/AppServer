//
//  DataManager.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation

final class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    
    //MARK: - Menu Categories
    
    func deleteMenuCategory(_ menuCategory: MenuCategory) throws {
        
        for menuItem in try menuCategory.menuItems().all() {
            try menuItem.delete()
        }
        try menuCategory.delete()
    }
    
}
