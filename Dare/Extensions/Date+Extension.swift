//
//  Date+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 23/01/2025.
//

import SwiftUI

extension Date {
    func timeAgoSinceDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(date)
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days) days ago"
        } else if hours > 0 {
            return "\(hours) hours ago"
        } else if minutes > 0 {
            return "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}
