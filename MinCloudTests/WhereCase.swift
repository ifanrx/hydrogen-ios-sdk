//
//  WhereCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class WhereCase: MinCloudCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: or/and
    
    func test_or() {
        let whereArgs1 = Where.compare(key: "price", operator: .greaterThan, value: 5)
        let whereArgs2 = Where.compare(key: "price", operator: .lessThan, value: 10)
        let whereArgs = Where.or(wheres: [whereArgs1, whereArgs2])
        XCTAssertTrue(whereArgs.conditon.keys.contains("$or"))
        let conditions = whereArgs.conditon.getArray("$or", type: [String: Any].self)
        XCTAssertTrue(isDictEqual(dict1: whereArgs1.conditon, dict2: conditions[0]))
        XCTAssertTrue(isDictEqual(dict1: whereArgs2.conditon, dict2: conditions[1]))
    }
    
    func test_and() {
        let whereArgs1 = Where.compare(key: "price", operator: .greaterThan, value: 5)
        let whereArgs2 = Where.compare(key: "price", operator: .lessThan, value: 10)
        let whereArgs = Where.and(wheres: [whereArgs1, whereArgs2])
        XCTAssertTrue(whereArgs.conditon.keys.contains("$and"))
        let conditions = whereArgs.conditon.getArray("$and", type: [String: Any].self)
        XCTAssertTrue(isDictEqual(dict1: whereArgs1.conditon, dict2: conditions[0]))
        XCTAssertTrue(isDictEqual(dict1: whereArgs2.conditon, dict2: conditions[1]))
    }

    // MARK: compare
    
    func test_compare_eq() {
//        let condition: [String: Any] = ["price": ["$eq": 10.0]]
        
        let whereArgs = Where.compare(key: "price", operator: .equalTo, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$eq") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$eq") == 10.0))
    }
    
    func test_compare_record_eq() {
        let table = Table(name: "Book")
        let record = table.getWithoutData(recordId: "123")
        let whereArgs = Where.compare(key: "record", operator: .equalTo, value: record)
        XCTAssertTrue(whereArgs.conditon.keys.contains("record"))
        let valueDict = whereArgs.conditon.getDict("record") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$eq") ?? false)
        XCTAssertTrue((valueDict?.getString("$eq") == record.Id))
    }
    
    func test_compare_ne() {
        let whereArgs = Where.compare(key: "price", operator: .notEqualTo, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$ne") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$ne") == 10.0))
    }
    
    func test_compare_lt() {
        let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$lt") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$lt") == 10.0))
    }
    
    func test_compare_gt() {
        let whereArgs = Where.compare(key: "price", operator: .greaterThan, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$gt") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$gt") == 10.0))
    }
    
    func test_compare_gte() {
        let whereArgs = Where.compare(key: "price", operator: .greaterThanOrEqualTo, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$gte") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$gte") == 10.0))
    }
    
    func test_compare_lte() {
        let whereArgs = Where.compare(key: "price", operator: .lessThanOrEqualTo, value: 10.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$lte") ?? false)
        XCTAssertTrue((valueDict?.getDouble("$lte") == 10.0))
    }
    
    // MARK: range
    
    func test_range() {
        let whereArgs = Where.range(key: "price", start: 10.0, end: 20.0)
        XCTAssertTrue(whereArgs.conditon.keys.contains("price"))
        let valueDict = whereArgs.conditon.getDict("price") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$range") ?? false)
        let rangeValue = valueDict?.getArray("$range", type: Double.self)
        XCTAssertNotNil(rangeValue)
        XCTAssertTrue(rangeValue![0] == 10.0)
        XCTAssertTrue(rangeValue![1] == 20.0)
    }
    
    // MARK: String
    
    func test_contains() {
        let whereArgs = Where.contains(key: "name", value: "hua")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$contains") ?? false)
        XCTAssertTrue((valueDict?.getString("$contains") == "hua"))
    }
    
    func test_icontains() {
        let whereArgs = Where.icontains(key: "name", value: "hua")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$icontains") ?? false)
        XCTAssertTrue((valueDict?.getString("$icontains") == "hua"))
    }
    
    func test_matches() {
        let whereArgs = Where.matches(key: "title", regx: "/^foo/i")
        XCTAssertTrue(whereArgs.conditon.keys.contains("title"))
        let valueDict = whereArgs.conditon.getDict("title") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$regex") ?? false)
        let regex = valueDict!["$regex"] as? String
        XCTAssertEqual(regex!, "^foo")
        XCTAssertTrue(valueDict?.keys.contains("$options") ?? false)
        let options = valueDict!["$options"] as? String
        XCTAssertEqual(options!, "i")
        
    }
    
    // MARK: List
    
    func test_inList() {
        let condition: [String: Any] = ["array": ["$in": [1, 2, 3]]]
        let whereArgs = Where.inList(key: "array", list: [1, 2, 3])
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    func test_notInList() {
        let condition: [String: Any] = ["array": ["$nin": [1, 2, 3]]]
        let whereArgs = Where.notInList(key: "array", list: [1, 2, 3])
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    func test_arrayContains() {
        let condition: [String: Any] = ["array": ["$all": [1, 2, 3]]]
        let whereArgs = Where.arrayContains(key: "array", list: [1, 2, 3])
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    // MARK: NULL
    
    func test_isNull() {
        let whereArgs = Where.isNull(key: "name")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$isnull") ?? false)
        XCTAssertTrue((valueDict?.getBool("$isnull") == true))
    }
    
    func test_isNotNull() {
        let whereArgs = Where.isNotNull(key: "name")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$isnull") ?? false)
        XCTAssertTrue((valueDict?.getBool("$isnull") == false))
    }
    
    // MARK: Exist
    
    func test_exists() {
        let whereArgs = Where.exists(key: "name")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$exists") ?? false)
        XCTAssertTrue((valueDict?.getBool("$exists") == true))
    }
    
    func test_notExists() {
        let whereArgs = Where.notExists(key: "name")
        XCTAssertTrue(whereArgs.conditon.keys.contains("name"))
        let valueDict = whereArgs.conditon.getDict("name") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("$exists") ?? false)
        XCTAssertTrue((valueDict?.getBool("$exists") == false))
    }
    
    // MARK: hasKey
    
    func test_hasKey() {
        let condition: [String: Any] = ["name": ["$has_key": "dict"]]
        let whereArgs = Where.hasKey("name", fieldName: "dict")
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    // MARK: GEO
    
    func test_within() {
        let polygon = GeoPolygon(coordinates: [[0,0], [1,0], [1,1], [0,1], [0,0]])
        let condition = ["polygon": ["$within": polygon.geoJson]]
        let whereArgs = Where.within(key: "polygon", polygon: polygon)
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    func test_include() {
        let point = GeoPoint(longitude: 1, latitude: 2)
        let condition = ["point": ["$intersects": point.geoJson]]
        let whereArgs = Where.include(key: "point", point: point)
        XCTAssertTrue(isDictEqual(dict1: condition, dict2: whereArgs.conditon))
    }
    
    func test_withinCircle() {
        let point = GeoPoint(longitude: 1, latitude: 2)
        _ = ["point": ["$center": ["radius": 10, "coordinates": [point.longitude, point.latitude]]]]
        let whereArgs = Where.withinCircle(key: "point", point: point, radius: 10)
        XCTAssertTrue(whereArgs.conditon.keys.contains("point"))
        let centerDict = whereArgs.conditon.getDict("point") as? [String: Any]
        XCTAssertTrue(centerDict?.keys.contains("$center") ?? false)
        let valueDict = centerDict?.getDict("$center") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("radius") ?? false)
        XCTAssertTrue(valueDict?.keys.contains("coordinates") ?? false)
        let coordinates = valueDict?.getArray("coordinates", type: Double.self)
        XCTAssertEqual(coordinates![0], 1)
        XCTAssertEqual(coordinates![1], 2)
    }
    
    func test_withinRegion() {
        let point = GeoPoint(longitude: 1, latitude: 2)
        _ = ["point": ["$nearsphere": ["radius": 10, "coordinates": [point.longitude, point.latitude]]]]
        let whereArgs = Where.withinRegion(key: "point", point: point, minDistance: 5, maxDistance: 10)
        XCTAssertTrue(whereArgs.conditon.keys.contains("point"))
        let centerDict = whereArgs.conditon.getDict("point") as? [String: Any]
        XCTAssertTrue(centerDict?.keys.contains("$nearsphere") ?? false)
        let valueDict = centerDict?.getDict("$nearsphere") as? [String: Any]
        XCTAssertTrue(valueDict?.keys.contains("geometry") ?? false)
        XCTAssertTrue(valueDict?.keys.contains("min_distance") ?? false)
        XCTAssertTrue(valueDict?.keys.contains("max_distance") ?? false)
    }

    func test_isDictEqual() {
        let condition1: [String: Any] = ["array": ["$in": [1, 2, 3]]]
        let condition2: [String: Any] = ["array": ["$in": [1, 2, 3]]]
        XCTAssertTrue(isDictEqual(dict1: condition1, dict2: condition2))
    }
    
    func test_isDictEqual_N() {
        let condition1: [String: Any] = ["array": ["$in": [1, 2, 3]]]
        let condition2: [String: Any] = ["array": ["$nin": [1, 2, 3]]]
        XCTAssertFalse(isDictEqual(dict1: condition1, dict2: condition2))
    }

    
    func isDictEqual(dict1: [String: Any], dict2: [String: Any]) -> Bool {
        guard let key1 = dict1.keys.first, let key2 = dict2.keys.first, key1 == key2 else { return false }
        
        let valueDict1 = dict1.getDict(key1) as? [String: Any]
        let valueDict2 = dict2.getDict(key2) as? [String: Any]
        
        guard let valueKey1 = valueDict1?.keys.first, let valueKey2 = valueDict2?.keys.first, valueKey1 == valueKey2 else {
            return false
        }
        
        if valueDict1?[valueKey1] == nil {
            return false
        }
        
        if valueDict2?[valueKey2] == nil {
            return false
        }
        
        return true
    }

}
