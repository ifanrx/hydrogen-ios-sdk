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

@objc(BAASTableRecord)
public class TableRecord: BaseRecord {
    @objc public var tableIdentify: String
    @objc public var recordInfo: [String: Any] = [:]

    @objc public init(tableIdentify: String, recordId: String?) {
        self.tableIdentify = tableIdentify
        super.init(recordId: recordId)
    }

    @objc public convenience init(tableIdentify: String) {
        self.init(tableIdentify: tableIdentify, recordId: nil)
    }

    @objc public func get(key: String) -> Any? {
        return recordInfo[key]
    }

    @discardableResult
    @objc public func save(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(false, HError.init(code: 604))
            return nil
        }

        let request = TableRecordProvider.request(.save(tableId: tableIdentify, parameters: record)) { [weak self] result in
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

        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public func update(_ completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(false, HError.init(code: 604))
            return nil
        }

        guard recordId != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!"))
            return nil
        }

        let request = TableRecordProvider.request(.update(tableId: tableIdentify, recordId: recordId!, parameters: record)) { [weak self] result in
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
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public func delete(completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(false, HError.init(code: 604))
            return nil
        }

        guard recordId != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!"))
            return nil
        }

        let request = TableRecordProvider.request(.delete(tableId: tableIdentify, recordId: recordId!)) { [weak self] result in
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
        return RequestCanceller(cancellable: request)
    }
}
