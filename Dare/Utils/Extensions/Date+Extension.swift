//
//  Date+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 23/01/2025.
//

import SwiftUI

extension Date {
    func timeAgoSinceDate() -> String {
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(self)
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30
        let years = days / 365

        if years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        } else if months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}
