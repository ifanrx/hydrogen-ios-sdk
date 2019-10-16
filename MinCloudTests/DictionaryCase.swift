//
//  DictionaryCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/27.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class DictionaryCase: MinCloudCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_convertToMinDictionary() {
        let book = Table(name: "Book")
        let record = book.getWithoutData(recordId: "123")
        let point = GeoPoint(longitude: 1.0, latitude: 2.0)
        let point2 = GeoPoint(longitude: 3.0, latitude: 4.0)
        let point3 = GeoPoint(longitude: 5.0, latitude: 6.0)
        let polygon = GeoPolygon(points: [point, point2, point3, point])
        let user = User(Id: "123")
        record.set(record: ["price": 11.0, "point": point, "polygon": polygon, "user": user])
        
        let parameterForMinCloud = record.recordParameter.convertToMinDictionary()
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("price"))
        XCTAssertEqual(parameterForMinCloud.getDouble("price"), 11.0)
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("point"))
        let pointDict = parameterForMinCloud.getDict("point") as? [String: Any]
        XCTAssertTrue(pointDict?.keys.contains("type") ?? false)
        XCTAssertEqual(pointDict?.getString("type"), "Point")
        XCTAssertTrue(pointDict?.keys.contains("coordinates") ?? false)
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("polygon"))
        let polygonDict = parameterForMinCloud.getDict("polygon") as? [String: Any]
        XCTAssertTrue(polygonDict?.keys.contains("type") ?? false)
        XCTAssertEqual(polygonDict?.getString("type"), "Polygon")
        XCTAssertTrue(polygonDict?.keys.contains("coordinates") ?? false)
        
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("user"))
        XCTAssertEqual(parameterForMinCloud.getString("user"), "123")
    }

}
