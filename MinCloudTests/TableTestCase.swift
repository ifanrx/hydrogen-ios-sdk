//
//  TableTestCase.swift
//  MinCloudTests
//
//  Created by pengquanhua on 2019/4/11.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class TableTestCase: XCTestCase {

    var table: Table! = Table(name: "Book")
    var createdRecord: Record?
    var updatedRecord: Record?
    var atomicRecord: Record?
    var deleteRecord: Record?
    var data: NSDictionary!
    override func setUp() {
        BaaS.register(clientID: "fdc4feb5403a985fe681")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        table = nil
        createdRecord = nil
        updatedRecord = nil
        deleteRecord = nil
        atomicRecord = nil
    }

    // 获取数据详情
    func testGetRecord() {

        let promise = expectation(description: "Status code: 201")

        table?.get(data.getString("recordId")!, completion: { (record, error) in
            XCTAssertNotNil(record, "记录为 nil")
            XCTAssertNotNil(record!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 获取数据列表
    func testRecordList() {

        let promise = expectation(description: "Status code: 201")

        table?.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "数据列表为 nil")
            if listResult?.records?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.records?[0].Id, "数据项 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 新增数据
    func testCreateRecord() {
        let promise = expectation(description: "Status code: 201")
        createdRecord = table.createRecord()

        // 逐个赋值
        createdRecord?.set(key: "color", value: "red")

        // 一次性赋值
        createdRecord?.set(record: ["price": 24, "name": "normal book"])

        // date 类型
        //                let dateISO = ISO8601DateFormatter().string(from: Date())
        //                record.set(key: "publish_date", value: dateISO)

        // geoPoint 类型
        let point = GeoPoint(latitude: 10, longitude: 2)
        createdRecord?.set(key: "location", value: point)

        // polygon
        let polygon = GeoPolygon(coordinates: [[30, 10], [40, 40], [20, 40], [10, 20], [30, 10]])
        createdRecord?.set(key: "polygon", value: polygon)

        // object
        let pulish_info = ["name": "新华出版社"]
        createdRecord?.set(key: "publish_info", value: pulish_info)

        // array
        createdRecord?.set(key: "recommender", value: ["hua", "ming"])

        let authorTable = Table(name: "Author")
        let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
        createdRecord?.set(key: "writer", value: author)

        createdRecord?.save { (result, error) in
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            XCTAssertTrue(result)
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 更新一条记录
    func testUpdateRecord() {
        let promise = expectation(description: "Status code: 201")
        updatedRecord = table.getWithoutData(recordId: data.getString("recordId")!)

        // 逐个赋值
        updatedRecord?.set(key: "color", value: "red_update")

        // 一次性赋值
        updatedRecord?.set(record: ["price": 25, "name": "normal book update"])

//         // date 类型
//        let dateISO = ISO8601DateFormatter().string(from: Date())
//        updatedRecord?.set(key: "publish_date", value: dateISO)

        // geoPoint 类型
        let point = GeoPoint(latitude: 11, longitude: 12)
        updatedRecord?.set(key: "location", value: point)

        // polygon
        let polygon = GeoPolygon(coordinates: [[31, 11], [41, 41], [21, 41], [11, 21], [31, 11]])
        updatedRecord?.set(key: "polygon", value: polygon)

        // object
        let pulish_info = ["name": "新华出版社"]
        updatedRecord?.set(key: "publish_info", value: pulish_info)

        // array
        updatedRecord?.set(key: "recommender", value: ["hua", "ming"])

        // file

        let file = File()
        file.Id = "5cac34631071240a7f8c492d"
        file.cdnPath = "https://cloud-minapp-25010.cloud.ifanrusercontent.com/1hDjlboSpaKmXGgH"
        file.name = "test"
        file.createdAt = 1554789475
        file.mimeType = "image/png"
        file.size = 2299
        updatedRecord?.set(key: "cover", value: file.fileInfo)

        // unset
        updatedRecord?.unset(key: "location")

        let authorTable = Table(name: "Author")
        let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
        updatedRecord?.set(key: "writer", value: author)

        updatedRecord?.update { (result, error) in
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            XCTAssertTrue(result)
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 原子操作
    func testAtomic() {
        let promise = expectation(description: "Status code: 201")
        atomicRecord = table.getWithoutData(recordId: data.getString("atomic_recordId")!)

        atomicRecord?.incrementBy(key: "price", value: 1)
        atomicRecord?.append(key: "recommender", value: ["hong"])
        atomicRecord?.uAppend(key: "recommender", value: ["xiaoming", "xiaohong"])
        atomicRecord?.remove(key: "recommender", value: ["ming"])

        atomicRecord?.update { (result, error) in
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            XCTAssertTrue(result)
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 删除本记录
    func testDeleteRecord() {
        let promise = expectation(description: "Status code: 201")
        deleteRecord = table.getWithoutData(recordId: data.getString("delete_recordId")!)

        deleteRecord?.delete { (result, error) in
            if error != nil {
                XCTAssertTrue(error!.code == 404)
            } else {
                XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
                XCTAssertTrue(result)
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 批量删除记录
    func testDeletRecords() {
        let promise = expectation(description: "Status code: 201")

        let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 20)
        let query = Query()
        query.setWhere(whereArgs)
        let options = ["enable_trigger": true]

        table?.delete(query: query, options: options, completion: { (result, error) in
            XCTAssertNotNil(result, "结果为 nil")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // find 查询数据，过滤，扩展
    func testQuery() {
        let promise = expectation(description: "Status code: 201")

        // 设置查询条件
        let whereargs = Where.contains(key: "name", value: "老人与海")

        // 应用查询条件
        let query = Query()
        query.setWhere(whereargs)
        query.select(["created_by", "name"])
        query.expand(["created_by"])
        table?.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "数据列表为 nil")
            if listResult?.records?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.records?[0].Id, "数据项 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // find 查询 limit offset
    func testQueryOffsetandOrder() {
        let promise = expectation(description: "Status code: 201")

        let query = Query()
        query.limit(5)
        query.offset(1)
        table?.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "数据列表为 nil")
            if listResult?.records?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.records?[0].Id, "数据项 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // get 扩展 过滤
    func testGetExpandAndSelect() {

        let promise = expectation(description: "Status code: 201")

        let select = ["name"]
        let expand = ["created_by"]
        table?.get(data.getString("recordId")!, select: select, expand: expand, completion: {(record, error) in
            XCTAssertNotNil(record, "记录为 nil")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 批量更新
    func testBatchUpdate() {
        let promise = expectation(description: "Status code: 201")

        // 批量更新数据，如将价钱小于15的记录的价钱 增加 1.
        let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 15)
        let query = Query()
        query.setWhere(whereArgs)
        let options = ["enable_trigger": true]
        let record = table.createRecord()
        record.incrementBy(key: "price", value: 1)
        table.update(record: record, query: query, options: options) { (result, error) in
            XCTAssertNotNil(result, "结果为 nil")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
