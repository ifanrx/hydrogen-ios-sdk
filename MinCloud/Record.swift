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

@objc(BaaSRecord)
public class Record: BaseRecord {

    @objc public internal(set) var acl: String?

    @objc public let table: Table

    /// 记录所有的信息
    @objc public internal(set) var recordInfo: [String: Any] = [:]

    @objc init(table: Table, Id: String?) {
        self.table = table
        super.init()
        self.Id = Id
    }

    @objc convenience init(table: Table) {
        self.init(table: table, Id: nil)
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

        let request = TableRecordProvider.request(.save(tableId: table.identify, parameters: recordParameter)) { result in
            self.clear() // 清除条件
            let (recordInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                if let recordInfo = recordInfo {
                    self.Id = recordInfo.getString("id")
                    self.acl = recordInfo.getString("acl")
                    if let createdBy = recordInfo.getDict("created_by") as? [String: Any] {
                        self.createdBy = createdBy
                    } else {
                        self.createdById = recordInfo.getInt64("created_by")
                    }
                    self.createdAt = recordInfo.getDouble("created_at")
                    self.updatedAt = recordInfo.getDouble("updated_at")
                    self.recordInfo.merge(recordInfo)
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

        guard Id != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!") as NSError)
            return nil
        }

        let request = TableRecordProvider.request(.update(tableId: table.identify, recordId: Id!, parameters: recordParameter)) { result in
            self.clear() // 清除条件
            let (recordInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                if let recordInfo = recordInfo {
                    self.Id = recordInfo.getString("id")
                    self.updatedAt = recordInfo.getDouble("updated_at")
                    self.recordInfo.merge(recordInfo)
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

        guard Id != nil else {
            completion(false, HError.init(code: 400, description: "recordId invalid!") as NSError)
            return nil
        }

        let request = TableRecordProvider.request(.delete(tableId: table.identify, recordId: Id!)) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                self.Id = nil
                self.recordInfo = [:]
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
