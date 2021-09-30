//
//  Filter.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation

struct Filter {
    var roomTypes: [RoomType]
    var sellingTypes: [SellingType]
    var orderAsc: Bool
    var startIndex: Int
    
    mutating func addRoomType(type: Int) {
        roomTypes.append(RoomType.init(rawValue: type)!)
    }
    
    mutating func removeRoomType(type: Int) {
        roomTypes.removeAll(where: {$0.rawValue == type})
    }
    
    mutating func addSellingType(type: Int) {
        sellingTypes.append(SellingType.init(rawValue: type)!)
    }
    
    mutating func removeSellingType(type: Int) {
        sellingTypes.removeAll(where: {$0.rawValue == type})
    }
}
