//
//  Report.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/2/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper

class Report : Mappable {
    var id: Int?
    var assignmentId: Int?
    var message : String?
    var status: String?
    var householdName: String?
    
    required init(status: String?, message: String?, assignment: Assignment) {
        self.status = status
        self.message = message
        self.assignmentId = assignment.id
        self.householdName = assignment.household?.name
    }

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id              <- map["id"]
        assignmentId    <- map["assignment_id"]
        message         <- map["message"]
        status          <- map["status"]
        householdName   <- map["household_name"]
    }
}
