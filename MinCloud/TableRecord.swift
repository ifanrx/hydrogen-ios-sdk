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

    /// 记录所有的信息
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

    /// 将新增的记录上传到服务器
    ///
    /// 记录新增成功后，新的记录值将同时被更新到本地的记录，可通过 recordInfo 查询。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
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

    /// 更新记录
    ///
    /// 记录更新成功后，新的记录值将同时被更新到本地的记录，可通过 recordInfo 查询。。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
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

    /// 删除本记录
    ///
    /// 记录删除成功后，本地的记录也同时被清空。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
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
