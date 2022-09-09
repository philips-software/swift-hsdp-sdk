import Foundation
import Alamofire
import SwiftUI


public class SwiftHsdpSdk {
    
    private let manager: Session
    private let url: HsdpUrlBuilder
    
    public init(manager: Session = Session.default, url: HsdpUrlBuilder = HsdpUrlBuilder()) {
        self.manager = manager
        self.url = url
    }
    
    public func getHsdpUrlBuilder() -> HsdpUrlBuilder {
        return url;
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
        
        return try await manager.request("\(url.getIAMURL())\(url.tokenPath)", method: .post, parameters: parameters, headers: headers).serializingDecodable(LoginResponse.self).value
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
        
        return try await manager.request("\(url.getIAMURL())\(url.introspectPath)", method: .post, parameters: parameters, headers: headers).serializingDecodable(IntrospectResponse.self).value
    }
    
    public func refresh(rr: RefreshRequest) async throws -> RefreshResponse
    {
        let basicAuthentication = "\(rr.basicAuthentication.username):\(rr.basicAuthentication.password)".data(using: .utf8)?.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication!)",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*"
        ]
        
        let parameters: Parameters = [
            "grant_type": "refresh_token",
            "refresh_token": "\(rr.refreshToken)"
        ]
        
        return try await manager.request("\(url.getIAMURL())\(url.tokenPath)", method: .post, parameters: parameters, headers: headers).serializingDecodable(RefreshResponse.self).value
    }
    
    public func revoke(rr: RevokeRequest, onCompletion: @escaping ( Optional<Int>) -> Void)
    {
        let basicAuthentication = "\(rr.basicAuthentication.username):\(rr.basicAuthentication.password)".data(using: .utf8)?.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication!)",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*",
            "API-version": "2"
        ]
        
        let parameters: Parameters = [
            "token": "\(rr.token)"
        ]
        
        manager.request("\(url.getIAMURL())\(url.revokePath)", method: .post, parameters: parameters, headers: headers).responseData(emptyResponseCodes: [200]) {
            data in
            onCompletion(data.response?.statusCode)
        }.resume()
        
    }
    
}
