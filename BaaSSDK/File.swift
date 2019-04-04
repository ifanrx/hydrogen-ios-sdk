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

    public var fileId: String!
    public var mimeType: String!
    public var name: String!
    public var cdnPath: String!
    public var size: Int!
    public var category: FileCategory!
    public var localPath: String!
    public var createdAt: TimeInterval!

    @objc public var fileInfo: [String: Any] {
        return ["id": fileId, "name": name, "created_at": createdAt, "mime_type": mimeType, "cdn_path": cdnPath, "size": size]
    }

    @discardableResult
    @objc open func delete(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

        guard fileId != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!"))
            return nil
        }

        let request = FileProvider.request(.deleteFile(fileId: fileId!)) { result in
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
