//
//  Assignment.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/29/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper

class Assignment : Mappable {
    var id: Int?
    var assignmentType: String?
    var household : Household?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id               <- map["id"]
        assignmentType   <- map["assignment_type"]
        household        <- map["household"]
    }
}
