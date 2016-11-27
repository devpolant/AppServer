//
//  DropletConfigurable.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 27.11.16.
//
//

import Foundation
import Vapor

protocol DropletConfigurable: class {
    init(droplet: Droplet)
    func setup()
}
