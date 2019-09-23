//
//  ContentCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

var get_content_option = false
var content_list_option = false

class ContentCase: MinCloudCase {
    
    let contentGroup = ContentGroup(Id: "1551697162031508")

    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_get_content() {
        let dict = SampleData.Content.get_content.toDictionary()
        contentGroup.get("1551697403189289") {content, error in
            ModelCase.contentEqual(content: content!, dict: dict!)
        }
    }
    
    func test_get_content_option() {
        get_content_option = true
        let dict = SampleData.Content.get_content_option.toDictionary()
        contentGroup.get("1551697403189289", select: ["title"]) {content, error in
            ModelCase.contentEqual(content: content!, dict: dict!)
            get_content_option = false
        }
    }
    
    func test_get_category() {
        let dict = SampleData.Content.get_category.toDictionary()
        contentGroup.getCategory("1551697507400928") { category, error in
            ModelCase.contentCategoryEqual(category: category!, dict: dict!)
        }
    }
    
    func test_content_list_option() {
        content_list_option = true
        let dict = SampleData.Content.content_list_option.toDictionary()
        let whereAgrs = Where.compare(key: "title", operator: .equalTo, value: "article")
        let query = Query()
        query.setWhere(whereAgrs)
        query.limit(10)
        query.offset(0)
        query.orderBy(["created_at"])
        query.select(["title"])
        contentGroup.find(query: query, completion: {contentList, error in
            ModelCase.contentListEqual(list: contentList!, dict: dict!)
            content_list_option = false
        })
    }
    
    func test_content_list() {
        let dict = SampleData.Content.content_list.toDictionary()
        contentGroup.find(completion: {contentList, error in
            ModelCase.contentListEqual(list: contentList!, dict: dict!)
        })
    }
    
    func test_content_list_in_category() {
        let dict = SampleData.Content.content_list_in_category.toDictionary()
        contentGroup.find(categoryId: "1551697507400928") { (contentList, error) in
            ModelCase.contentListEqual(list: contentList!, dict: dict!)
        }
    }
    
    func test_category_list() {
        let dict = SampleData.Content.category_list.toDictionary()
        let query = Query()
        query.limit(10)
        query.offset(0)
        contentGroup.getCategoryList(query: query) { categoryList, error in
            ModelCase.contentCategoryListEqual(list: categoryList!, dict: dict!)
        }
    }
}

extension ContentGroupAPI {
    var testSampleData: Data {
        switch self {
        case .conentDetail:
            if get_content_option {
                return SampleData.Content.get_content_option
            }
            return SampleData.Content.get_content
        case .contentList(let parameters):
            if parameters.keys.contains("keys") {
                return SampleData.Content.content_list_option
            }
            return SampleData.Content.content_list
        case .categoryDetail:
            return SampleData.Content.get_category
        case.contentListInCategory:
            return SampleData.Content.content_list_in_category
        case .categoryList:
            return SampleData.Content.category_list
        }
    }
}

class ContentPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? ContentGroupAPI else {
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
    
    private func test_path(target: ContentGroupAPI) {
        let path = target.path
        switch target {
        case .conentDetail(let contentId, _):
            XCTAssertEqual(path, Path.ContentGroup.contentDetail(contentId: contentId))
        case .contentList:
            XCTAssertEqual(path, Path.ContentGroup.contentList)
        case .contentListInCategory:
            XCTAssertEqual(path, Path.ContentGroup.contentList)
        case .categoryList:
            XCTAssertEqual(path, Path.ContentGroup.categoryList)
        case .categoryDetail(let categoryId):
            XCTAssertEqual(path, Path.ContentGroup.categoryDetail(categoryId: categoryId))

        }
    }
    
    private func test_method(target: ContentGroupAPI) {
        let method = target.method
        XCTAssertEqual(Moya.Method.get, method)
    }
    
    private func test_params(target: ContentGroupAPI) {
        switch target {
        case .conentDetail(_, let parameters):
            if get_content_option {
                XCTAssertTrue(parameters.keys.contains("keys"))
            }
        case .contentList(let parameters):
            if content_list_option {
                XCTAssertTrue(parameters.keys.contains("where"))
                XCTAssertTrue(parameters.keys.contains("keys"))
                XCTAssertTrue(parameters.keys.contains("limit"))
                XCTAssertTrue(parameters.keys.contains("offset"))
                XCTAssertTrue(parameters.keys.contains("order_by"))
            }
        case .contentListInCategory(let parameters):
            XCTAssertTrue(parameters.keys.contains("category_id"))
        case .categoryList(let parameters):
            XCTAssertTrue(parameters.keys.contains("limit"))
            XCTAssertTrue(parameters.keys.contains("offset"))
        case .categoryDetail:
            break
        }
    }
}
