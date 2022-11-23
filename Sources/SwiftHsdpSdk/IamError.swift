
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
    
    /// There is no access token
    case NoAccessToken = "no_access_token"

    /// There is no refresh token
    case NoRefreshToken = "no_refresh_token"
    
    /// Client is not authorized
    case UnAuthorizedClient = "unauthorized_client"
    
    /// Failed to get a new refresh token
    case TokenRefreshFailed = "token_refresh_failed"
    
    ///  An unexpected error occured
    case Other = "other"
}

public struct IamErrorResponse : Codable {
    public let error: String
    public let error_description: String
}
