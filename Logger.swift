//
//  Logger.swift
//  TrendmatchB2B
//
//  Created by Le Van Long on 6/11/19.
//  Copyright © 2019 Long Le. All rights reserved.
//

import Foundation

enum LogLevel: String {
    case error = " ‼️ "
    case info = " ℹ️ "
    case debug = " 💬 "
    case verbose = " 🔬 "
    case warning = " ⚠️ "
    case severe = " 🔥 "
}

class Logger {
    
    static var dateFormat = "yyyy-MM-dd HH:mm:ssSSSZ"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private init() {}
    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Loging methods
    
    class func error(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.error, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    class func info(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.info, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    class func debug(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.debug, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    class func verbose(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.verbose, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    class func warning(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.warning, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    class func severe(_ object: Any?, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        innerLog(object, logLevel: LogLevel.severe, filename: filename, line: line, column: column, funcName: funcName)
    }
    
    private class func innerLog(_ object: Any?, logLevel: LogLevel, filename: String, line: Int, column: Int, funcName: String) {
        guard isLoggingEnabled else { return }
        Swift.print("\(Date().logFormatString())\(logLevel.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName): ", separator: " ", terminator: " ")
        Swift.print(object ?? "NIL")
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

private extension Date {
    func logFormatString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
