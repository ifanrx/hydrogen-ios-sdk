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
}
