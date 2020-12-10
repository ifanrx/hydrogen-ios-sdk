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
    
    // 所有内容库信息
    @objc public internal(set) var contentInfo: [String: Any] = [:]


    @objc required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.title = dict.getString("title")
        self.cover = dict.getString("cover")
        self.desc = dict.getString("description")
        self.categories = dict.getArray("categories", type: String.self)
        self.groupId = dict.getString("group_id")
        self.content = dict.getString("content")
        self.readCount = dict.getInt("read_count")
        self.contentInfo = dict
    }
    
    /**
     *  根据 key 获取值
     */
    @objc public func get(_ key: String) -> Any? {
        return contentInfo[key]
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
