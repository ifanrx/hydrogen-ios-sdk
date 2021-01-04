//
//  ContentCategory.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

/// 内容库分类
@objc(BaaSContentCategory)
open class ContentCategory: NSObject, Mappable {
    /// 内容库分类 Id
    @objc public internal(set) var Id: String?
    /// 内容库分类名称
    @objc public internal(set) var name: String?
    /// 内容库分类是否有子分类
    @objc public internal(set) var haveChildren: Bool = false
    /// 内容库分类的子分类
    @objc public internal(set) var children: [ContentCategory]?
    
    /// 内容库分类所有信息
    @objc public var categoryInfo: [String: Any] = [:]

    @objc required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.name = dict.getString("name")
        self.haveChildren = dict.getBool("have_children")
        let children = dict.getArray("children", type: [String: Any].self)
        var subCategorys: [ContentCategory] = []
        for subDict in children {
            if let subCategory = ContentCategory(dict: subDict) {
                subCategorys.append(subCategory)
            }
        }
        self.children = subCategorys
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
