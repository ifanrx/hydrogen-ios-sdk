//
//  File.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

/// 知晓云上的文件
@objc(BaaSFile)
open class File: NSObject, Mappable {

    /// 文件 Id
    @objc public internal(set) var Id: String?
    /// 文件类型
    @objc public internal(set) var mimeType: String?
    /// 文件名称
    @objc public internal(set) var name: String?
    /// 文件在 cdn 的访问路径
    @objc public internal(set) var path: String? // cdn 全路径
    /// 文件在 cdn 的相对路径
    @objc public internal(set) var cdnPath: String? // cdn 相对路径
    /// 文件大小
    @objc public internal(set) var size: Int = 0
    /// 文件分类
    @objc public internal(set) var category: FileCategory?
    /// 文件的本地路径
    @objc public internal(set) var localPath: String?
    /// 文件创建时间
    @objc public internal(set) var createdAt: TimeInterval = 0
    
    /// 回调函数执行队列
    @objc public var callBackQueue: DispatchQueue = .main

    @objc required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.name = dict.getString("name")
        self.mimeType = dict.getString("mime_type")
        self.size = dict.getInt("size")
        self.path = dict.getString("path")
        self.cdnPath = dict.getString("cdn_path")
        self.createdAt = dict.getDouble("created_at")
        if let categoryDict = dict.getDict("category") as? [String: Any] {
            let category = FileCategory(dict: categoryDict)
            self.category = category
        }
    }

    @objc public override init() {
        super.init()
    }
    
    /// 文件元数据
    @objc public var metaInfo: [String: Any] {
        var info: [String: Any] = [:]
        if let fileId = Id {
            info["id"] = fileId
        }

        if let name = name {
            info["name"] = name
        }

        if let mimeType = mimeType {
            info["mime_type"] = mimeType
        }
        
        if let cdnPath = cdnPath {
            info["cdn_path"] = cdnPath
        }
        
        if let path = path {
            info["path"] = path
        }
        
        if let category = category {
            info["category"] = category.categoryInfo
        }
        
        info["size"] = size
        info["created_at"] = createdAt
        return info
    }
    
    /// 根据 key 获取值
    @objc public func get(_ key: String) -> Any? {
        return metaInfo[key]
    }

    /**
     *  文件信息（内部）
     *  在给类型为 file 类型的列赋值时，必须以下面方式组织文件信息
     */
    var fileInfo: [String: Any] {
        var info: [String: Any] = [:]
        if let fileId = Id {
            info["id"] = fileId
        }

        if let name = name {
            info["name"] = name
        }

        if let mimeType = mimeType {
            info["mime_type"] = mimeType
        }

        // 此处 cdn_path 为文件的访问全路径，
        // 用于更新数据表的 file 字段，
        // 注意与 cdnPath 属性的区别。
        if let cdnPath = path {
            info["cdn_path"] = cdnPath
        }
        info["size"] = size
        info["created_at"] = createdAt
        return info
    }

    @objc override open var description: String {
        let dict = self.metaInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.metaInfo
        return dict.toJsonString
    }

    /// 删除本文件
    ///
    /// 删除文件后，本地文件信息不清空，建议开发者自行清空。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc public func delete(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard Id != nil else {
            callBackQueue.async {
                completion(false, HError.init(code: 400, description: "fileId invalid!") as NSError)
            }
            return nil
        }

        let request = FileManager.FileProvider.request(.deleteFile(fileId: Id!), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
