//
//  Content.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/27.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BaaSContent)
open class Content: NSObject, Mappable {
    @objc public internal(set) var Id: Int64 = -1
    @objc public internal(set) var title: String?
    @objc public internal(set) var desc: String?
    @objc public internal(set) var cover: String?
    @objc public internal(set) var content: String?
    @objc public internal(set) var groupId: Int64 = -1
    @objc public internal(set) var categories: [Int]?
    @objc public internal(set) var readCount: Int = 0

    /**
     *  创建者的 ID
     */
    @objc public internal(set) var createdById: Int64 = -1

    /**
     *  创建者的信息
     */
    @objc public internal(set) var createdBy: [String: Any]?

    /**
     *  创建时间
     */
    @objc public internal(set) var createdAt: TimeInterval = 0

    /**
     *  更新时间
     */
    @objc public internal(set) var updatedAt: TimeInterval = 0

    required public init?(dict: [String: Any]) {
        self.Id = dict.getInt64("id")
        self.title = dict.getString("title")
        self.cover = dict.getString("cover")
        self.desc = dict.getString("description")
        self.categories = dict.getArray("categories", type: Int.self)
        self.groupId = dict.getInt64("group_id")
        self.content = dict.getString("content")
        if let createdBy = dict.getDict("created_by") as? [String: Any] {
            self.createdBy = createdBy
            self.createdById = dict.getDict("created_by")?.getInt64("id") ?? -1
        } else {
            self.createdById = dict.getInt64("created_by")
        }
        self.createdAt = dict.getDouble("created_at")
        self.updatedAt = dict.getDouble("created_at")
    }
}
