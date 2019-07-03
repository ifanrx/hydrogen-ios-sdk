//
//  ListResult.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/10.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

@objc(BaaSListResult)
public class ListResult: NSObject {

    @objc public internal(set) var limit: Int = 20

    @objc public internal(set) var offset: Int = 0

    @objc public internal(set) var totalCount: Int = 0

    @objc public internal(set) var next: String?  // 下一页

    @objc public internal(set) var previous: String? // 上一页

    public override init() {
        super.init()
    }

    public init?(dict: [String: Any]?) {
        guard let dict = dict, let meta = dict["meta"] as? [String: Any] else { return nil }
        self.limit = meta.getInt("limit")
        self.offset = meta.getInt("offset")
        self.totalCount = meta.getInt("total_count")
        self.next = meta.getString("next")
        self.previous = meta.getString("previous")
    }

}

@objc(BaaSUserListResult)
public class UserListResult: ListResult {

    @objc public internal(set) var users: [User]?
}

@objc(BaaSRecordListResult)
public class RecordListResult: ListResult {

    @objc public internal(set) var records: [Record]?
}

@objc(BaaSFileListResult)
public class FileListResult: ListResult {

    @objc public internal(set) var files: [File]?
}

@objc(BaaSFileCategoryListResult)
public class FileCategoryListResult: ListResult {

    @objc public internal(set) var fileCategorys: [FileCategory]?
}

@objc(BaaSContentListResult)
public class ContentListResult: ListResult {

    @objc public internal(set) var contents: [Content]?
}

@objc(BaaSContentCategoryListResult)
public class ContentCategoryListResult: ListResult {

    @objc public internal(set) var contentCategorys: [ContentCategory]?
}

@objc(BaaSOrderList)
public class OrderList: ListResult {

    @objc public internal(set) var orders: [Order]?
    var dictInfo: [String: Any]?

    public override init() {
        super.init()
    }

    public override init?(dict: [String: Any]?) {
        guard let dictInfo = dict, let objects = dictInfo["objects"] as? [[String: Any]] else { return nil }
        self.dictInfo = dictInfo
        var orderInfos: [Order] = []
        for orderDict in objects {
            if let orderInfo = Order(dict: orderDict) {
                orderInfos.append(orderInfo)
            }
        }
        self.orders = orderInfos
        super.init(dict: dict)
    }

    override open var description: String {
        let dict = self.dictInfo ?? [:]
        return dict.toJsonString
    }
}
