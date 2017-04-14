//
//  QuorumMember.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/29/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper
import Locksmith

class QuorumMember : Mappable, ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var quorumId: Int?
    
    func displayName () -> String {
        return [lastName ?? "", firstName ?? ""].joined(separator: ", ")
    }
    
    required init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id               <- map["id"]
        firstName        <- map["first_name"]
        lastName         <- map["last_name"]
        quorumId         <- map["quorum_id"]
    }
    
    public let service = UserStore.keychainQuorumMember
    public var account = UserStore.keychainQuorumMember
    public var data: [String: Any] {
        return [
            "quorumMemberId": id as AnyObject,
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "quorumId": quorumId as AnyObject
        ]
    }
    
    public static func fromSecureStore() -> QuorumMember? {
        guard let result = Locksmith.loadDataForUserAccount(userAccount: UserStore.keychainQuorumMember, inService: UserStore.keychainQuorumMember) else { return nil }
            
        let quorumMember = QuorumMember()
        quorumMember.id = result["quorumMemberId"] as! Int?
        if quorumMember.id == nil {
            return nil
        }
        quorumMember.firstName = result["firstName"] as! String?
        quorumMember.lastName = result["lastName"] as! String?
        quorumMember.quorumId = result["quorumId"] as! Int?
        return quorumMember
    }
}
