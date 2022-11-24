import XCTest
import Alamofire
import Mocker
@testable import SwiftHsdpSdk


final class SwiftHsdpSdkTest: XCTestCase {
    
    var hsdpSDK: IamOAuth2!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        hsdpSDK = IamOAuth2(region: Region.EuWest, environment: .Prod, clientId: "test", clientSecret: "test", session: sessionManager);
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoginSucces() async throws {
        
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.loginResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.login(username: "username", password: "password")
        
        XCTAssertEqual(response.accessToken, "a5e488fc-7178-4cdw-937d-7136vg713a8d", "Access toking parsing is incorect")
    }
    
    func testLoginError() async throws {
        
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 400, data: [.post: MockedData.errorResponse.data])
        mock.register()
    
        do {
            _ = try await hsdpSDK.login(username: "username", password: "password")
         }
         catch let e as IamError {
             XCTAssertEqual(e, IamError.InvalidGrant)
         }
    }
    
    func testIntrospectSucces() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.introspect()
        
        XCTAssertEqual(response.sub, "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9", "Sub is incorect")
    }
    
    func testIntrospectFalseSucces() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectFalseResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.introspect()
        
        XCTAssertEqual(response.active, false)
    }
    
    func testIntrospectError() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 400, data: [.post: MockedData.errorResponse.data])
        mock.register()
    
        do {
            _ = try await hsdpSDK.login(username: "username", password: "password")
         }
         catch let e as IamError {
             XCTAssertEqual(e, IamError.InvalidGrant)
         }
    }
    
    func testRefreshSucces() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.refresh()
        
        XCTAssertEqual(response.accessToken, "fd9df3b047-141e-403df6-8373-94b1512bdfdf3303", "Accesstoken is incorect")
    }
    
    func testRefreshError() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 400, data: [.post: MockedData.errorResponse.data])
        mock.register()
    
        do {
            _ = try await hsdpSDK.refresh()
         }
         catch let e as IamError {
             XCTAssertEqual(e, IamError.InvalidGrant)
         }
    }
    
    func testRevokeSucces() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/revoke")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()
    
        try await hsdpSDK.revoke()
        
        XCTAssertTrue(hsdpSDK.token.accessToken.isEmpty, "Accesstoken is not empty")
    }
    
    func testRevokeError() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/revoke")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 400, data: [.post: MockedData.errorResponse.data])
        mock.register()
    
        do {
            _ = try await hsdpSDK.revoke()
         }
         catch let e as IamError {
             XCTAssertEqual(e, IamError.InvalidGrant)
         }
    }
    
    func testuserInfoSucces() async throws {
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9", expiration: .now.addingTimeInterval(5000))
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/userinfo")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.get: MockedData.userInfoResponse.data])
        mock.register()
    
        let userInfo = try await hsdpSDK.userInfo()
        
        XCTAssertEqual(userInfo.name, "Martijn van Welie", "Name is incorect")
    }
    
    func testAuthenticatorRefreshTokenBeforeExpiration() async throws {
        // Given an expired token
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9", expiration: .now.addingTimeInterval(-5000))
        
        // Given a response for a refresh
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        mock.register()
        
        // Given a error repsonse for get userinfo
        let apiEndpoint2 = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/userinfo")!
        let mock2 = Mock(url: apiEndpoint2, dataType: .json, statusCode: 400, data: [.get: MockedData.errorResponse.data])
        mock2.register()

        do {
            // Calling userInfo should first result in a call to refresh() because the token is expired
            _ = try await hsdpSDK.userInfo()
        } catch { }
        
        // Verify that we now have the new access token that came from the refresh that was done under the hood
        XCTAssertEqual(hsdpSDK.token.accessToken, "fd9df3b047-141e-403df6-8373-94b1512bdfdf3303", "Accesstoken is incorect")
    }
    
    func testAuthenticatorRefreshOn401() async throws {
        // Given a valid token
        hsdpSDK.token = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9", expiration: .now.addingTimeInterval(5000))
        
        // Given a response for a refresh
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        mock.register()
        
        // Given a error repsonse for get userinfo
        let apiEndpoint2 = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/userinfo")!
        let mock2 = Mock(url: apiEndpoint2, dataType: .json, statusCode: 401, data: [.get: Data()])
        mock2.register()

        do {
            // Calling userInfo should first result in a call to refresh() because the token is expired
            // But after that we still get a 401
            _ = try await hsdpSDK.userInfo()
        } catch let e as IamError {
            XCTAssertEqual(e, IamError.UnAuthorizedClient)
        }
        
        // Verify that we now have the new access token that came from the refresh that was done under the hood
        XCTAssertEqual(hsdpSDK.token.accessToken, "fd9df3b047-141e-403df6-8373-94b1512bdfdf3303", "Accesstoken is incorect")

    }
}

public final class MockedData {
    public static let loginResponse: URL = Bundle.module.url(forResource: "loginResponse", withExtension: "json")!
    public static let introspectResponse: URL = Bundle.module.url(forResource: "introspectResponse", withExtension: "json")!
    public static let introspectFalseResponse: URL = Bundle.module.url(forResource: "introspectFalseResponse", withExtension: "json")!
    public static let refreshResponse: URL = Bundle.module.url(forResource: "refreshResponse", withExtension: "json")!
    public static let errorResponse: URL = Bundle.module.url(forResource: "errorResponse", withExtension: "json")!
    public static let userInfoResponse: URL = Bundle.module.url(forResource: "userInfoResponse", withExtension: "json")!
}

internal extension URL {
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
