//
//  UserStore.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/29/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import Locksmith

class UserStore {
    public static let sharedInstance = UserStore()
    public static let keychainUser: String = "HomeTeachingUser"
    public static let keychainQuorumMember: String = "HomeTeachingQuorumMember"

    public var currentUser: User?
    public var currentQuorumMember: QuorumMember?
    public var authenticationToken: String? {
        get {
            if self.currentUser == nil {
                return nil
            }
            return self.currentUser?.authenticationToken
        }
        set(newValue) {
            if self.currentUser != nil {
                self.currentUser?.authenticationToken = newValue
            }
        }
    }
    
    init () {
        read()
    }
    
    public func read() {
        self.currentUser = User.fromSecureStore()
        self.currentQuorumMember = QuorumMember.fromSecureStore()
    }
    
    public func write(_ user: User, _ quorumMember: QuorumMember?) {
        self.currentUser = user
        self.currentQuorumMember = quorumMember
        write()
    }
    
    public func write() {
        do {
            try currentUser?.updateInSecureStore()
            try currentQuorumMember?.updateInSecureStore()
        } catch {
            print(error)
        }
    }
    
    public func delete() {
        self.currentUser = nil
        self.currentQuorumMember = nil
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: UserStore.keychainUser, inService: UserStore.keychainUser)
            try Locksmith.deleteDataForUserAccount(userAccount: UserStore.keychainQuorumMember, inService: UserStore.keychainQuorumMember)
        } catch {
            // Do nothing
        }
    }
    
    public func isLoggedIn() -> Bool {
        return authenticationToken != nil
    }
    
    public func isLinkedToQuorum() -> Bool {
        return self.currentQuorumMember != nil && self.currentQuorumMember!.id != nil
    }
}
