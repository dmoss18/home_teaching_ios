//
//  HomeTeachingService.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/26/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import PMKAlamofire
import ObjectMapper

class HttpService {
    open static let sharedInstance = HttpService()
    private let userStore: UserStore = UserStore.sharedInstance
//    private var baseUrl: String = "https://protected-sierra-11823.herokuapp.com"
    private var baseUrl: String = "http://localhost:3000"
    private var headers: [String: String?] = [
        "Content-Type": "application/json",
        "Authorization": nil
    ]
    
    private init() {
        // TODO: Read baseUrl from plist
    }
    
    func login(email: String, password: String) -> Promise<User> {
        let endpoint: String = UrlBuilder(baseUrl).resource("user_token").build()
        let parameters = [
            "email": email,
            "password": password
        ]
        
        return firstly { _ in
            sendRequest(endpoint, method: .post, parameters: parameters).responseString()
        }.then { jsonString -> User in
            let user = User(JSONString: jsonString)!
            self.userStore.write(user, user.quorumMember)
            self.updateAuthHeader(token: user.authenticationToken)
            return user
        }
    }
    
    func getAssignments(quorumMember: QuorumMember) -> Promise<[Assignment]> {
        let endpoint: String = UrlBuilder(baseUrl)
            .resource("quorums", id: quorumMember.quorumId)
            .resource("quorum_members", id: quorumMember.id)
            .resource("assignments")
            .build()
        
        return firstly { _ in
            sendRequest(endpoint).responseJSON()
        }.then { json -> [Assignment] in
            return self.parseArray(json: json)
        }
    }
    
    func createReport(_ report : Report) -> Promise<Report> {
        let endpoint: String = UrlBuilder(baseUrl)
            .resource("reports")
            .build()
        
        let parameters = [
            "assignment_id": String(report.assignmentId!),
            "status": report.status,
            "message": report.message,
            "household_name": report.householdName
        ]

        return firstly { _ in
            sendRequest(endpoint, method: .post, parameters: parameters).responseString()
        }.then { json -> Report in
            return Report(JSONString: json)!
        }
    }
    
    func getQuorumMembers(quorumId: Int, page: Int = 1) -> Promise<PaginatedList<QuorumMember>> {
        let endpoint: String = UrlBuilder(baseUrl)
            .resource("quorums", id: quorumId)
            .resource("quorum_members")
            .build()
        
        let parameters = [
            "page": page
        ]
        
        return firstly { _ in
            sendRequest(endpoint, parameters: parameters).responseString()
        }.then { json -> PaginatedList<QuorumMember> in
            return PaginatedList<QuorumMember>(JSONString: json)!
        }
    }
    
    func searchQuorumMembers(quorumId: Int, name: String) -> Promise<[QuorumMember]> {
        let endpoint: String = UrlBuilder(baseUrl)
            .resource("quorums", id: quorumId)
            .resource("quorum_members")
            .resource("search")
            .build()
        
        let parameters = [
            "name": name
        ]
        
        return firstly { _ in
            sendRequest(endpoint, parameters: parameters).responseJSON()
        }.then { json -> [QuorumMember] in
            return self.parseArray(json: json)
        }
    }
    
    func updateQuorumMember(member: QuorumMember, parameters : Parameters) -> Promise<QuorumMember> {
        let endpoint: String = UrlBuilder(baseUrl)
            .resource("quorum_members", id: member.id)
            .build()
        
        return firstly { _ in
            sendRequest(endpoint, method: .patch, parameters: parameters).responseString()
        }.then { json -> QuorumMember in
            return QuorumMember(JSONString: json)!
        }
    }
    
    private func sendRequest(
        _ endpoint: String, method: Alamofire.HTTPMethod = .get, parameters: Parameters? = nil) -> DataRequest {
        let encoding : ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        return Alamofire.request(
            endpoint, method: method, parameters: parameters, encoding: encoding).validate()
    }
    
    private func parseArray<T: Mappable>(json: Any) -> [T] {
        return Mapper<T>().mapArray(JSONArray: json as! [[String : Any]])!
    }
    
    
    private func updateAuthHeader(token: String?) {
        headers["Authorization"] = "Bearer \(token)"
    }
}
