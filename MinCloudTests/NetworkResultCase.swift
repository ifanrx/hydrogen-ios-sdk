//
//  NetworkResultCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

class NetworkResultCase: MinCloudCase {
    
    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_result_parse_200() {
        let result: Result<Moya.Response, MoyaError> = .success(Response(statusCode: 200, data: SampleData.Auth.curUser))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
        }
    }

    func test_result_parse_201() {
        let result: Result<Moya.Response, MoyaError> = .success(Response(statusCode: 200, data: SampleData.Auth.curUser))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
        }
    }
    
    // 错误信息为 json 格式
    func test_result_parse_error_json_400() {
        let result: Result<Moya.Response, MoyaError> = .success(Response(statusCode: 400, data: SampleData.Network.network_error_json))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(400, error?.code)
            XCTAssertEqual(error?.localizedDescription, SampleData.Network.network_error_json.toDictionary()?.getString("error_msg"))
        }
    }
    
    // 错误信息为 String 格式
    func test_result_parse_error_message_400() {
        let result: Result<Moya.Response, MoyaError> = .success(Response(statusCode: 400, data: "网络错误".data(using: String.Encoding.utf8)!))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(400, error?.code)
            XCTAssertEqual(error?.localizedDescription, "网络错误")
        }
    }
    
    // 只有状态码，错误信息为空
    func test_result_parse_error_nil_400() {
        let result: Result<Moya.Response, MoyaError> = .success(Response(statusCode: 400, data: Data()))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(400, error?.code)
        }
    }
    
    func test_network_failure() {
        let result: Result<Moya.Response, MoyaError> = .failure(MoyaError.jsonMapping(Response(statusCode: 400, data: Data())))
        ResultHandler.parse(result) { (result: CurrentUser?, error: NSError?) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
        }
    }
    
    
}
