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

open class Table: BaseQuery {
    var tableId: Int?
    var tableName: String?
    fileprivate var identify: String

    public init(tableId: Int) {
        self.identify = String(tableId)
        super.init()
    }

    public init(tableName: String) {
        self.identify = tableName
        super.init()
    }

    open func createRecord() -> TableRecord {
        return TableRecord(tableIdentify: identify)
    }

    open func create(records: [[String: Any]], enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) {
        TableProvider.request(.createRecords(tableId: identify, records: records)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    open func delete(enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) {
        queryArgs["enableTrigger"] = enableTrigger ? 1 : 0
        TableProvider.request(.delete(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    open func get(recordId: String, completion:@escaping RecordResultCompletion) {
        TableProvider.request(.get(tableId: identify, recordId: recordId, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let record = ResultHandler.dictToRecord(identify: strongSelf.identify, dict: recordInfo)
                completion(record, nil)
            }
        }
    }

    open func update(record: BaseRecord, enableTrigger: Bool = true, completion:@escaping BOOLResultCompletion) {
        queryArgs["enableTrigger"] = enableTrigger ? 1 : 0
        TableProvider.request(.update(tableId: identify, urlParameters: queryArgs, bodyParameters: record.record)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    open func find(_ completion:@escaping RecordsResultCompletion) {
        TableProvider.request(.find(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let records = ResultHandler.dictToRecords(identify: strongSelf.identify, dict: recordsInfo)
                completion(records, nil)
            }
        }
    }
}
