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
    @objc public var contentId: Int = -1
    @objc public var title: String?
    @objc public var desc: String?
    @objc public var cover: String?
    @objc public var content: String?
    @objc public var groupId: Int = -1
    @objc public var categories: [Int]?
    @objc public var readCount: Int = 0

    /**
     *  创建者的 ID
     */
    @objc public var createdById: Int = 0

    /**
     *  创建者的信息
     */
    @objc public var createdBy: [String: Any]?

    /**
     *  创建时间
     */
    @objc public var createdAt: TimeInterval = 0

    /**
     *  更新时间
     */
    @objc public var updatedAt: TimeInterval = 0}
