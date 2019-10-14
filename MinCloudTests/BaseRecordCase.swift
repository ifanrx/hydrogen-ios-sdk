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
        XCTAssertEqual(record.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(record.updatedAt, dict.getDouble("updated_at"))
        XCTAssertEqual(record.createdById, dict.getString("created_by"))
    }
    
    func test_init_created_by_dict() {
        let dict = SampleData.Record.base_record_created_by_dict.toDictionary()!
        let record = BaseRecord(dict: dict)!
        XCTAssertEqual(record.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(record.updatedAt, dict.getDouble("updated_at"))
        XCTAssertEqual(record.createdById, dict.getDict("created_by")?.getString("id"))
    }

    // MARK: set
    
    func test_one_set() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(key: "price", value: 11.0)
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        XCTAssertEqual(11.0, record.recordParameter.getDouble("price"))
    }
    
    func test_one_set_record() {
        let author = User(Id: "1001")
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(key: "author", value: author)
        XCTAssertTrue(record.recordParameter.keys.contains("author"))
        XCTAssertEqual("1001", record.recordParameter.getString("author"))
    }
    
    func test_one_set_GeoPoint() {
        let point = GeoPoint(longitude: 1.0, latitude: 2.0)
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(key: "point", value: point)
        XCTAssertTrue(record.recordParameter.keys.contains("point"))
        let geojson = record.recordParameter.getDict("point") as? [String: Any]
        XCTAssertTrue(geojson?.keys.contains("type") ?? false)
        XCTAssertEqual(geojson?.getString("type"), "Point")
        XCTAssertTrue(geojson?.keys.contains("coordinates") ?? false)
    }
    
    func test_one_set_GeoPolygon() {
        let polygon = GeoPolygon(coordinates: [[0,0], [1,1], [0,0]])
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(record: ["polygon": polygon])
        XCTAssertTrue(record.recordParameter.keys.contains("polygon"))
        let geojson = record.recordParameter.getDict("polygon") as? [String: Any]
        XCTAssertTrue(geojson?.keys.contains("type") ?? false)
        XCTAssertEqual(geojson?.getString("type"), "Polygon")
        XCTAssertTrue(geojson?.keys.contains("coordinates") ?? false)
    }
    
    func test_set() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(record: ["price": 11.0])
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        XCTAssertEqual(11.0, record.recordParameter.getDouble("price"))
    }
    
    func test_set_record() {
        let author = User(Id: "1001")
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(key: "author", value: author)
        XCTAssertTrue(record.recordParameter.keys.contains("author"))
        XCTAssertEqual("1001", record.recordParameter.getString("author"))
    }
    
    func test_set_GeoPoint() {
        let point = GeoPoint(longitude: 1.0, latitude: 2.0)
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(record: ["point": point])
        XCTAssertTrue(record.recordParameter.keys.contains("point"))
        let geojson = record.recordParameter.getDict("point") as? [String: Any]
        XCTAssertTrue(geojson?.keys.contains("type") ?? false)
        XCTAssertEqual(geojson?.getString("type"), "Point")
        XCTAssertTrue(geojson?.keys.contains("coordinates") ?? false)
    }
    
    func test_set_GeoPolygon() {
        let polygon = GeoPolygon(coordinates: [[0,0], [1,1], [0,0]])
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.set(record: ["polygon": polygon])
        XCTAssertTrue(record.recordParameter.keys.contains("polygon"))
        let geojson = record.recordParameter.getDict("polygon") as? [String: Any]
        XCTAssertTrue(geojson?.keys.contains("type") ?? false)
        XCTAssertEqual(geojson?.getString("type"), "Polygon")
        XCTAssertTrue(geojson?.keys.contains("coordinates") ?? false)
    }
    
    func test_unset_key() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.unset(key: "price")
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
        record.incrementBy(key: "price", value: 1)
        XCTAssertTrue(record.recordParameter.keys.contains("price"))
        let dict = record.recordParameter.getDict("price") as? [String: Any]
        XCTAssertEqual("$incr_by", dict?.keys.first)
    }
    
    func test_append() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.append(key: "array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$append", dict?.keys.first)
    }
    
    func test_uAppend() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.uAppend(key: "array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$append_unique", dict?.keys.first)
    }
    
    func test_remove() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.remove(key: "array", value: [1, 2, 4])
        XCTAssertTrue(record.recordParameter.keys.contains("array"))
        let dict = record.recordParameter.getDict("array") as? [String: Any]
        XCTAssertEqual("$remove", dict?.keys.first)
    }
    
    func test_updateObject() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        record.updateObject(key: "dict", value: ["key": "value"])
        XCTAssertTrue(record.recordParameter.keys.contains("dict"))
        let dict = record.recordParameter.getDict("dict") as? [String: Any]
        XCTAssertEqual("$update", dict?.keys.first)
    }

}
