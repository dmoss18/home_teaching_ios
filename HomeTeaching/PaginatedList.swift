//
//  PaginatedList.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/13/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper

class PaginatedList<T: Mappable> : Mappable {
    var data : [T]?
    var perPage : Int?
    var totalPages : Int?
    var totalObjects : Int?
    var currentPage : Int?
    
    required init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data            <- map["data"]
        perPage         <- map["meta.per_page"]
        totalPages      <- map["meta.total_pages"]
        totalObjects    <- map["meta.total_objects"]
        currentPage     <- map["meta.current_page"]
    }
    
    func nextPage() -> Int {
        let page = self.currentPage ?? 1
        return self.hasNextPage() ? page + 1 : page
    }
    
    func hasNextPage() -> Bool {
        if self.totalPages == nil || self.currentPage == nil {
            return false
        }
        return self.currentPage! < self.totalPages!
    }
}
