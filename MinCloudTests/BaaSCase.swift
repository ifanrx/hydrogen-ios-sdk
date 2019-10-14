//
//  BaaSCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

class BaaSCase: MinCloudCase {

    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_invoke() {
        BaaS.invoke(name: "helloWorld", data: ["name": "MinCloud"], sync: true) { result, error in
            XCTAssertNotNil(result)
        }
    }
    
    func test_send_sms_code() {
        BaaS.sendSmsCode(phone: "15088057274") { (success, error) in
            XCTAssertTrue(success)
        }
    }
    
    func test_verify_sms_code() {
        BaaS.verifySmsCode(phone: "15088057274", code: "123") { (success, error) in
            XCTAssertTrue(success)
        }
    }
}

extension BaaSAPI {
    var testSampleData: Data {
        switch self {
        case .invokeFunction:
            return SampleData.BaaS.invoke
        case .sendSmsCode:
            return "{\"status\" : \"ok\"}".data(using: String.Encoding.utf8)!
        case .verifySmsCode:
            return "{\"status\" : \"ok\"}".data(using: String.Encoding.utf8)!
            
        }
    }
}

class BaaSPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? BaaSAPI else {
            XCTFail("发送 AuthAPI 错误")
            return request
        }
        
        // 测试 path
        test_path(target: api)
        
        // 测试 method
        test_method(target: api)
        
        // 测试参数
        test_params(target: api)
        
        
        return request
    }
    
    private func test_path(target: BaaSAPI) {
        let path = target.path
        switch target {
        case .invokeFunction:
            XCTAssertEqual(path, Path.BaaS.cloudFunction)
        case .sendSmsCode:
            XCTAssertEqual(path, Path.BaaS.sendSmsCode)
        case .verifySmsCode:
            XCTAssertEqual(path, Path.BaaS.verifySmsCode)
        }
        
    }
    
    private func test_method(target: BaaSAPI) {
        let method = target.method
        switch target {
        case .invokeFunction, .sendSmsCode, .verifySmsCode:
            XCTAssertEqual(method, Moya.Method.post)
        }
    }
    
    private func test_params(target: BaaSAPI) {
        switch target {
        case .invokeFunction(let parameters):
            XCTAssertTrue(parameters.keys.contains("function_name"))
            XCTAssertTrue(parameters.keys.contains("data"))
            XCTAssertTrue(parameters.keys.contains("sync"))
        case .sendSmsCode(let parameters):
            XCTAssertTrue(parameters.keys.contains("phone"))
        case .verifySmsCode(let parameters):
            XCTAssertTrue(parameters.keys.contains("phone"))
            XCTAssertTrue(parameters.keys.contains("code"))
        }
    }
    
}
