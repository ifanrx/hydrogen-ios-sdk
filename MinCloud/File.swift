//
//  File.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BaaSFile)
open class File: NSObject, Mappable {

    @objc public internal(set) var Id: String!
    @objc public internal(set) var mimeType: String!
    @objc public internal(set) var name: String!
    @objc public internal(set) var cdnPath: String!
    @objc public internal(set) var size: Int = 0
    @objc public internal(set) var category: FileCategory!
    @objc public internal(set) var localPath: String!
    @objc public internal(set) var createdAt: TimeInterval = 0

    required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id")
        self.name = dict.getString("name")
        self.mimeType = dict.getString("mime_type")
        self.size = dict.getInt("size")
        self.cdnPath = dict.getString("path")
        self.createdAt = dict.getDouble("created_at")
        let category = FileCategory(dict: dict)
        self.category = category
    }

    public override init() {
        super.init()
    }

    /**
     *  文件信息
     *  在给类型为 file 类型的列赋值时，必须以下面方式组织文件信息
     */
    @objc public  var fileInfo: [String: Any] {
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
        info["size"] = size
        info["created_at"] = createdAt
        return info
    }

    override open var description: String {
        let dict = self.fileInfo
        return dict.toJsonString
    }

    /// 删除本文件
    ///
    /// 删除文件后，本地文件信息不清空，建议开发者自行清空。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func delete(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard Id != nil else {
            completion(false, HError.init(code: 400, description: "fileId invalid!") as NSError)
            return nil
        }

        let request = FileProvider.request(.deleteFile(fileId: Id!)) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    Storage.shared.reset()
                    printDebugInfo("logout success!")
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
