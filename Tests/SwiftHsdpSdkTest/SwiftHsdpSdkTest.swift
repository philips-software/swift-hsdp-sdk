import XCTest
import Alamofire
import Mocker
@testable import SwiftHsdpSdk


final class SwiftHsdpSdkTest: XCTestCase {
    
    
    func testLogin() async throws {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        let hsdpSDK = SwiftHsdpSdk(manager: sessionManager)
        let url = hsdpSDK.getHsdpUrlBuilder();
        
        let apiEndpoint = URL(string: "\(url.getIAMURL())\(url.tokenPath)")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.loginResponse.data])
        mock.register()
        
        let request = LoginRequest(username: "user@philips.com", password: "password!", basicAuthentication: BasicAuthentication(username: "username", password: "password"));
        
        let response = try await hsdpSDK.login(lr: request);
        
        XCTAssertEqual(response.access_token, "a5e488fc-7178-4cdw-937d-7136vg713a8d", "Access toking parsing is incorect")
    }
    
    func testIntrospect() async throws {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        let hsdpSDK = SwiftHsdpSdk(manager: sessionManager)
        let url = hsdpSDK.getHsdpUrlBuilder();
        
        let apiEndpoint = URL(string: "\(url.getIAMURL())\(url.introspectPath)")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectResponse.data])
        mock.register()
        
        let request = IntrospectRequest(accessToken: "token", basicAuthentication: BasicAuthentication(username: "username", password: "password"));
        
        let response = try await hsdpSDK.introspect(ir: request);
        
        XCTAssertEqual(response.username, "user@philips.com", "Username parsing is incorect")
    }
    
    func testRefresh() async throws {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        let hsdpSDK = SwiftHsdpSdk(manager: sessionManager)
        let url = hsdpSDK.getHsdpUrlBuilder();
        
        let apiEndpoint = URL(string: "\(url.getIAMURL())\(url.tokenPath)")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        mock.register()
        
        let request = RefreshRequest(refreshToken: "token", basicAuthentication: BasicAuthentication(username: "username", password: "password"));
        
        let response = try await hsdpSDK.refresh(rr: request);
        
        XCTAssertEqual(response.access_token, "fd9df3b047-141e-403df6-8373-94b1512bdfdf3303", "Username parsing is incorect")
    }
    
    func testRevoke() async throws {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        let sessionManager = Session(configuration: configuration)
        let hsdpSDK = SwiftHsdpSdk(manager: sessionManager)
        let url = hsdpSDK.getHsdpUrlBuilder();
        
        let apiEndpoint = URL(string: "\(url.getIAMURL())\(url.revokePath)")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.refreshResponse.data])
        let mockCalledback = expectation(description: "The mock should be called")
        mock.register()
        
        let request = RevokeRequest(token: "token", basicAuthentication: BasicAuthentication(username: "username", password: "password"));
        
        hsdpSDK.revoke(rr: request) {result in
            mockCalledback.fulfill()
            XCTAssertEqual(result!, 200, "200 ok is a succesfull revoke")
        };
        
        wait(for: [mockCalledback], timeout: 10.0)
    }
    
}

public final class MockedData {
    public static let loginResponse: URL = Bundle.module.url(forResource: "loginResponse", withExtension: "json")!
    public static let introspectResponse: URL = Bundle.module.url(forResource: "introspectResponse", withExtension: "json")!
    public static let refreshResponse: URL = Bundle.module.url(forResource: "refreshResponse", withExtension: "json")!
}

internal extension URL {
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
