//
//  RecordCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

class RecordCase: MinCloudCase {
    
    let table = Table(name: "Book")

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_create_record() {
        let dict =  SampleData.Record.create_record.toDictionary()
        
        // 新增数据，创建一个空的记录项
        let record = table.createRecord()

        // 逐个赋值
        record.set(key: "description", value: "这是本好书")

        // 一次性赋值
        record.set(record: ["price": 24, "name": "老人与海"])

        let point = GeoPoint(longitude: 2, latitude: 10)
        record.set(key: "location", value: point)

        let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
        record.set(key: "polygon", value: polygon)

        let pulish_info = ["name": "新华出版社"]
        record.set(key: "publish_info", value: pulish_info)

        record.set(key: "recommender", value: ["hua", "ming"])

        record.save {success, error in
            // 是否新建记录成功
            XCTAssertTrue(success)
            
            // 是否成功合并
            ModelCase.recordEqual(record: record, dict: dict!)
        }
    }
    
    func test_delete_record() {
        let record = table.getWithoutData(recordId: "5d80a0f6b569376e0b1d5064")
        record.delete(completion: { success, error in
            XCTAssertTrue(success)
        })
    }
    
    func test_delete_record_id_invalid() {
        let record = table.createRecord()
        record.delete(completion: { success, error in
            XCTAssertFalse(success)
            XCTAssertEqual(error?.code, 400)
        })
    }
    
    func test_update_record() {
        let dict =  SampleData.Record.update_record.toDictionary()
        
        let record = table.getWithoutData(recordId: "5d5e5d2e989c1c336aa7b6bd")
        record.set(key: "color", value: "brown")
        record.set(record: ["author": "hua", "name": "good book"])
        record.incrementBy(key: "price", value: 1)
        record.append(key: "recommender", value: ["hong"])

        record.update { success, error in
            XCTAssertTrue(success)
            XCTAssertEqual(record.Id, dict?.getString("id"))
            XCTAssertEqual(record.updatedAt, dict?.getDouble("updated_at"))
            XCTAssertEqual(record.get(key: "color") as? String, dict?.getString("color"))
            
        }
    }
    
    func test_update_record_id_invalid() {
        let record = table.createRecord()
        record.set(key: "price", value: 10)
        record.update { (success, error) in
            XCTAssertFalse(success)
            XCTAssertEqual(error?.code, 400)
        }
    }
}


extension TableRecordAPI {
    var testSampleData: Data {
        switch self {
        case .save:
            return SampleData.Record.create_record
        case .update:
            return SampleData.Record.update_record
        case .delete:
            return Data()
        }
    }
}

class RecordPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? TableRecordAPI else {
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
    
    private func test_path(target: TableRecordAPI) {
        let path = target.path
        switch target {
        case .delete(let tableId, let recordId):
            XCTAssertEqual(path, Path.Table.recordDetail(tableId: tableId, recordId: recordId))
        case .save(let tableId, _):
            XCTAssertEqual(path, Path.Table.saveRecord(tableId: tableId))
        case .update(let tableId, let recordId, _):
            XCTAssertEqual(path, Path.Table.recordDetail(tableId: tableId, recordId: recordId))
        }
    }
    
    private func test_method(target: TableRecordAPI) {
        let method = target.method
        switch target {
        case .update:
            XCTAssertEqual(method, Moya.Method.put)
        case .delete:
             XCTAssertEqual(method, Moya.Method.delete)
        case .save:
             XCTAssertEqual(method, Moya.Method.post)
        }
    }
    
    private func test_params(target: TableRecordAPI) {
        switch target {
        case .update(_, _, let parameters):
            XCTAssertTrue(parameters.keys.contains("color"))
            XCTAssertTrue(parameters.keys.contains("author"))
            XCTAssertTrue(parameters.keys.contains("price"))
            XCTAssertTrue(parameters.keys.contains("recommender"))
        case .delete:
             break
        case .save(_, let parameters):
            XCTAssertTrue(parameters.keys.contains("description"))
            XCTAssertTrue(parameters.keys.contains("price"))
            XCTAssertTrue(parameters.keys.contains("location"))
            XCTAssertTrue(parameters.keys.contains("polygon"))
            XCTAssertTrue(parameters.keys.contains("name"))
            XCTAssertTrue(parameters.keys.contains("publish_info"))
            XCTAssertTrue(parameters.keys.contains("recommender"))
        }
    }

}

