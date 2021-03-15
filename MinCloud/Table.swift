//
//  Table.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya

/// 数据表的记录在进行 save/update/delete 操作时，可以附带的选项。
@objc(RecordOptionKey)
public class RecordOptionKey: NSObject, NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let aCopy = RecordOptionKey(key: key)
        return aCopy
    }
    
    let key: String
    private init(key: String) {
        self.key = key
        super.init()
    }
    
    /// 是否允许触发器触发
    /// 该参数对应值为 Bool 类型，默认 true。
    @objc public static let enableTrigger = RecordOptionKey(key: "enable_trigger")
}

/// 数据表
/// 对应知晓云的数据表
/// 通过 Table 对象操作知晓云对应 Id 的数据表。
@objc(BaaSTable)
open class Table: NSObject {
    public internal(set) var Id: String?
    public internal(set) var name: String?
    var identifier: String
    
    static var TableProvider = MoyaProvider<TableAPI>(plugins: logPlugin)
    // 处理外部回调
    @objc public var callBackQueue: DispatchQueue = .main
    
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
    /// - Returns: 一条空记录
    @objc public func createRecord() -> Record {
        return Record(table: self)
    }

    /// 通过记录 Id 来创建一条记录，如果 recordId 为空字符串，则返回 nil。
    ///
    /// - Parameter recordId: 记录 Id
    /// - Returns: 记录
    @objc public func getWithoutData(recordId: String) -> Record? {
        guard !recordId.isEmpty else { return nil }
        return Record(table: self, Id: recordId)
    }

    /// 批量新建记录
    ///
    /// - Parameters:
    ///   - records: 记录值
    ///   - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func createMany(_ records: [[String: Any]], options: [RecordOptionKey: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {

        let newRecords = records.map { $0.jsonValue() }
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: newRecords, options: .prettyPrinted)
        } catch let error {
            callBackQueue.async {
                completion(nil, HError.init(code: 400, description: error.localizedDescription) as NSError)
            }
            return nil
        }

        var args = [String: Any]()
        for option in options ?? [:] {
            args[option.key.key] = option.value
        }
        let request = Table.TableProvider.request(.createRecords(tableId: identifier, recordData: jsonData!, parameters: args), callbackQueue: callBackQueue) { result in
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
    ///   - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func delete(query: Query? = nil, options: [RecordOptionKey: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        for option in options ?? [:] {
            queryArgs[option.key.key] = option.value
        }
        let request = Table.TableProvider.request(.delete(tableId: identifier, parameters: queryArgs), callbackQueue: callBackQueue) { result in
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
        let request = Table.TableProvider.request(.get(tableId: identifier, recordId: recordId, parameters: parameters), callbackQueue: callBackQueue) { result in
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
    ///   - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func update(record: Record, query: Query? = nil, options: [RecordOptionKey: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        for option in options ?? [:] {
            queryArgs[option.key.key] = option.value
        }
        let request = Table.TableProvider.request(.update(tableId: identifier, urlParameters: queryArgs, bodyParameters: record.recordParameter.jsonValue()), callbackQueue: callBackQueue) { result in
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
        let request = Table.TableProvider.request(.find(tableId: identifier, parameters: queryArgs), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (listResult: RecordList?, error: NSError?) in
                listResult?.records?.forEach({ (record) in
                    record.table = self
                })
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
    
    
    /// 订阅事件
    ///
    /// - Parameters:
    ///   - event: 事件类型
    ///   - where: 订阅条件，满足条件的事件将被订阅。默认为 nil，表示该事件所有情况都会触发
    ///   - onInit: 事件订阅成功回调函数
    ///   - onError: 事件订阅失败回调函数
    ///   - onEvent: 事件触发回调函数
    @objc public func subscribe(_ event: SubscriptionEvent,
                          where: Where? = nil,
                          onInit: @escaping SubscribeCallback,
                          onError: @escaping ErrorSubscribeCallback,
                          onEvent: @escaping EventCallback) {
        
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            callBackQueue.async {
                onError(error as NSError)
            }
            return
        }

        let topic = Config.Wamp.topic(for: identifier, event: event)
        let _where = (`where` == nil) ? nil : Where.and([`where`!])
        let whereArgs = ["where": _where?.conditon ?? [:]]
        WampSessionManager.shared.subscribe(topic, options: whereArgs, onInit: onInit, onError: onError, onEvent: onEvent)
    }
}
