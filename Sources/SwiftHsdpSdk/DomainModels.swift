
import Foundation
import Alamofire

public enum Environment : String {
    case Prod = "iam-service"
    case Dev = "iam-dev"
    case ClientTest = "iam-client-test"
}

public enum Region : String {
    case EuWest = "eu-west"
    case UsEast = "us-east"
    case UsWest = "us-west"
}

public struct LoginResponse : Codable {
    public let access_token : String
    public let refresh_token : String?
    public let scope : String
    public let token_type : String
    public let id_token : String?
    public let expires_in : UInt
}

public struct IntrospectResponse : Codable {
    public let active: Bool
    public let username: String?
    public let scope: String?
    public let exp: Int?
    public let sub: String?
    public let organizations: Organization?
}

public struct RefreshResponse : Codable {
    public let scope : String
    public let access_token : String
    public let token_type : String
    public let id_token : String?
    public let expires_in : String
}

public struct Organization: Codable {
    public let managingOrganization: String
    public let organizationList: [OrganizationListItem]
}

public struct OrganizationListItem: Codable {
    public let organizationId : String
    public let permissions : [String]
}

public struct UserInfo: Codable {
    public let sub: String
    public let name: String?
    public let given_name: String?
    public let family_name: String?
    public let email: String?
    public let address: String?
}

public struct Token : Codable, AuthenticationCredential {
    public var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 2) > expiration }
    
    public let tokenType: String
    public let scopes: [String]
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: UInt
    public let expiration: Date
    public let timestamp: Date

    public init(tokenType: String = "", scopes: [String] = [], accessToken: String = "", refreshToken: String = "", expiresIn: UInt = 0, expiration: Date? = nil) {
        self.tokenType = tokenType
        self.scopes = scopes
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.expiration = expiration ?? Date(timeIntervalSinceNow: Double(self.expiresIn))
        self.timestamp = .now
    }
    
    public init(from loginResponse: LoginResponse) {
        self.tokenType = loginResponse.token_type
        self.scopes = loginResponse.scope.components(separatedBy: " ")
        self.accessToken = loginResponse.access_token
        self.refreshToken = loginResponse.refresh_token ?? ""
        self.expiresIn = loginResponse.expires_in
        self.expiration = Date(timeIntervalSinceNow: Double(self.expiresIn))
        self.timestamp = .now
    }
    
    public func update(from refreshResponse: RefreshResponse) -> Token {
        return Token(
            tokenType: refreshResponse.token_type,
            scopes: refreshResponse.scope.components(separatedBy: " "),
            accessToken: refreshResponse.access_token,
            refreshToken: self.refreshToken,
            expiresIn: UInt(refreshResponse.expires_in) ?? 0
        )
    }
}
