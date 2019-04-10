//
//  ContentCategory.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc open class ContentCategory: Query {
    @objc public internal(set) var categoryId: Int = -1
    @objc public internal(set) var name: String!
    @objc public internal(set) var haveChildren: Bool = false
    @objc public internal(set) var children: [ContentCategory]!
}
