
import Foundation

public enum IamError : String, Error {
    /// 404, path not found
    case PathNotFound = "404"
    
    /// Invalid grant, the credentials provided are not valid
    case InvalidGrant = "invalid_grant"
    
    /// The specified grant type is unsupported
    case UnsupportedGrantType = "unsupported_grant_type"
    
    /// The provided client failed to authenticate. The clientId or clientSecret are wrong
    case ClientAuthenticationFailed = "invalid_client"
    
    /// The request is invalid
    case InvalidRequest = "invalid_request"
    
    /// Token has expired
    case TokenExpired = "token_expired"
    
    ///
    case UnAuthorizedClient = "unauthorized_client"
    
    ///  An unexpected error occured
    case Other = "other"
}

public struct IamErrorResponse : Codable {
    public let error: String
    public let error_description: String
}