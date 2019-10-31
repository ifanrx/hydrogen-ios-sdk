//
//  TableCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

var get_record_option = false
var record_list_option = false

class TableCase: MinCloudCase {

    let table = Table(name: "Book")
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_get_record() {
        let dict = SampleData.Table.get_record.toDictionary()
        table.get("5d5e5d2e989c1c336aa7b6bd") {record, error in
            ModelCase.recordEqual(record: record!, dict: dict!)
        }
    }
    
    func test_get_record_option() {
        get_record_option = true
        let dict = SampleData.Table.get_record_option.toDictionary()
        table.get("5d5e5d2e989c1c336aa7b6bd", select: ["color", "created_by"], expand: ["created_by"]) {record, error in
            ModelCase.recordEqual(record: record!, dict: dict!)
            get_record_option = false
        }
    }
    
    func test_record_list() {
        let dict = SampleData.Table.record_list.toDictionary()
        table.find() { (recordList, error) in
            ModelCase.recordListEqual(recordList: recordList!, dict: dict!)
        }
    }
    
    func test_record_list_option() {
        let dict = SampleData.Table.record_list_option.toDictionary()
        record_list_option = true
        let whereAgrs = Where.compare("color", operator: .equalTo, value: "brown")
        let query = Query()
        query.where = whereAgrs
        query.limit = 10
        query.offset = 0
        query.orderBy = ["created_at"]
        query.expand = ["created_by"]
        query.select = ["color", "created_by"]
        table.find(query: query) { (recordList, error) in
            record_list_option = false
            ModelCase.recordListEqual(recordList: recordList!, dict: dict!)
        }
    }
    
    func test_create_many_records() {
        let options = ["enable_trigger": true]
        table.createMany([["name": "麦田里的守望者", "price": 30], ["name": "三体", "price": 39]], options: options) {result, error in
            XCTAssertNotNil(result, "批量创建记录")
        }
    }
    
    func test_batch_update() {
        let whereArgs = Where.compare("price", operator: .lessThan, value: 15)
        let query = Query()
        query.where = whereArgs
        let options = ["enable_trigger": true]
        let record = table.createRecord()
        record.set("price", value: 35)
        table.update(record: record, query: query, options: options) { (result, error) in
            XCTAssertNotNil(result, "批量更新记录")
        }
    }
    
    func test_batch_delete() {
        let whereArgs = Where.contains("color", value: "brown")
        let query = Query()
        query.where = whereArgs
        let options = ["enable_trigger": true]
        table.delete(query: query, options: options, completion: {result, error in
            XCTAssertNotNil(result, "批量删除记录")
        })
    }
    
}

extension TableAPI {
    var testSampleData: Data {
        switch self {
        case .get:
            if get_record_option {
                return SampleData.Table.get_record_option
            }
            return SampleData.Table.get_record
        case .find:
            if record_list_option {
                return SampleData.Table.record_list_option
            }
            return SampleData.Table.record_list
        case .createRecords:
            return SampleData.Table.create_many_record
        case .delete:
            return SampleData.Table.batch_delete
        case .update:
            return SampleData.Table.batch_update
        }
    }
}

class TablePlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? TableAPI else {
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
    
    private func test_path(target: TableAPI) {
        let path = target.path
        switch target {
        case .get(let tableId, let recordId, _):
            XCTAssertEqual(Path.Table.recordDetail(tableId: tableId, recordId: recordId), path)
        case .find(let tableId, _):
            XCTAssertEqual(Path.Table.recordList(tableId: tableId), path)
        case .delete(let tableId, _):
            XCTAssertEqual(Path.Table.recordList(tableId: tableId), path)
        case .createRecords(let tableId, _, _):
            XCTAssertEqual(Path.Table.recordList(tableId: tableId), path)
        case .update(let tableId, _, _):
            XCTAssertEqual(Path.Table.recordList(tableId: tableId), path)
        }
    }
    
    private func test_method(target: TableAPI) {
        let method = target.method
        switch target {
        case .get, .find:
            XCTAssertEqual(method, Moya.Method.get)
        case .delete:
            XCTAssertEqual(method, Moya.Method.delete)
        case .createRecords:
            XCTAssertEqual(method, Moya.Method.post)
        case .update:
            XCTAssertEqual(method, Moya.Method.put)
        }
    }
    
    private func test_params(target: TableAPI) {
        
        switch target {
        case .get(_, _, let parameters):
            if get_record_option {
                XCTAssertTrue(parameters.keys.contains("keys"))
                XCTAssertTrue(parameters.keys.contains("expand"))
            }
        case .find(_, let parameters):
            if record_list_option {
                XCTAssertTrue(parameters.keys.contains("where"))
                XCTAssertTrue(parameters.keys.contains("keys"))
                XCTAssertTrue(parameters.keys.contains("expand"))
                XCTAssertTrue(parameters.keys.contains("limit"))
                XCTAssertTrue(parameters.keys.contains("offset"))
                XCTAssertTrue(parameters.keys.contains("order_by"))
            }
        case .delete(_, let parameters):
            XCTAssertTrue(parameters.keys.contains("where"))
            XCTAssertTrue(parameters.keys.contains("enable_trigger"))
        case .createRecords(_, let recordData, let parameters):
            XCTAssertTrue(parameters.keys.contains("enable_trigger"))
            XCTAssertNotNil(recordData)
        case .update(_, let urlParameters, let bodyParameters):
            XCTAssertTrue(urlParameters.keys.contains("where"))
            XCTAssertTrue(urlParameters.keys.contains("enable_trigger"))
            XCTAssertTrue(bodyParameters.keys.contains("price"))
        }
    }
}
