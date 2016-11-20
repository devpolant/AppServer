//
//  User.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 20.11.16.
//
//

import Foundation
import BCrypt

protocol User: class {
    var login: String { get set }
    var hash: String { get set }
    var token: String { get set }
}

extension User {
    
    func updateHash(from password: String) {
        self.hash = BCrypt.hash(password: password)
    }
    
    func isHashEqual(to password: String) -> Bool {
        var result = false
        do {
            result = try BCrypt.verify(password: password, matchesHash: hash)
        } catch {
            print("Error while check password equality: \(error)")
        }
        return result
    }
}
