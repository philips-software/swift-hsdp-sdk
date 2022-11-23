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
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.introspect()
        
        XCTAssertEqual(response.sub, "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9", "Sub is incorect")
    }
    
    func testIntrospectFalseSucces() async throws {
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectFalseResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.introspect()
        
        XCTAssertEqual(response.active, false)
    }
    
    func testIntrospectError() async throws {
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d")
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
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        mock.register()
    
        let response = try await hsdpSDK.refresh()
        
        XCTAssertEqual(response.accessToken, "fd9df3b047-141e-403df6-8373-94b1512bdfdf3303", "Accesstoken is incorect")
    }
    
    func testRefreshError() async throws {
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
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
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/revoke")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.register()
    
        try await hsdpSDK.revoke()
        
        XCTAssertTrue(hsdpSDK.token.accessToken.isEmpty, "Accesstoken is not empty")
    }
    
    func testRevokeError() async throws {
        hsdpSDK.authenticationInterceptor.credential = Token(accessToken: "a5e488fc-7178-4cdw-937d-7136vg713a8d", refreshToken: "62dfdf06-ba7e-4edfd-874c-a3bdfdfdfa9")
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
}

public final class MockedData {
    public static let loginResponse: URL = Bundle.module.url(forResource: "loginResponse", withExtension: "json")!
    public static let introspectResponse: URL = Bundle.module.url(forResource: "introspectResponse", withExtension: "json")!
    public static let introspectFalseResponse: URL = Bundle.module.url(forResource: "introspectFalseResponse", withExtension: "json")!
    public static let refreshResponse: URL = Bundle.module.url(forResource: "refreshResponse", withExtension: "json")!
    public static let errorResponse: URL = Bundle.module.url(forResource: "errorResponse", withExtension: "json")!
}

internal extension URL {
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
