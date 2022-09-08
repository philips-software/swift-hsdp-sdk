import Foundation
import Alamofire
import SwiftUI


public class SwiftHsdpSdk {
    
    private let manager: Session

    public init(manager: Session = Session.default) {
        self.manager = manager
    }
    
    public func login(lr: LoginRequest) async throws -> LoginResponse
    {
        let basicAuthentication = "\(lr.basicAuthentication.username):\(lr.basicAuthentication.password)".data(using: .utf8)?.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication!)",
            "Content-Type": "application/x-www-form-urlencoded",
            "API-version": "2",
            "Accept": "*/*"
        ]
        
        let parameters: Parameters = [
            "grant_type": "password",
            "username": "\(lr.username)",
            "password": "\(lr.password)"
        ]
        
        return try await manager.request("https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token", method: .post, parameters: parameters, headers: headers).serializingDecodable(LoginResponse.self).value
    }
    
    public func introspect(ir: IntrospectRequest) async throws -> IntrospectResponse
    {
        let basicAuthentication = "\(ir.basicAuthentication.username):\(ir.basicAuthentication.password)".data(using: .utf8)?.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication!)",
            "Content-Type": "application/x-www-form-urlencoded",
            "API-version": "3",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "token": "\(ir.accessToken)"
        ]
        
        return try await manager.request("https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect", method: .post, parameters: parameters, headers: headers).serializingDecodable(IntrospectResponse.self).value
        
    }
    
}

public struct LoginResponse : Codable {
    
    public let access_token : String
    public let refresh_token : String
    public let scope : String
    public let token_type : String
    public let id_token : String
    public let expires_in : Int
}

public struct IntrospectResponse : Codable {
    
    public let active: Bool
    public let username: String
    public let scope: String
    public let exp: Int
    let organizations: Organization
}

struct Organization: Codable {
    
    let managingOrganization: String
    let organizationList: [OrganizationListItem]
}

struct OrganizationListItem: Codable {
    
    let organizationId : String
    let permissions : [String]
    
}

public struct LoginRequest {
    
    public init(username: String, password: String, basicAuthentication: BasicAuthentication) {
        self.username = username
        self.password = password
        self.basicAuthentication = basicAuthentication
    }
    
    let username : String
    let password : String
    let basicAuthentication : BasicAuthentication
    
}

public struct IntrospectRequest {
    
    public init(accessToken: String, basicAuthentication: BasicAuthentication) {
        self.accessToken = accessToken
        self.basicAuthentication = basicAuthentication
    }
    
    let accessToken : String
    let basicAuthentication : BasicAuthentication
    
}

public struct BasicAuthentication {
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    let username : String
    let password : String
}
