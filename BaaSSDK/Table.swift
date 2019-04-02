//
//  Table.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya
import Result

@objc(BAASTable)
public class Table: BaseQuery {
    public var tableId: Int?
    public var tableName: String?
    fileprivate var identify: String

    @objc public init(tableId: Int) {
        self.identify = String(tableId)
        super.init()
    }

    @objc public init(tableName: String) {
        self.identify = tableName
        super.init()
    }

    @objc public func createRecord() -> TableRecord {
        return TableRecord(tableIdentify: identify)
    }

    @objc public func getWithoutData(recordId: String) -> TableRecord {
        return TableRecord(tableIdentify: identify, recordId: recordId)
    }

    @objc public func create(records: [[String: Any]], enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

        let request = TableProvider.request(.createRecords(tableId: identify, records: records)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @objc public func delete(enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

        queryArgs["enableTrigger"] = enableTrigger ? 1 : 0
        let request = TableProvider.request(.delete(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @objc public func get(recordId: String, completion:@escaping RecordResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = TableProvider.request(.get(tableId: identify, recordId: recordId, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let record = ResultHandler.dictToRecord(identify: strongSelf.identify, dict: recordInfo)
                completion(record, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @objc public func update(record: BaseRecord, enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

        queryArgs["enableTrigger"] = enableTrigger ? 1 : 0
        let request = TableProvider.request(.update(tableId: identify, urlParameters: queryArgs, bodyParameters: record.record)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @objc public func find(_ completion:@escaping RecordsResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = TableProvider.request(.find(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let records = ResultHandler.dictToRecords(identify: strongSelf.identify, dict: recordsInfo)
                completion(records, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
