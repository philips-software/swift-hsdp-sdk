
import Foundation
import Alamofire

public class IamOAuthAuthenticator : Authenticator {
    public var iam : IamOAuth2?
    
    public func apply(_ credential: Token, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }
    
    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Token) -> Bool {
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }
    
    public func refresh(_ credential: Token, for session: Session, completion: @escaping (Result<Token, Error>) -> Void) {
        guard let iam = iam else {
            print("no iam is set for authenticator")
            return
        }

        // Try token refresh
        Task {
            do {
                let token = try await iam.refresh()
                completion(.success(token))
            } catch {
                print("refresh failed")
            }
        }
    }
    
    public func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == 401
    }
    
    public init() {    }
}
