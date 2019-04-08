//
//  FileCategory.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/25.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BAASFileCategory)
open class FileCategory: NSObject {
    @objc public var categoryId: String!
    @objc public var name: String!
    @objc public var files: Int = 0
}
