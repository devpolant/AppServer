//
//  PublicResponseRepresentable.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 02.12.16.
//
//

import Foundation
import Vapor

protocol PublicResponseRepresentable {
    func publicResponseNode() throws -> Node
}
