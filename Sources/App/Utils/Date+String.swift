//
//  Date+String.swift
//  AppServer
//
//  Created by Anton Poltoratskyi on 06.11.16.
//
//

import Foundation

extension Date {
    
    func toString() -> String? {
        
        let dateFormetter = DateFormatter()
        
        dateFormetter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormetter.calendar = Calendar(identifier: .gregorian)
        dateFormetter.dateFormat = "MM-dd-yyyy HH:mm"
        
        return dateFormetter.string(from: self)
    }
}
