//
//  ContentCategory.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc open class ContentCategory: BaseQuery {
    @objc public var categoryId: String!
    @objc public var name: String!
    @objc public var haveChildren: Bool = false
    @objc public var children: [ContentCategory]!
}
