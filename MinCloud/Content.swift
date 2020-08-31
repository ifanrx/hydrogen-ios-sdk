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
    @objc public internal(set) var Id: String?
    @objc public internal(set) var title: String?
    @objc public internal(set) var desc: String?
    @objc public internal(set) var cover: String?
    @objc public internal(set) var content: String?
    @objc public internal(set) var groupId: String?
    @objc public internal(set) var categories: [String]?
    @objc public internal(set) var readCount: Int = 0
    @objc public internal(set) var contentInfo: [String: Any] = [:]

    /**
     *  创建者的 ID
     */
    @objc public internal(set) var createdById: String?

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

    @objc required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.title = dict.getString("title")
        self.cover = dict.getString("cover")
        self.desc = dict.getString("description")
        self.categories = dict.getArray("categories", type: String.self)
        self.groupId = dict.getString("group_id")
        self.content = dict.getString("content")
        if let createdBy = dict.getDict("created_by") as? [String: Any] {
            self.createdBy = createdBy
            self.createdById = dict.getDict("created_by")?.getString("id")
        } else {
            self.createdById = dict.getString("created_by")
        }
        self.createdAt = dict.getDouble("created_at")
        self.updatedAt = dict.getDouble("updated_at")
        self.contentInfo = dict
    }
    
    @objc override open var description: String {
        let dict = self.contentInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.contentInfo
        return dict.toJsonString
    }
}
