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
    @objc public internal(set) var categoryId: String!
    @objc public internal(set) var name: String!
    @objc public internal(set) var files: Int = 0
}
