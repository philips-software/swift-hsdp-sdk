//
//  File.swift
//  
//
//  Created by matthijs.van.marion@philips.com on 08/09/2022.
//

import Foundation

public struct LoginResponse : Codable {
    
    public let access_token : String
    public let refresh_token : String
    public let scope : String
    public let token_type : String
    public let id_token : String
    public let expires_in : Int
}

public struct RefreshResponse : Codable {
    
    public let scope : String
    public let access_token : String
    public let token_type : String
    public let id_token : String
    public let expires_in : String
}

public struct IntrospectResponse : Codable {
    
    public let active: Bool
    public let username: Optional<String>
    public let scope: Optional<String>
    public let exp: Optional<Int>
    let organizations: Optional<Organization>
    public let client_id: Optional<String>
    public let token_type: Optional<String>
    public let identity_type: Optional<String>
}

struct Organization: Codable {
    
    let managingOrganization: String
    let organizationList: [OrganizationListItem]
}

struct OrganizationListItem: Codable {
    
    let organizationId : String
    let permissions : [String]
    let organizationName: String
    let groups : [String]
    let roles : [String]
    
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

public struct RefreshRequest {
    
    public init(refreshToken: String, basicAuthentication: BasicAuthentication) {
        self.refreshToken = refreshToken
        self.basicAuthentication = basicAuthentication
    }
    
    let basicAuthentication : BasicAuthentication
    let refreshToken: String
    
}

public struct RevokeRequest {
    
    public init(token: String, basicAuthentication: BasicAuthentication) {
        self.token = token
        self.basicAuthentication = basicAuthentication
    }
    
    let basicAuthentication : BasicAuthentication
    let token: String
    
}

public enum Environment: String {
    case Prod = "iam-service", Dev = "iam-dev", ClientTest = "iam-client-test"
}

public enum Region: String {
    case EuWest = "eu-west", UsEast = "us-east", UsWest = "us-west"
}

public struct HsdpUrlBuilder {
    
    public init(environment: Environment = Environment.Prod, region: Region = Region.EuWest) {
        self.environment = environment
        self.region = region
    }
    
    let environment: Environment
    let region: Region
    
    public let tokenPath = "authorize/oauth2/token"
    public let revokePath = "authorize/oauth2/revoke"
    public let introspectPath = "authorize/oauth2/introspect"
    public let userInfoPath = "authorize/oauth2/userinfo"
    
    public func getIAMURL() -> String {
        return "https://\(environment.rawValue).\(region.rawValue).philips-healthsuite.com/"
    }
}
