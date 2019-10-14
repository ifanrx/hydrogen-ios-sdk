//
//  OrderCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

fileprivate var order_list_option = false

class OrderCase: MinCloudCase {

    override func setUp() {
        super.setUp()
        Pay.shared.payTooler = TestPayTooler()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_wx_pay() {
        let dict = SampleData.Order.wx_pay.toDictionary()
        Pay.shared.wxPay(totalCost: 0.01, merchandiseDescription: "微信支付", merchandiseSchemaID: "123", merchandiseRecordID: "123", merchandiseSnapshot: [:], completion: { (order, error) in
            XCTAssertNotNil(order)
            XCTAssertEqual(order?.tradeNo, dict?.getString("trade_no"))
            XCTAssertEqual(order?.transactionNo, dict?.getString("transaction_no"))
            XCTAssertTrue(Pay.shared.payTooler.wxPayCalled)
            Pay.shared.payTooler.wxPayCalled = false
        })
    }

    func test_ali_pay() {
        let dict = SampleData.Order.ali_pay.toDictionary()
        Pay.shared.aliPay(totalCost: 0.02, merchandiseDescription: "支付宝", merchandiseSchemaID: "123", merchandiseRecordID: "123", merchandiseSnapshot: [:], completion: { (order, error) in
            XCTAssertNotNil(order)
            XCTAssertEqual(order?.tradeNo, dict?.getString("trade_no"))
            XCTAssertEqual(order?.transactionNo, dict?.getString("transaction_no"))
            XCTAssertTrue(Pay.shared.payTooler.aliPayCalled)
            Pay.shared.payTooler.aliPayCalled = false
        })
    }
    
    func test_get_order() {
        let dict = SampleData.Order.get_order.toDictionary()
        Pay.shared.order("Zn2tRyp1V8q5YdMuvK8JRhSYyunl8SMd") { (order, error) in
            ModelCase.orderEqual(order: order!, dict: dict!)
        }
    }
    
    func test_order_list() {
        let dict = SampleData.Order.order_list.toDictionary()
        let query = Query()
        query.limit(10)
        query.offset(0)
        Pay.shared.orderList(query: query) { (orderList, error) in
            ModelCase.orderListEqual(list: orderList!, dict: dict!)
        }
    }

}

extension PayAPI {
    var testSampleData: Data {
        switch self {
        case .pay(let parameters):
            if parameters.getString("gateway_type") == WXPay {
                return SampleData.Order.wx_pay
            } else if parameters.getString("gateway_type") == AliPay {
                return SampleData.Order.ali_pay
            }
        case .order:
            return SampleData.Order.get_order
        case .orderList:
            return SampleData.Order.order_list
        }
        return Data()
    }
}

class OrderPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? PayAPI else {
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
    
    private func test_path(target: PayAPI) {
        let path = target.path
        switch target {
        case .pay:
            XCTAssertEqual(path, Path.Pay.pay)
        case .order(let transactionID):
            XCTAssertEqual(path, Path.Pay.order(transactionID: transactionID))
        case .orderList:
            XCTAssertEqual(path, Path.Pay.orderList)
        }
    }
    
    private func test_method(target: PayAPI) {
        let method = target.method
        switch target {
        case .pay:
            XCTAssertEqual(method, Moya.Method.post)
        case .order, .orderList:
            XCTAssertEqual(method, Moya.Method.get)
        }
    }
    
    private func test_params(target: PayAPI) {
        switch target {
        case .order:
            break
        case .pay(let parameters):
            XCTAssertTrue(parameters.keys.contains("gateway_type"))
            XCTAssertTrue(parameters.keys.contains("total_cost"))
            XCTAssertTrue(parameters.keys.contains("merchandise_description"))
            XCTAssertTrue(parameters.keys.contains("merchandise_schema_id"))
            XCTAssertTrue(parameters.keys.contains("merchandise_snapshot"))
            XCTAssertTrue(parameters.keys.contains("merchandise_record_id"))
        case .orderList(let parameters):
            XCTAssertTrue(parameters.keys.contains("limit"))
            XCTAssertTrue(parameters.keys.contains("offset"))
        }
    }
}

class TestPayTooler: PayProtocol {
    var wxPayCalled: Bool = false
    var aliPayCalled: Bool = false
    
    func payWithWX(_ request: PayReq, appId: String) {
        wxPayCalled = true
    }
    
    func payWithAli(_ paymentUrl: String, appId: String) {
        aliPayCalled = true
    }
}
