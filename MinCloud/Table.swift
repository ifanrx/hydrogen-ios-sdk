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

@objc(BaaSTable)
public class Table: NSObject {
    public internal(set) var Id: Int64?
    public internal(set) var name: String?
    var identify: String

    @objc public init(tableId: Int64) {
        self.identify = String(tableId)
        super.init()
    }

    @objc public init(name: String) {
        self.identify = name
        super.init()
    }

    /// 创建一条空记录
    ///
    /// - Returns:
    @objc public func createRecord() -> TableRecord {
        return TableRecord(table: self)
    }

    /// 示例化一条记录
    ///
    /// - Parameter recordId: 记录 Id
    /// - Returns:
    @objc public func getWithoutData(recordId: String) -> TableRecord {
        return TableRecord(table: self, Id: recordId)
    }

    /// 批量新建记录
    ///
    /// - Parameters:
    ///   - records: 记录值
    ///   - options: 选项,目前支持 enable_trigger: 是否触发触发器。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func createMany(_ records: [[String: Any]], options: [String: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: records, options: .prettyPrinted)
        } catch let error {
            completion(nil, HError.init(code: 400, description: error.localizedDescription))
            return nil
        }

        let args = options ?? [:]
        let request = TableProvider.request(.createRecords(tableId: identify, recordData: jsonData!, parameters: args)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 批量删除记录
    ///
    /// - Parameters:
    ///   - query: 查询条件，将会删除满足条件的记录。如果不设置条件，将删除该表的所有记录。可选
    ///   - options: 选项,目前支持 enable_trigger: 是否触发触发器, 可选。
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func delete(query: Query? = nil, options: [String: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs.merge(options ?? [:])
        let request = TableProvider.request(.delete(tableId: identify, parameters: queryArgs)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取记录详情
    ///
    /// - Parameters:
    ///   - recordId: 记录 Id
    ///   - select: 筛选条件，只返回指定的字段。可选
    ///   - expand: 扩展条件。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func get(_ recordId: String, select: [String]? = nil, expand: [String]? = nil, completion:@escaping RecordResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = TableProvider.request(.get(tableId: identify, recordId: recordId, parameters: parameters)) { [weak self]  result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let record = ResultHandler.dictToRecord(table: strongSelf, dict: recordInfo)
                completion(record, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 批量更新记录
    ///
    /// 先使用 setQuery 方法设置条件，满足条件的记录将会被更新。
    /// 如果不设置条件，将更新该表的所有记录。
    ///
    /// - Parameters:
    ///   - record: 需要更新的记录值
    ///   - query: 查询条件，满足条件的记录将被更新
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func update(record: BaseRecord, query: Query? = nil, enableTrigger: Bool = true, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = TableProvider.request(.update(tableId: identify, urlParameters: queryArgs, bodyParameters: record.record)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询记录
    ///
    /// - Parameter:
    ///   - query: 查询条件，满足条件的记录将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func find(query: Query? = nil, completion:@escaping RecordListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = TableProvider.request(.find(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordsInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let records = ResultHandler.dictToRecordListResult(table: strongSelf, dict: recordsInfo)
                completion(records, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
