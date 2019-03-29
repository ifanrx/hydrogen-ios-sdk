//
//  ContentCategory.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc open class ContentCategory: BaseQuery {
    @objc open var categoryId: String!
    @objc open var name: String!
    @objc open var haveChildren: Bool = false
    @objc open var children: [ContentCategory]!
}
