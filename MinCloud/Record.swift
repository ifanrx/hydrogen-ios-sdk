//
//  TableRecord.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya

/// 数据表记录
/// 对应知晓云数据表的一条记录
/// 通过 Record 对象，可以操作知晓云对应 Id 的记录。
@objc(BaaSRecord)
public class Record: BaseRecord {

    @objc public var table: Table?
    
    static var TableRecordProvider = MoyaProvider<TableRecordAPI>(plugins: logPlugin)

    /// 记录所有的信息
    @objc public internal(set) var recordInfo: [String: Any] = [:]

    @objc public init(table: Table, Id: String?) {
        self.table = table
        super.init()
        self.Id = Id
    }

    @objc public convenience init(table: Table) {
        self.init(table: table, Id: nil)
    }

    required init?(dict: [String: Any]) {
        self.recordInfo = dict
        super.init(dict: dict)
    }

    @objc convenience public init?(table: Table, dict: [String: Any]) {
        self.init(dict: dict)
        self.table = table
    }

    @objc override open var description: String {
        let dict = self.recordInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.recordInfo
        return dict.toJsonString
    }

    @objc public func get(_ key: String) -> Any? {
        return recordInfo[key]
    }

    /// 将新增的记录上传到服务器
    ///
    /// 记录新增成功后，新的记录值将同时被更新到本地的记录，可通过 recordInfo 查询。
    ///
    /// - query: 查询条件，目前仅支持设置扩展
    /// - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func save(expand: [String]? = nil, options: [RecordOptionKey: Any]? = nil, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        
        guard let tableId = table?.identifier else {
            completion(false, HError.init(code: 400, description: "recordId invalid!") as NSError)
            return nil
        }

        var queryArgs: [String: Any] = [:]
        if let expand = expand {
            queryArgs["expand"] = expand.joined(separator: ",")
        }
        for option in options ?? [:] {
            queryArgs[option.key.key] = option.value
        }
        let callBackQueue = table?.callBackQueue ?? .main
        let request = Record.TableRecordProvider.request(.save(tableId: tableId, urlParameters: queryArgs, bodyParametes: recordParameter.jsonValue()), callbackQueue: callBackQueue) { result in
            self.clear() // 清除条件

            ResultHandler.parse(result, handler: { (record: Record?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    if let record = record {
                        self.Id = record.Id
                        self.recordInfo.merge(record.recordInfo)
                    }
                    completion(true, nil)
                }
            })
        }

        return RequestCanceller(cancellable: request)
    }

    /// 更新记录
    ///
    /// 记录更新成功后，新的记录值将同时被更新到本地的记录，可通过 recordInfo 查询。。
    ///
    /// - query: 查询条件，目前仅支持设置扩展
    /// - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func update(expand: [String]? = nil, options: [RecordOptionKey: Any]? = nil, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {

        let callBackQueue = table?.callBackQueue ?? .main
        guard Id != nil, let tableId = table?.identifier else {
            callBackQueue.async {
                completion(false, HError.init(code: 400, description: "recordId invalid!") as NSError)
            }
            return nil
        }

        var queryArgs: [String: Any] = [:]
        if let expand = expand {
            queryArgs["expand"] = expand.joined(separator: ",")
        }
        for option in options ?? [:] {
            queryArgs[option.key.key] = option.value
        }
        let request = Record.TableRecordProvider.request(.update(tableId: tableId, recordId: Id!, urlParameters: queryArgs, bodyParametes: recordParameter.jsonValue()), callbackQueue: callBackQueue) { result in
            let unsetKeys = self.recordParameter.getDict("$unset") as? [String: Any]
            self.clear() // 清除条件
            ResultHandler.parse(result, handler: { (record: Record?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    if let record = record {
                        self.Id = record.Id
                        self.recordInfo.merge(record.recordInfo)
                        if let unsetKeys = unsetKeys {
                            for key in unsetKeys.keys {
                                self.recordInfo.removeValue(forKey: key)
                            }
                        }
                        
                    }
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 删除本记录
    ///
    /// 记录删除成功后，本地的记录也同时被清空。
    ///
    /// - options: 选项,目前 RecordOptionKey 仅支持 enableTrigger，表示是否触发触发器，默认为 true。可选
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func delete(options: [RecordOptionKey: Any]? = nil, completion:@escaping BOOLResultCompletion) -> RequestCanceller? {

        let callBackQueue = table?.callBackQueue ?? .main
        guard Id != nil, let tableId = table?.identifier else {
            callBackQueue.async {
                completion(false, HError.init(code: 400, description: "recordId invalid!") as NSError)
            }
            return nil
        }

        var args = [String: Any]()
        for option in options ?? [:] {
            args[option.key.key] = option.value
        }
        let request = Record.TableRecordProvider.request(.delete(tableId: tableId, recordId: Id!, parameters: args), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    self.Id = nil
                    self.recordInfo = [:]
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
