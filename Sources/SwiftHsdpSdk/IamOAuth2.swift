import Foundation
import Alamofire

public class IamOAuth2 {
    
    public let session: Session
    public let baseURL : String
    public var token : Token = Token()
    public let basicAuthentication : String
    
    public let tokenPath = "authorize/oauth2/token"
    public let revokePath = "authorize/oauth2/revoke"
    public let introspectPath = "authorize/oauth2/introspect"
    public let userInfoPath = "authorize/oauth2/userinfo"
    

    public convenience init(region: Region, environment: Environment, clientId: String, clientSecret: String, token: Token = Token(), session: Session = Session.default) {
        let url = "https://\(environment.rawValue).\(region.rawValue).philips-healthsuite.com/"
        self.init(baseURL: url, clientId: clientId, clientSecret: clientSecret, session: session)
    }
    
    public init(baseURL: String, clientId: String, clientSecret: String, token: Token = Token(), session: Session = Session.default) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
        self.basicAuthentication = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
    }
    
    fileprivate func processResponse<T>(_ response: DataResponse<String, AFError>, onSucces: (String) throws -> T) throws -> T {
        let statusCode = response.response!.statusCode
        if case let .failure(error) = response.result {
            if (statusCode == 404) {
                throw IamError.PathNotFound
            } else {
                print(error)
                throw IamError.Other
            }
        }
        
        if (200...299 ~= statusCode ) {
            return try onSucces(response.value!)
        } else if (400...499 ~= statusCode) {
            let iamErrorResponse = try JSONDecoder().decode(IamErrorResponse.self, from: Data(response.value!.utf8))
            throw IamError(rawValue: iamErrorResponse.error) ?? .Other
        } else {
            throw IamError.Other
        }
    }
    
    public func login(username: String, password: String) async throws -> Token
    {
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication)",
            "Content-Type": "application/x-www-form-urlencoded",
            "API-version": "2",
            "Accept": "*/*"
        ]
        
        let parameters: Parameters = [
            "grant_type": "password",
            "username": username,
            "password": password
        ]
        
        let response = await session.request(
            baseURL + tokenPath,
            method: .post,
            parameters: parameters,
            headers: headers
        ).serializingString().response
                
        return try processResponse(response) { responseString in
            let loginResponse : LoginResponse = try JSONDecoder().decode(LoginResponse.self, from: Data(response.value!.utf8))
            self.token = Token(from: loginResponse)
            return self.token
        }
    }
    
    public func introspect() async throws -> IntrospectResponse
    {
        return try await introspect(self.token)
    }
    
    public func introspect(_ token: Token) async throws -> IntrospectResponse
    {
        if token.accessToken.isEmpty { throw IamError.NoAccessToken }
            
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication)",
            "Content-Type": "application/x-www-form-urlencoded",
            "API-version": "3",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "token": token.accessToken
        ]
        
        let response = await session.request(
            baseURL + introspectPath,
            method: .post,
            parameters: parameters,
            headers: headers
        ).serializingString().response
        
        return try processResponse(response) { responseString in
            return try JSONDecoder().decode(IntrospectResponse.self, from: Data(response.value!.utf8))
        }
    }
    
    public func refresh() async throws -> Token
    {
        return try await refresh(self.token)
    }
    
    public func refresh(_ token: Token) async throws -> Token
    {
        if token.refreshToken.isEmpty { throw IamError.NoRefreshToken }
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication)",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*"
        ]
        
        let parameters: Parameters = [
            "grant_type": "refresh_token",
            "refresh_token": token.refreshToken
        ]
        
        let response = await session.request(
            baseURL + tokenPath,
            method: .post,
            parameters: parameters,
            headers: headers).serializingString().response
        
        return try processResponse(response) { responseString in
            print(responseString)
            let refreshResponse : RefreshResponse = try JSONDecoder().decode(RefreshResponse.self, from: Data(response.value!.utf8))
            self.token = self.token.update(from: refreshResponse)
            return self.token
        }
    }
    
    public func revoke() async throws
    {
        return try await revoke(self.token)
    }
    
    public func revoke(_ token: Token) async throws
    {
        if token.accessToken.isEmpty { throw IamError.NoAccessToken }
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuthentication)",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*",
            "API-version": "2"
        ]
        
        let parameters: Parameters = [
            "token": token.accessToken
        ]
        
        let response = await session.request(
            baseURL + revokePath,
            method: .post,
            parameters: parameters,
            headers: headers
        ).serializingString(emptyResponseCodes: [200]).response
        
        try processResponse(response) { responseString in
            self.token = Token()
        }
    }
}
