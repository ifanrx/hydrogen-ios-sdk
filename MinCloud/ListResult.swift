//
//  ListResult.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/10.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

@objc(BaaSListResult)
public class ListResult: NSObject, Mappable {

    @objc public internal(set) var limit: Int = 20

    @objc public internal(set) var offset: Int = 0

    @objc public internal(set) var totalCount: Int = -1 // 默认该属性无效

    @objc public internal(set) var next: String?  // 下一页地址，nil 表示当前为 最后一页

    @objc public internal(set) var previous: String? // 上一页地址，nil 表示当前为 第一页
    
    @objc public internal(set) var listInfo: [String: Any] = [:]
    
    public override init() {
        super.init()
    }

    required public init?(dict: [String: Any]) {
        guard let meta = dict["meta"] as? [String: Any] else { return nil }
        self.limit = meta.getInt("limit")
        self.offset = meta.getInt("offset")
        self.totalCount = meta.getInt("total_count", defaultValue: -1)
        self.next = meta.getString("next")
        self.previous = meta.getString("previous")
        self.listInfo = dict
    }
    
    override open var description: String {
        let dict = self.listInfo
        return dict.toJsonString
    }
    
    override open var debugDescription: String {
        let dict = self.listInfo
        return dict.toJsonString
    }
    
    func mapList<T>(dict: [String: Any]) -> [T]? where T: Mappable {
        var list: [T]!
        if let objects = dict["objects"] as? [[String: Any]] {
            list = []
            for dict in objects {
                let item = T(dict: dict)
                if let item = item {
                    list.append(item)
                }
            }
        }
        return list
    }
}

@objc(BaaSUserList)
public class UserList: ListResult {

    @objc public internal(set) var users: [User]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.users = mapList(dict: dict)
    }
}

@objc(BaaSRecordList)
public class RecordList: ListResult {

    @objc public internal(set) var records: [Record]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.records = mapList(dict: dict)
    }
}

@objc(BaaSFileListResult)
public class FileList: ListResult {

    @objc public internal(set) var files: [File]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.files = mapList(dict: dict)
    }
}

@objc(BaaSFileCategoryListResult)
public class FileCategoryList: ListResult {

    @objc public internal(set) var fileCategorys: [FileCategory]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.fileCategorys = mapList(dict: dict)
    }
}

@objc(BaaSContentList)
public class ContentList: ListResult {

    @objc public internal(set) var contents: [Content]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.contents = mapList(dict: dict)
    }
}

@objc(BaaSContentCategoryList)
public class ContentCategoryList: ListResult {

    @objc public internal(set) var contentCategorys: [ContentCategory]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.contentCategorys = mapList(dict: dict)
    }
}

@objc(BaaSOrderList)
public class OrderList: ListResult {

    @objc public internal(set) var orders: [Order]?
    
    public override init() {
        super.init()
    }

    public required init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.orders = mapList(dict: dict)
    }
}
