//
//  User.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/26/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import ObjectMapper
import Locksmith

class User : Mappable, ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    var email: String?
    var authenticationToken: String?
    var id: Int?
    var quorumMember: QuorumMember?
    
    required init () {
        
    }
    
    required init?(map: Map) {
        // Optionally validate params before serialization
        // Return nil if they are invalid
    }
    
    func mapping(map: Map) {
        email               <- map["email"]
        authenticationToken <- map["authentication_token"]
        id                  <- map["id"]
        quorumMember        <- map["quorum_member"]
    }
    
    public let service = UserStore.keychainUser
    public var account = UserStore.keychainUser
    public var data: [String: Any] {
        return [
            "email": email as AnyObject,
            "authenticationToken": authenticationToken as AnyObject,
            "userId": id as AnyObject
        ]
    }
    
    public static func fromSecureStore() -> User? {
        guard let result = Locksmith.loadDataForUserAccount(userAccount: UserStore.keychainUser, inService: UserStore.keychainUser) else { return nil }
        let user = User()
        user.id = result["userId"] as! Int?
        if user.id == nil {
            return nil
        }
        user.authenticationToken = result["authenticationToken"] as! String?
        user.email = result["email"] as! String?
        return user
    }
}
