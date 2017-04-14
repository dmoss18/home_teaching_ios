//
//  UrlUtil.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/29/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation

class UrlBuilder {
    private var components: [String] = []

    init (_ base: String) {
        components.append(base)
    }

    public func resource(_ name: String, id: Int? = nil) -> UrlBuilder {
        components.append(name)
        if id != nil {
            components.append(String(id!))
        }
        return self
    }
    
    public func build() -> String {
        return components.joined(separator: "/")
    }
}
