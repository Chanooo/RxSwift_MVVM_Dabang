//
//  String+.swift
//  dabang
//
//  Created by 18101004 on 2021/09/30.
//

import Foundation

extension String {
    /// 1억6천 -> 16000
    func priceToInt() -> Int {
        var price = 0
        var priceTitle = self
        if self.contains("억") {
            price += priceTitle.subStringBeforeFirst(char: "억").toInt() * 10000
            priceTitle = priceTitle.subStringAfterFirst(char: "억")
            
        }
        
        if self.contains("천") {
            price += priceTitle.subStringBeforeFirst(char: "천").toInt() * 1000
            priceTitle = priceTitle.subStringAfterFirst(char: "천")
            
        }
        
        if self.contains("만원") {
            price += priceTitle.subStringBeforeFirst(char: "만").toInt()
        }
        
        return price
    }
    
    
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    
    /// "123456789".subString( from:0, to:4) -> "12345"
    func subString(from: Int, to: Int) -> String {
        if self.count <= 0 {
            return self
        } else if self.count <= from {
            return ""
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: min(self.count-1, to))
        return String(self[startIndex...endIndex])
    }
    
    
    /// "123456789".subString( from:4) -> "56789"
    func subString(from: Int) -> String {
        if self.count <= 0 {
            return self
        } else if self.count <= from {
            return ""
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: self.count-1)
        return String(self[startIndex...endIndex])
    }
    
    func subStringAfterLast(char: Character) -> String {
        if let index = self.lastIndex(of: char) {
            return String(self.suffix(from: index)).subString(from: 1)
        } else {
            return self
        }
    }
    
    func subStringAfterFirst(char: Character) -> String {
        if let index = self.firstIndex(of: char) {
            return String(self.suffix(from: index)).subString(from: 1)
        } else {
            return self
        }
    }
    
    func subStringBeforeLast(char: Character) -> String {
        if let index = self.lastIndex(of: char) {
            return String(self.prefix(upTo: index))
        } else {
            return self
        }
    }
    
    func subStringBeforeFirst(char: Character) -> String {
        if let index = self.firstIndex(of: char) {
            return String(self.prefix(upTo: index))
        } else {
            return self
        }
    }
    
    
    func firstIndexOf(char: Character) -> Int {
        return self.distance(of: char) ?? -1
    }
    
    func firstIndexOf(str: String) -> Int {
        return self.distance(of: str) ?? -1
    }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}


extension String.SubSequence {
    func toInt() -> Int {
        return Int(self) ?? 0
    }
}
