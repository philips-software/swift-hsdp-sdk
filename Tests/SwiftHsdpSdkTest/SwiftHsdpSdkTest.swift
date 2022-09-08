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
        
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/token")!
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
        
        let apiEndpoint = URL(string: "https://iam-service.eu-west.philips-healthsuite.com/authorize/oauth2/introspect")!
        let mock = Mock(url: apiEndpoint, dataType: .json, statusCode: 200, data: [.post: MockedData.introspectResponse.data])
        mock.register()
        
        let request = IntrospectRequest(accessToken: "token", basicAuthentication: BasicAuthentication(username: "username", password: "password"));
        
        let response = try await hsdpSDK.introspect(ir: request);
        
        XCTAssertEqual(response.username, "user@philips.com", "Username parsing is incorect")
    }
    
}


public final class MockedData {
    public static let loginResponse: URL = Bundle.module.url(forResource: "loginResponse", withExtension: "json")!
    public static let introspectResponse: URL = Bundle.module.url(forResource: "introspectResponse", withExtension: "json")!
}

internal extension URL {
    var data: Data {
        return try! Data(contentsOf: self)
    }
}



