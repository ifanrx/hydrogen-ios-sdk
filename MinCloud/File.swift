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

@objc(BAASFile)
open class File: NSObject {

    @objc public var Id: String!
    @objc public var mimeType: String!
    @objc public var name: String!
    @objc public var cdnPath: String!
    @objc public var size: Int = 0
    @objc public var category: FileCategory!
    @objc public var localPath: String!
    @objc public var createdAt: TimeInterval = 0

    @objc public var fileInfo: [String: Any] {
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

    @discardableResult
    @objc open func delete(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(false, HError.init(code: 604))
            return nil
        }

        guard Id != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!"))
            return nil
        }

        let request = FileProvider.request(.deleteFile(fileId: Id!)) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
