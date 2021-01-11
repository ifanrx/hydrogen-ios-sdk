//
//  ListResult.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/10.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

/// 记录列表元数据，当调用 Table/FileManager/ContentGroup/Pay 对象的 find()，将返回该对象。
@objc(BaaSListResult)
public class ListResult: NSObject, Mappable {

    /// 当前请求指定的返回的记录个数
    @objc public internal(set) var limit: Int = 20

    /// 指定该请求返回的记录的起始位置
    @objc public internal(set) var offset: Int = 0

    /// 满足请求条件的记录的数量，-1 表示该属性无效。
    @objc public internal(set) var totalCount: Int = -1 // 默认该属性无效

    /// 下一页地址，nil 表示当前为 最后一页
    @objc public internal(set) var next: String?

    /// 上一页地址，nil 表示当前为 第一页
    @objc public internal(set) var previous: String?
    
    /// 满足请求条件的所有记录信息
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

/// 用户列表，继承自 ListResult
@objc(BaaSUserList)
public class UserList: ListResult {

    /// 所有用户
    @objc public internal(set) var users: [User]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.users = mapList(dict: dict)
    }
}

/// 记录列表，继承自 ListResult
@objc(BaaSRecordList)
public class RecordList: ListResult {

    /// 所有记录
    @objc public internal(set) var records: [Record]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.records = mapList(dict: dict)
    }
}

/// 文件列表，继承自 ListResult
@objc(BaaSFileListResult)
public class FileList: ListResult {

    /// 所有文件
    @objc public internal(set) var files: [File]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.files = mapList(dict: dict)
    }
}

/// 文件分类列表，继承自 ListResult
@objc(BaaSFileCategoryListResult)
public class FileCategoryList: ListResult {

    /// 所有文件分类
    @objc public internal(set) var fileCategorys: [FileCategory]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.fileCategorys = mapList(dict: dict)
    }
}

/// 内容列表，继承自 ListResult
@objc(BaaSContentList)
public class ContentList: ListResult {

    /// 所有内容
    @objc public internal(set) var contents: [Content]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.contents = mapList(dict: dict)
    }
}

/// 内容分类列表，继承自 ListResult
@objc(BaaSContentCategoryList)
public class ContentCategoryList: ListResult {

    /// 所有内容分类
    @objc public internal(set) var contentCategorys: [ContentCategory]?

    required public init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.contentCategorys = mapList(dict: dict)
    }
}

/// 订单列表，继承自 ListResult
@objc(BaaSOrderList)
public class OrderList: ListResult {

    /// 所有订单
    @objc public internal(set) var orders: [Order]?
    
    public override init() {
        super.init()
    }

    public required init?(dict: [String: Any]) {
        super.init(dict: dict)
        self.orders = mapList(dict: dict)
    }
}
