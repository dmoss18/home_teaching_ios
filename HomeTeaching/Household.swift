//
//  Household.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/29/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper

class Household : Mappable {
    var id : Int?
    var name : String?
    var street : String?
    var city : String?
    var state : String?
    var zip : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        street      <- map["street"]
        city        <- map["city"]
        state       <- map["state"]
        zip         <- map["zip"]
    }
}
