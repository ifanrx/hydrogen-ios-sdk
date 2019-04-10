//
//  Content.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/27.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASContent)
open class Content: NSObject {
    @objc public internal(set) var contentId: Int = -1
    @objc public internal(set) var title: String?
    @objc public internal(set) var desc: String?
    @objc public internal(set) var cover: String?
    @objc public internal(set) var content: String?
    @objc public internal(set) var groupId: Int = -1
    @objc public internal(set) var categories: [Int]?
    @objc public internal(set) var readCount: Int = 0

    /**
     *  创建者的 ID
     */
    @objc public internal(set) var createdById: Int = 0

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
    @objc public internal(set) var updatedAt: TimeInterval = 0}
