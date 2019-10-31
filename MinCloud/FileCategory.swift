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

@objc(BaaSFileCategory)
open class FileCategory: NSObject, Mappable {
    @objc public internal(set) var Id: String?
    @objc public internal(set) var name: String?
    @objc public internal(set) var files: Int = 0
    @objc public internal(set) var updatedAt: TimeInterval = 0
    @objc public internal(set) var createdAt: TimeInterval = 0
    
    var categoryInfo: [String: Any] = [:]

    @objc required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.name = dict.getString("name")
        self.files = dict.getInt("files")
        self.createdAt = dict.getDouble("created_at")
        self.updatedAt = dict.getDouble("updated_at")
        self.categoryInfo = dict
    }
    
    @objc override open var description: String {
        let dict = self.categoryInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.categoryInfo
        return dict.toJsonString
    }
}
