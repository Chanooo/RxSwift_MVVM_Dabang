//
//  RoomModel.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import RxDataSources

struct RoomModel: Codable {
    
    let desc : String
    let isCheck : Bool
    let priceTitle : String
    let roomType : Int
    let sellingType : Int
    let hashTags : [String]
    let imgUrl : String
    
    enum CodingKeys : String, CodingKey{
        case desc
        case isCheck = "is_check"
        case priceTitle = "price_title"
        case roomType = "room_type"
        case sellingType = "selling_type"
        case hashTags = "hash_tags"
        case imgUrl = "img_url"
    }
    
    init() {
        self.desc = "average"
        self.isCheck = false
        self.priceTitle = ""
        self.roomType = 0
        self.sellingType = 0
        self.hashTags = [""]
        self.imgUrl = ""
    }
}

struct RoomSection {
    var items: [RoomModel]
}

extension RoomSection: SectionModelType {
    typealias Item = RoomModel
    init(original: RoomSection, items: [RoomModel]) {
        self = original
        self.items = items
    }
    
    var identity: Int {  // 섹션 구분자
        return 0
    }
}
