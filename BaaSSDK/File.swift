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

public class File: NSObject {

    public var fileId: String!
    public var mimeType: String!
    public var name: String!
    public var cdnPath: String!
    public var size: Int!
    public var category: FileCategory!
    public var localPath: String!
    public var createdAt: TimeInterval!

    public var fileInfo: [String: Any] {
        return ["id": fileId, "name": name, "created_at": createdAt, "mime_type": mimeType, "cdn_path": cdnPath, "size": size]
    }

    public func delete(_ completion:@escaping BOOLResultCompletion) {
        guard fileId != nil else {
            completion(false, HError.init(code: 400, errorDescription: "recordId invalid!"))
            return
        }

        FileProvider.request(.deleteFile(fileId: fileId!)) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}
