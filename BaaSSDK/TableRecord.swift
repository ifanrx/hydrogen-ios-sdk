//
//  TableRecord.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya
import Result

public class TableRecord: BaseRecord {
    var tableIdentify: String
    public var recordInfo: [String: Any] = [:]

    public init(tableIdentify: String, recordId: String?) {
        self.tableIdentify = tableIdentify
        super.init(recordId: recordId)
    }

    public convenience init(tableIdentify: String) {
        self.init(tableIdentify: tableIdentify, recordId: nil)
    }

    public func get(key: String) -> Any? {
        return recordInfo[key]
    }

    public func save(_ completion:@escaping BOOLResultCompletion) {
        TableRecordProvider.request(.save(tableId: tableIdentify, parameters: record)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                if let recordInfo = recordInfo {
                    strongSelf.recordId = recordInfo.getString("id")
                    strongSelf.recordInfo.merge(recordInfo)
                }
                completion(true, nil)
            }
        }
    }

    public func update(_ completion:@escaping BOOLResultCompletion) {
        guard recordId != nil else {
            completion(false, HError.init(code: 400, errorDescription: "recordId invalid!"))
            return
        }

        TableRecordProvider.request(.update(tableId: tableIdentify, recordId: recordId!, parameters: record)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                if let recordInfo = recordInfo {
                    strongSelf.recordId = recordInfo.getString("id")
                    strongSelf.recordInfo.merge(recordInfo)
                }
                completion(true, nil)
            }
        }
    }

    public func delete(completion:@escaping BOOLResultCompletion) {
        guard recordId != nil else {
            completion(false, HError.init(code: 400, errorDescription: "recordId invalid!"))
            return
        }

        TableRecordProvider.request(.delete(tableId: tableIdentify, recordId: recordId!)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                strongSelf.recordId = nil
                strongSelf.recordInfo = [:]
                completion(true, nil)
            }
        }
    }
}
