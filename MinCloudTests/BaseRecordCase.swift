//
//  BaseRecordCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class BaseRecordCase: MinCloudCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: init
    func test_init() {
        let dict = SampleData.Record.base_record.toDictionary()!
        let record = BaseRecord(dict: dict)!
    }
    
    // create_by 为扩展时能否正常解析
    func test_init_created_by_dict() {
        let dict = SampleData.Record.base_record_created_by_dict.toDictionary()!
        let record = BaseRecord(dict: dict)!
    }

    // MARK: set
    
    func test_set() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set("price", value: 11.0)
        record.set("name", value: "goodbook")
        XCTAssertEqual(2, record.recordParameter.keys.count)
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        XCTAssertEqual(11.0, record.recordParameter.getDouble("price"))
        XCTAssertTrue(record.recordParameter.keys.contains("name"))
        XCTAssertEqual("goodbook", record.recordParameter.getString("name"))
    }
    
    func test_set_dict() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(["price": 11.0])
        record.set(["name": "goodbook"])
        XCTAssertEqual(2, record.recordParameter.keys.count)
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        XCTAssertEqual(11.0, record.recordParameter.getDouble("price"))
        XCTAssertTrue(record.recordParameter.keys.contains("name"))
        XCTAssertEqual("goodbook", record.recordParameter.getString("name"))
    }
    
    func test_unset_key() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.unset("price")
        XCTAssertTrue(record.recordParameter.keys.contains("$unset"))
        let unsetDict = record.recordParameter.getDict("$unset") as? [String: Any]
        XCTAssertEqual("price", unsetDict?.keys.first)
    }
    
    func test_unset_keys() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.unset(keys: ["price", "author"])
        XCTAssertTrue(record.recordParameter.keys.contains("$unset"))
        let unsetDict = record.recordParameter.getDict("$unset") as? [String: Any]
        XCTAssertTrue(unsetDict?.keys.contains("price") ?? false)
        XCTAssertTrue(unsetDict?.keys.contains("author") ?? false)
    }
    
    // MARK: 原子性
    
    func test_incrementBy() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.incrementBy("price", value: 1)
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        let dict = record.recordParameter.getDict("price") as? [String: Any]
        XCTAssertEqual("$incr_by", dict?.keys.first)
    }
    
    func test_append() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.append("array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$append", dict?.keys.first)
    }
    
    func test_uAppend() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.uAppend("array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$append_unique", dict?.keys.first)
    }
    
    func test_remove() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.remove("array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$remove", dict?.keys.first)
    }
    
    func test_updateObject() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.updateObject("dict", value: ["key": "value"])
        XCTAssertTrue(record.recordParameter.keys.contains("dict"))
        let dict = record.recordParameter.getDict("dict") as? [String: Any]
        XCTAssertEqual("$update", dict?.keys.first)
    }

}
