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
    public internal(set) var Id: String?
    public internal(set) var name: String?
    var identifier: String

    static var TableProvider = MoyaProvider<TableAPI>(plugins: logPlugin)
    
    @objc public init(tableId: String) {
        self.identifier = tableId
        super.init()
    }

    @objc public init(name: String) {
        self.identifier = name
        super.init()
    }

    /// 创建一条空记录
    ///
    /// - Returns:
    @objc public func createRecord() -> Record {
        return Record(table: self)
    }

    /// 示例化一条记录
    ///
    /// - Parameter recordId: 记录 Id
    /// - Returns:
    @objc public func getWithoutData(recordId: String) -> Record {
        return Record(table: self, Id: recordId)
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

        let newRecords = records.map { $0.jsonValue() }
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: newRecords, options: .prettyPrinted)
        } catch let error {
            completion(nil, HError.init(code: 400, description: error.localizedDescription) as NSError)
            return nil
        }

        let args = options ?? [:]
        let request = Table.TableProvider.request(.createRecords(tableId: identifier, recordData: jsonData!, parameters: args)) { result in
            ResultHandler.parse(result, handler: { (resultInfo: MappableDictionary?, error: NSError?) in
                completion(resultInfo?.value, error)
            })
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

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs.merge(options ?? [:])
        let request = Table.TableProvider.request(.delete(tableId: identifier, parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (resultInfo: MappableDictionary?, error: NSError?) in
                completion(resultInfo?.value, error)
            })
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

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = Table.TableProvider.request(.get(tableId: identifier, recordId: recordId, parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (record: Record?, error: NSError?) in
                record?.table = self
                completion(record, error)
            })
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
    ///   - options: 选项,目前支持 enable_trigger: 是否触发触发器, 可选。
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func update(record: Record, query: Query? = nil, options: [String: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs.merge(options ?? [:])
        let request = Table.TableProvider.request(.update(tableId: identifier, urlParameters: queryArgs, bodyParameters: record.recordParameter.jsonValue())) { result in
            ResultHandler.parse(result, handler: { (resultInfo: MappableDictionary?, error: NSError?) in
                completion(resultInfo?.value, error)
            })
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
    @objc public func find(query: Query? = nil, completion: @escaping RecordListResultCompletion) -> RequestCanceller? {

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = Table.TableProvider.request(.find(tableId: identifier, parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: RecordList?, error: NSError?) in
                listResult?.records?.forEach({ (record) in
                    record.table = self
                })
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
