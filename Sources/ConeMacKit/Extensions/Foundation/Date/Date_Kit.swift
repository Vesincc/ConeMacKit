//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension Date {
    
    /// 时间戳转字符串
    /// - Parameters:
    ///   - tramp: 时间戳
    ///   - dateFormat: dateFormat
    /// - Returns: 时间字符串
    static func timestampToDataFormat(_ tramp: Int, dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(tramp))
        let format = DateFormatter()
        format.dateFormat = dateFormat
        return format.string(from: date)
    }
    
}

public extension Date {
    
     
    /// 间隔几个小时
    /// - Parameter toDate: 截止时间
    /// - Returns: 小时
    func hourBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: self, to: toDate)
        return components.hour ?? 0
    }
    
    /// 日期转字符串
    /// - Parameters:
    ///   - dateFormat: 日期格式
    ///   - timezone: TimeZone
    ///   - localeIdentifier: Locale identifier
    /// - Returns: String
    func dateToString(dateFormat: String, timezone: TimeZone? = nil, localeIdentifier: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let tz = timezone {
            formatter.timeZone = tz
        }
        if let ld = localeIdentifier {
            formatter.locale = Locale(identifier: ld)
        }
        return formatter.string(from: self)
    }
    
    /// 当前时区 Calendar
    var calendar: Calendar {
        return Calendar(identifier: Calendar.current.identifier)
    }
    
    /// 年
    var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            if let date = calendar.date(byAdding: .year, value: yearsToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 月
    var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .month, in: .year, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = newValue - currentMonth
            if let date = calendar.date(byAdding: .month, value: monthsToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 日
    var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .day, in: .month, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = newValue - currentDay
            if let date = calendar.date(byAdding: .day, value: daysToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 小时
    var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = newValue - currentHour
            if let date = calendar.date(byAdding: .hour, value: hoursToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 分钟
    var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = newValue - currentMinutes
            if let date = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 秒
    var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .second, in: .minute, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentSeconds = calendar.component(.second, from: self)
            let secondsToAdd = newValue - currentSeconds
            if let date = calendar.date(byAdding: .second, value: secondsToAdd, to: self) {
                self = date
            }
        }
    }
    
}
