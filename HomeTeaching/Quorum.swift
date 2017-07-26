//
//  Quorum.swift
//  HomeTeaching
//
//  Created by Devin Moss on 7/25/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper

class Quorum : Mappable {

    var id: Int?
    var name: String?
    var quorumType: String?
    var wardId: Int?
    
    required init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id               <- map["id"]
        name             <- map["name"]
        quorumType       <- map["quorum_type"]
        wardId           <- map["ward_id"]
    }
}
