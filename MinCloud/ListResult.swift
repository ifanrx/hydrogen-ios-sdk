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

    @objc public internal(set) var totalCount: Int = 0

    @objc public internal(set) var next: String?  // 下一页

    @objc public internal(set) var previous: String? // 上一页

    public override init() {
        super.init()
    }

    required public init?(dict: [String: Any]) {
        guard let meta = dict["meta"] as? [String: Any] else { return nil }
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

    required public init?(dict: [String: Any]) {
        var users: [User]!
        if let objects = dict["objects"] as? [[String: Any]] {
            users = []
            for userDict in objects {
                let user = User(dict: userDict)
                if let user = user {
                    users.append(user)
                }
            }
        }
        self.users = users
        super.init(dict: dict)
    }
}

@objc(BaaSRecordListResult)
public class RecordListResult: ListResult {

    @objc public internal(set) var records: [Record]?

    required public init?(dict: [String: Any]) {
        var records: [Record]!
        if let objects = dict["objects"] as? [[String: Any]] {
            records = []
            for recordDict in objects {
                let record = Record(dict: recordDict)
                if let record = record {
                    records.append(record)
                }
            }
        }
        self.records = records
        super.init(dict: dict)
    }
}

@objc(BaaSFileListResult)
public class FileListResult: ListResult {

    @objc public internal(set) var files: [File]?

    required public init?(dict: [String: Any]) {
        var files: [File]!
        if let objects = dict["objects"] as? [[String: Any]] {
            files = []
            for fileDict in objects {
                let file = File(dict: fileDict)
                if let file = file {
                    files.append(file)
                }
            }
        }
        self.files = files
        super.init(dict: dict)
    }
}

@objc(BaaSFileCategoryListResult)
public class FileCategoryListResult: ListResult {

    @objc public internal(set) var fileCategorys: [FileCategory]?

    required public init?(dict: [String: Any]) {
        var categorys: [FileCategory]!
        if let objects = dict["objects"] as? [[String: Any]] {
            categorys = []
            for categoryDict in objects {
                let category = FileCategory(dict: categoryDict)
                if let category = category {
                    categorys.append(category)
                }
            }
        }
        self.fileCategorys = categorys
        super.init(dict: dict)
    }
}

@objc(BaaSContentListResult)
public class ContentListResult: ListResult {

    @objc public internal(set) var contents: [Content]?

    required public init?(dict: [String: Any]) {
        var contents: [Content]!
        if let objects = dict["objects"] as? [[String: Any]] {
            contents = []
            for contentDict in objects {
                let content = Content(dict: contentDict)
                if let content = content {
                    contents.append(content)
                }
            }
        }
        self.contents = contents
        super.init(dict: dict)
    }
}

@objc(BaaSContentCategoryListResult)
public class ContentCategoryListResult: ListResult {

    @objc public internal(set) var contentCategorys: [ContentCategory]?

    required public init?(dict: [String: Any]) {
        var categorys: [ContentCategory]!
        if let objects = dict["objects"] as? [[String: Any]] {
            categorys = []
            for categoryDict in objects {
                let category = ContentCategory(dict: categoryDict)
                if let category = category {
                    categorys.append(category)
                }
            }
        }
        self.contentCategorys = categorys
        super.init(dict: dict)
    }
}

@objc(BaaSOrderList)
public class OrderList: ListResult {

    @objc public internal(set) var orders: [Order]?
    var dictInfo: [String: Any]?

    public override init() {
        super.init()
    }

    public required init?(dict: [String: Any]) {
        guard let objects = dict["objects"] as? [[String: Any]] else { return nil }
        self.dictInfo = dict
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
