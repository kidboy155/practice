//
//  Extentions.swift
//  TableView
//
//  Created by Nguyen Van  Quoc on 10/22/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import Foundation
import UIKit
public extension String {
    public func index(with offset: Int) -> Index {
        return self.index(startIndex, offsetBy: offset)
    }
    
    public func subString(from offset: Int) -> String {
        let fromIndex = index(with: offset)
        return String(self.suffix(from: fromIndex))
    }
    
    public func subString(to offset: Int) -> String {
        let toIndex = index(with: offset)
        
        return String(self.prefix(upTo: toIndex))
    }
    
    private func subString(from startOffset: Int, to endOffset: Int) -> String? {
        guard startOffset <= endOffset && startOffset >= 0 && endOffset < self.count else {
            print("Invalid String offset")
            return nil
        }
        let lo = index(with: startOffset)
        let hi = index(with: endOffset)
        let subRange = lo...hi
        return String(self[subRange])
    }
    
    public subscript(range: Range<Int>) -> String {
        return self.subString(with: range)
    }
    
    public subscript(range: ClosedRange<Int>) -> String {
        return subString(with: range)
    }
    
    public subscript(index: Int) -> String {
        return self.subString(with: index..<(index+1))
    }
    
    public func subString(with range: Range<Int>) -> String {
        let startIndex = index(with: range.lowerBound)
        let endIndex = index(with: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
    public func subString(with range: ClosedRange<Int>) -> String {
        let startIndex = index(with: range.lowerBound)
        let endIndex = index(with: range.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    
    public func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
        return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
    }
    
    
    public func indexes(of string: String, options: String.CompareOptions = .literal) -> [Int] {
        var result: [Int] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex, locale: nil) {
            let idx = distance(from: startIndex, to: range.lowerBound)
            result.append(idx)
            start = range.upperBound
        }
        return result
    }
    
    
    public func ranges(of string: String, options: String.CompareOptions = .literal) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex, locale: nil) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    init(htmlEncodedString: String) {
        self.init()
        guard let encodedData = htmlEncodedString.data(using: .utf8) else {
            self = htmlEncodedString
            return
        }
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = htmlEncodedString
        }
    }
}

public extension UIColor {
    public convenience init?(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:String!
        
        if rgba.hasPrefix("#") {
            hex = rgba.subString(from: 1)
        }
        else if(rgba.hasPrefix("0x"))
        {
            hex = rgba.subString(from: 2)
        }
        else
        {
            print("Invalid RGB string, missing '#' or '0x' as prefix")
            self.init(red:red, green:green, blue:blue, alpha:alpha)
            return nil
        }
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue)
        {
            switch (hex.count)
            {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
            }
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
