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
        let file = File(dict: ["created_at": 1554287059, "id": "5ca489d3d625d846af4bf453", "mime_type": "image/png", "name": "test", "path": "https://cloud-minapp-25010.cloud.ifanrusercontent.com/1hBd47RKaLeXkOAF", "size": 2299, "category": ["id": "5ca489bb8c374f5039a8062b", "name": "Book"]])
        let user = User(Id: "123")
        record.set(record: ["price": 11.0, "point": point, "points": [point], "polygon": polygon, "polygons": [polygon], "user": user, "file": file!, "files": [file!]])
        
        let parameterForMinCloud = record.recordParameter.convertToMinDictionary()
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("price"))
        XCTAssertEqual(parameterForMinCloud.getDouble("price"), 11.0)
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("point"))
        let point1Dict = parameterForMinCloud.getDict("point") as! [String: Any]
        XCTAssertTrue(point1Dict.keys.contains("type"))
        XCTAssertEqual(point1Dict.getString("type"), "Point")
        XCTAssertTrue(point1Dict.keys.contains("coordinates"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("points"))
        let pointsDict = parameterForMinCloud.getArray("points", type: [String: Any].self)
        let point2Dict = pointsDict.first!
        XCTAssertTrue(point2Dict.keys.contains("type"))
        XCTAssertEqual(point2Dict.getString("type"), "Point")
        XCTAssertTrue(point2Dict.keys.contains("coordinates"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("polygon"))
        let polygon1Dict = parameterForMinCloud.getDict("polygon") as! [String: Any]
        XCTAssertTrue(polygon1Dict.keys.contains("type") )
        XCTAssertEqual(polygon1Dict.getString("type"), "Polygon")
        XCTAssertTrue(polygon1Dict.keys.contains("coordinates"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("polygons"))
        let polygonsDict = parameterForMinCloud.getArray("polygons", type: [String: Any].self)
        let polygon2Dict = polygonsDict.first!
        XCTAssertTrue(polygon2Dict.keys.contains("type") )
        XCTAssertEqual(polygon2Dict.getString("type"), "Polygon")
        XCTAssertTrue(polygon2Dict.keys.contains("coordinates"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("file"))
        let fileDict = parameterForMinCloud.getDict("file") as! [String: Any]
        XCTAssertTrue(fileDict.keys.contains("created_at"))
        XCTAssertTrue(fileDict.keys.contains("id"))
        XCTAssertTrue(fileDict.keys.contains("mime_type"))
        XCTAssertTrue(fileDict.keys.contains("name"))
        XCTAssertTrue(fileDict.keys.contains("cdn_path"))
        XCTAssertTrue(fileDict.keys.contains("size"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("file"))
        let filesDict = parameterForMinCloud.getArray("files", type: [String: Any].self)
        let file1Dict = filesDict.first!
        XCTAssertTrue(file1Dict.keys.contains("created_at"))
        XCTAssertTrue(file1Dict.keys.contains("id"))
        XCTAssertTrue(file1Dict.keys.contains("mime_type"))
        XCTAssertTrue(file1Dict.keys.contains("name"))
        XCTAssertTrue(file1Dict.keys.contains("cdn_path"))
        XCTAssertTrue(file1Dict.keys.contains("size"))
        
        XCTAssertTrue(parameterForMinCloud.keys.contains("user"))
        XCTAssertEqual(parameterForMinCloud.getString("user"), "123")
    }

}
