//
//  QueryCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class QueryCase: MinCloudCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_setWhere() {
        let whereArgs = Where.compare("price", operator: .equalTo, value: 10)
        let query = Query()
        query.where = whereArgs
        XCTAssertTrue(query.queryArgs.keys.contains("where"))
        let value = query.queryArgs.getString("where")
        XCTAssertEqual("{\n  \"price\" : {\n    \"$eq\" : 10\n  }\n}", value)
    }
    
    func test_select_without_id() {
        let query = Query()
        query.select = ["created_by", "user_id"]
        XCTAssertTrue(query.queryArgs.keys.contains("keys"))
        let value = query.queryArgs.getString("keys")
        let keys = value?.split(separator: ",")
        XCTAssertTrue(keys?.count == 3)
    }
    
    func test_select_with_id() {
        let query = Query()
        query.select = ["id", "created_by", "user_id"]
        XCTAssertTrue(query.queryArgs.keys.contains("keys"))
        let value = query.queryArgs.getString("keys")
        let keys = value?.split(separator: ",")
        XCTAssertTrue(keys?.count == 3)
    }
    
    func test_expand() {
        let query = Query()
        query.expand = ["created_by", "user_id"]
        XCTAssertTrue(query.queryArgs.keys.contains("expand"))
        let value = query.queryArgs.getString("expand")
        let keys = value?.split(separator: ",")
        XCTAssertTrue(keys?.count == 2)
    }
    
    func test_orderBy() {
        let query = Query()
        query.orderBy = ["created_at", "user_id"]
        XCTAssertTrue(query.queryArgs.keys.contains("order_by"))
        let value = query.queryArgs.getString("order_by")
        let keys = value?.split(separator: ",")
        XCTAssertTrue(keys?.count == 2)
    }
    
    func test_limit() {
        let query = Query()
        query.limit = 5
        XCTAssertTrue(query.queryArgs.keys.contains("limit"))
        let value = query.queryArgs.getInt("limit")
        XCTAssertEqual(5, value)
    }
    
    func test_offset() {
        let query = Query()
        query.offset = 10
        XCTAssertTrue(query.queryArgs.keys.contains("offset"))
        let value = query.queryArgs.getInt("offset")
        XCTAssertEqual(10, value)
    }
    
    func test_status_pending() {
        let query = OrderQuery()
        query.status = .pending
        XCTAssertTrue(query.queryArgs.keys.contains("status"))
        let value = query.queryArgs.getString("status")
        XCTAssertEqual("pending", value)
    }
    
    func test_status_success() {
        let query = OrderQuery()
        query.status = .success
        XCTAssertTrue(query.queryArgs.keys.contains("status"))
        let value = query.queryArgs.getString("status")
        XCTAssertEqual("success", value)
    }

    func test_refundStatus_partial() {
        let query = OrderQuery()
        query.refundStatus = .partial
        XCTAssertTrue(query.queryArgs.keys.contains("refund_status"))
        let value = query.queryArgs.getString("refund_status")
        XCTAssertEqual("partial", value)
    }
    
    func test_refundStatus_complete() {
        let query = OrderQuery()
        query.refundStatus = .complete
        XCTAssertTrue(query.queryArgs.keys.contains("refund_status"))
        let value = query.queryArgs.getString("refund_status")
        XCTAssertEqual("complete", value)
    }
    
    func test_gateWayType_partial() {
        let query = OrderQuery()
        query.gateWayType = .weixin
        XCTAssertTrue(query.queryArgs.keys.contains("gateway_type"))
        let value = query.queryArgs.getString("gateway_type")
        XCTAssertEqual("weixin_tenpay_app", value)
    }
    
    func test_tradeNo() {
        let query = OrderQuery()
        query.tradeNo = "12345"
        XCTAssertTrue(query.queryArgs.keys.contains("trade_no"))
        let value = query.queryArgs.getString("trade_no")
        XCTAssertEqual("12345", value)
    }
    
    func test_transactionNo() {
        let query = OrderQuery()
        query.transactionNo = "12345"
        XCTAssertTrue(query.queryArgs.keys.contains("transaction_no"))
        let value = query.queryArgs.getString("transaction_no")
        XCTAssertEqual("12345", value)
    }
    
    func test_merchandiseRecordId() {
        let query = OrderQuery()
        query.merchandiseRecordId = "12345"
        XCTAssertTrue(query.queryArgs.keys.contains("merchandise_record_id"))
        let value = query.queryArgs.getString("merchandise_record_id")
        XCTAssertEqual("12345", value)
    }
    
    func test_merchandiseSchemaId() {
        let query = OrderQuery()
        query.merchandiseSchemaId = "12345"
        XCTAssertTrue(query.queryArgs.keys.contains("merchandise_schema_id"))
        let value = query.queryArgs.getString("merchandise_schema_id")
        XCTAssertEqual("12345", value)
    }
}
