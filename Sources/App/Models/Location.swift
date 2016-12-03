//
//  Location.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 03.12.16.
//
//

import Foundation

struct Location {
    
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}


//MARK: - Distance

/*
 * Return distance in meters.
 */
extension Location {
    
    func distance(to point: Location) -> Double {
        
        let R = 6371.0
        let dLat = (point.latitude - self.latitude) * 3.14 / 180
        let dLon = (point.longitude - self.longitude) * 3.14 / 180
        let latRad1 = self.latitude * 3.14 / 180
        let latRad2 = point.latitude * 3.14 / 180
        
        let a1 = sin(dLat/2) * sin(dLat/2)
        let a2 = sin(dLon/2) * sin(dLon/2) * cos(latRad1) * cos(latRad2)
        
        let a = a1 + a2
        let c = 2 * atan2(sqrt(a),sqrt(1-a))
        
        return R * c * 1_000
    }
}
