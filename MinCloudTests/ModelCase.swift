//
//  ModelCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class ModelCase: MinCloudCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_current_user() {
        let dict = SampleData.User.userInfo.toDictionary()!
        let user = CurrentUser(dict: dict)!
        ModelCase.userEqual(user: user, dict: dict)
    }
    
    static func userEqual(user: User, dict: [String: Any]) {
        XCTAssertEqual(user.Id, dict.getString("id"))
        XCTAssertEqual(user.email, dict.getString("_email"))
        XCTAssertEqual(user.avatar, dict.getString("avatar"))
        XCTAssertEqual(user.isAuthorized, dict.getBool("is_authorized"))
        XCTAssertEqual(user.username, dict.getString("_username"))
        XCTAssertEqual(user.nickname, dict.getString("nickname"))
        XCTAssertEqual(user.gender, dict.getInt("gender"))
        XCTAssertEqual(user.country, dict.getString("country"))
        XCTAssertEqual(user.province, dict.getString("province"))
        XCTAssertEqual(user.city, dict.getString("city"))
        XCTAssertEqual(user.language, dict.getString("language"))
        XCTAssertEqual(user.unionid, dict.getString("unionid"))
        XCTAssertEqual(user.emailVerified, dict.getBool("_email_verified"))
        XCTAssertEqual(user.isAnonymous, dict.getBool("_anonymous"))
        XCTAssertEqual(user.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(user.updatedAt, dict.getDouble("updated_at"))
        XCTAssertEqual(user.createdById, dict.getString("created_by"))
    }
    
    func test_record() {
        let dict = SampleData.Table.get_record.toDictionary()!
        let record = Record(dict: dict)!
        ModelCase.recordEqual(record: record, dict: dict)
    }
    
    static func recordEqual(record: Record, dict: [String: Any]) {
        XCTAssertEqual(record.Id, dict.getString("id", "_id"))
        XCTAssertEqual(record.createdById, dict.getString("created_by"))
        XCTAssertEqual(record.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(record.updatedAt, dict.getDouble("updated_at"))
        XCTAssertEqual(record.acl, dict.getString("acl"))
    }
    
    func test_file() {
        let dict = SampleData.File.get_file.toDictionary()!
        let file = File(dict: dict)!
        ModelCase.fileEqual(file: file, dict: dict)
    }
    
    static func fileEqual(file: File, dict: [String: Any]) {
        XCTAssertEqual(file.Id, dict.getString("id"))
        XCTAssertEqual(file.name, dict.getString("name"))
        XCTAssertEqual(file.mimeType, dict.getString("mime_type"))
        XCTAssertEqual(file.size, dict.getInt("size"))
        XCTAssertEqual(file.cdnPath, dict.getString("path"))
        XCTAssertEqual(file.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(file.category.Id, dict.getDict("category")?.getString("id"))
        XCTAssertEqual(file.category.name, dict.getDict("category")?.getString("name"))
        
    }
    
    func test_file_category() {
        let dict = SampleData.File.get_category.toDictionary()!
        let category = FileCategory(dict: dict)!
        ModelCase.fileCategoryEqual(category: category, dict: dict)
    }
    
    static func fileCategoryEqual(category: FileCategory, dict: [String: Any]) {
        XCTAssertEqual(category.Id, dict.getString("id"))
        XCTAssertEqual(category.name, dict.getString("name"))
        XCTAssertEqual(category.files, dict.getInt("files"))
        XCTAssertEqual(category.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(category.updatedAt, dict.getDouble("updated_at"))
    }
    
    func test_content() {
        let dict = SampleData.Content.get_content.toDictionary()!
        let content = Content(dict: dict)!
        ModelCase.contentEqual(content: content, dict: dict)
    }
    
    static func contentEqual(content: Content, dict: [String: Any]) {
        XCTAssertEqual(content.Id, dict.getString("id"))
        XCTAssertEqual(content.title, dict.getString("title"))
        XCTAssertEqual(content.cover, dict.getString("cover"))
        XCTAssertEqual(content.desc, dict.getString("description"))
        XCTAssertEqual(content.categories, dict.getArray("categories", type: String.self))
        XCTAssertEqual(content.groupId, dict.getString("group_id"))
        XCTAssertEqual(content.content, dict.getString("content"))
        XCTAssertEqual(content.createdById, dict.getString("created_by"))
        XCTAssertEqual(content.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(content.updatedAt, dict.getDouble("updated_at"))
    }
    
    func test_content_category() {
        let dict = SampleData.Content.get_category.toDictionary()!
        let category = ContentCategory(dict: dict)!
        ModelCase.contentCategoryEqual(category: category, dict: dict)
    }
    
    static func contentCategoryEqual(category: ContentCategory, dict: [String: Any]) {
        XCTAssertEqual(category.Id, dict.getString("id"))
        XCTAssertEqual(category.name, dict.getString("name"))
        XCTAssertEqual(category.haveChildren, dict.getBool("have_children"))
        let children = dict.getArray("children", type: [String: Any].self)
        for (index, subDict) in children.enumerated() {
            XCTAssertEqual(category.children[index].Id, subDict.getString("id"))
            XCTAssertEqual(category.children[index].name, subDict.getString("name"))
        }
    }
    
    func test_order() {
        let dict = SampleData.Order.get_order.toDictionary()!
        let order = Order(dict: dict)!
        ModelCase.orderEqual(order: order, dict: dict)
    }
    
    static func orderEqual(order: Order, dict: [String: Any]) {
        XCTAssertEqual(order.Id, dict.getString("id"))
        XCTAssertEqual(order.tradeNo, dict.getString("trade_no"))
        XCTAssertEqual(order.transactionNo, dict.getString("transaction_no"))
        XCTAssertEqual(order.totalCost, dict.getDouble("total_cost"))
        XCTAssertEqual(order.status, dict.getString("status"))
        XCTAssertEqual(order.createdBy, dict.getString("created_by"))
        XCTAssertEqual(order.createdAt, dict.getDouble("created_at"))
        XCTAssertEqual(order.updatedAt, dict.getDouble("updated_at"))
        XCTAssertEqual(order.payAt, dict.getDouble("pay_at"))
        XCTAssertEqual(order.refundStatus, dict.getString("refund_status"))
        XCTAssertEqual(order.currencyType, dict.getString("currency_type"))
        XCTAssertEqual(order.gateWayType, dict.getString("gateway_type"))
        XCTAssertEqual(order.merchandiseRecordId, dict.getString("merchandise_record_id"))
        XCTAssertEqual(order.merchandiseSchemaId, dict.getString("merchandise_schema_id"))
        XCTAssertEqual(order.merchandiseDescription, dict.getString("merchandise_description"))
    }
    
    func test_GeoPoint() {
        let point = GeoPoint(longitude: 1.0, latitude: 2.0)
        XCTAssertTrue(point.geoJson.keys.contains("type"))
        XCTAssertTrue(point.geoJson.keys.contains("coordinates"))
        let coordinates = point.geoJson.getArray("coordinates", type: Double.self)
        XCTAssertEqual(coordinates, [1.0, 2.0])
    }
    
    func test_GeoPolygon1() {
        let polygon = GeoPolygon(coordinates: [[1.0, 1.0], [2.0, 2.0], [1.0, 1.0]])
        XCTAssertTrue(polygon.geoJson.keys.contains("type"))
        XCTAssertTrue(polygon.geoJson.keys.contains("coordinates"))
        XCTAssertEqual(polygon.coordinates, [[1.0, 1.0], [2.0, 2.0], [1.0, 1.0]])
        let coordinates = polygon.geoJson.getArray("coordinates", type: [[Double]].self)
        XCTAssertEqual(coordinates.first!, [[1.0, 1.0], [2.0, 2.0], [1.0, 1.0]])
    }
    
    func test_GeoPolygon2() {
        let point1 = GeoPoint(longitude: 1.0, latitude: 1.0)
        let point2 = GeoPoint(longitude: 2.0, latitude: 2.0)
        let point3 = GeoPoint(longitude: 1.0, latitude: 1.0)
        let polygon = GeoPolygon(points: [point1, point2, point3])
        XCTAssertTrue(polygon.geoJson.keys.contains("type"))
        XCTAssertTrue(polygon.geoJson.keys.contains("coordinates"))
        XCTAssertEqual(polygon.coordinates, [[1.0, 1.0], [2.0, 2.0], [1.0, 1.0]])
        let coordinates = polygon.geoJson.getArray("coordinates", type: [[Double]].self)
        XCTAssertEqual(coordinates.first!, [[1.0, 1.0], [2.0, 2.0], [1.0, 1.0]])
    }
    
     func test_list_result() {
        let dict = SampleData.Table.record_list.toDictionary()!
        let recordList = RecordList(dict: dict)!
        ModelCase.listResultEqual(recordList: recordList, dict: dict)
    }
    
    static func listResultEqual(recordList: ListResult, dict: [String: Any]) {
        guard let meta = dict["meta"] as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(recordList.limit, meta.getInt("limit"))
        XCTAssertEqual(recordList.offset, meta.getInt("offset"))
        XCTAssertEqual(recordList.totalCount, meta.getInt("total_count"))
        XCTAssertEqual(recordList.next, meta.getString("next"))
        XCTAssertEqual(recordList.previous, meta.getString("previous"))
    }
    
    func test_user_list() {
        let dict = SampleData.User.userList.toDictionary()!
        let userList = UserList(dict: dict)!
        ModelCase.listResultEqual(recordList: userList, dict: dict)
        ModelCase.userListEqual(userList: userList, dict: dict)
    }
    
    static func userListEqual(userList: UserList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for userDict in objects {
                userEqual(user: userList.users![index], dict: userDict)
                index += 1
            }
        }
    }
    
    func test_record_list() {
        let dict = SampleData.Table.record_list.toDictionary()!
        let recordList = RecordList(dict: dict)!
        ModelCase.listResultEqual(recordList: recordList, dict: dict)
        ModelCase.recordListEqual(recordList: recordList, dict: dict)
    }
    
    static func recordListEqual(recordList: RecordList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                recordEqual(record: recordList.records![index], dict: dict)
                index += 1
            }
        }
    }
    
    func test_file_list() {
        let dict = SampleData.File.file_list.toDictionary()!
        let list = FileList(dict: dict)!
        ModelCase.listResultEqual(recordList: list, dict: dict)
        ModelCase.fileListEqual(list: list, dict: dict)
    }
    
    static func fileListEqual(list: FileList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                fileEqual(file: list.files![index], dict: dict)
                index += 1
            }
        }
    }
    
    func test_file_category_list() {
        let dict = SampleData.File.get_category_list.toDictionary()!
        let list = FileCategoryList(dict: dict)!
        ModelCase.listResultEqual(recordList: list, dict: dict)
        ModelCase.fileCategoryListEqual(list: list, dict: dict)
    }
    
    static func fileCategoryListEqual(list: FileCategoryList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                fileCategoryEqual(category: list.fileCategorys![index], dict: dict)
                index += 1
            }
        }
    }
    
    func test_content_list() {
        let dict = SampleData.Content.content_list.toDictionary()!
        let list = ContentList(dict: dict)!
        ModelCase.listResultEqual(recordList: list, dict: dict)
        ModelCase.contentListEqual(list: list, dict: dict)
    }
    
    static func contentListEqual(list: ContentList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                contentEqual(content: list.contents![index], dict: dict)
                index += 1
            }
        }
    }
    
    func test_content_category_list() {
        let dict = SampleData.Content.category_list.toDictionary()!
        let list = ContentCategoryList(dict: dict)!
        ModelCase.listResultEqual(recordList: list, dict: dict)
        ModelCase.contentCategoryListEqual(list: list, dict: dict)
    }
    
    static func contentCategoryListEqual(list: ContentCategoryList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                contentCategoryEqual(category: list.contentCategorys![index], dict: dict)
                index += 1
            }
        }
    }
    
    func test_order_list() {
        let dict = SampleData.Order.order_list.toDictionary()!
        let list = OrderList(dict: dict)!
        ModelCase.listResultEqual(recordList: list, dict: dict)
        ModelCase.orderListEqual(list: list, dict: dict)
    }
    
    static func orderListEqual(list: OrderList, dict: [String: Any]) {
        if let objects = dict["objects"] as? [[String: Any]] {
            var index = 0
            for dict in objects {
                orderEqual(order: list.orders![index], dict: dict)
                index += 1
            }
        }
    }
}
