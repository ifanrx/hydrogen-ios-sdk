//
//  BaseRecord.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

/// 数据表中记录
@objc(BaaSBaseRecord)
open class BaseRecord: NSObject, Mappable {

    /**
     *  记录 Id
     */
    @objc public internal(set) var Id: String?

    required public init?(dict: [String: Any]) {
        self.Id = dict.getString("id", "_id")
    }

    public override init() {
        super.init()
    }

    /**
     *  记录需要更新的值
     */
    @objc var recordParameter: [String: Any] = [:]
    
    /// 给记录的某个字段设置值，保存在本地，调用 save() 才会保存到服务器。
    /// - Parameters:
    ///   - key: 数据表的字段名
    ///   - value: 该字段设置的新值。
    @objc public func set(_ key: String, value: Any) {
        recordParameter[key] = value
    }

    /// 一次性给记录赋值
    ///
    /// - Parameter record: 记录值
    
    
    /// 给一个记录的多个字段设置值
    /// - Parameter record: 记录值
    @objc public func set(_ record: [String: Any]) {
        recordParameter.merge(record)
    }

    /// 在服务器上将该 key 对应的值置空
    ///
    /// - Parameter key: 需要置为空的字段名
    @objc public func unset(_ key: String) {
        recordParameter["$unset"] = [key: ""]
    }

    /// 在服务器上将该 keys 对应的值置空
    ///
    /// - Parameter keys: 需要置为空的字段名列表
    @objc public func unset(keys: [String]) {
        var keyDict: [String: Any] = [:]
        for key in keys {
            keyDict[key] = ""
        }
        recordParameter["$unset"] = keyDict
    }

    /// 计数器原子性更新
    ///
    /// - Parameters:
    ///   - key: 字段名称，对应的数据表字段为 integer 或 number 类型
    ///   - value: 变化的值，原来值的基础上 +/- value
    @objc public func incrementBy(_ key: String, value: NSNumber) {
        recordParameter[key] = ["$incr_by": value]
    }

    /// 将 待插入的数组 加到原数组末尾
    ///
    /// - Parameters:
    ///   - key: 字段名，对应的数据表字段为 array 类型
    ///   - value: 需要插入的数据
    @objc public func append(_ key: String, value: [Any]) {
        recordParameter[key] = ["$append": value]
    }

    /// 将 待插入的数组 中不包含在原数组的数据加到原数组末尾
    ///
    /// - Parameters:
    ///   - key: 字段名
    ///   - value: 需要插入的数据
    @objc public func uAppend(_ key: String, value: [Any]) {
        recordParameter[key] = ["$append_unique": value]
    }

    /// 从原数组中删除指定的值
    ///
    /// - Parameters:
    ///   - key: 字段名，对应的数据表字段为 array 类型
    ///   - value: 需要删除的数据
    @objc public func remove(_ key: String, value: [Any]) {
        recordParameter[key] = ["$remove": value]
    }

    /// 更新 object 类型内的属性
    ///
    /// - Parameters:
    ///   - key: 字段名，对应的数据表字段为 object 类型
    ///   - value: 更新对象
    @objc public func updateObject(_ key: String, value: [String: Any]) {
        recordParameter[key] = ["$update": value]
    }
    
    /// 从 Array 类型删除最后一项
    ///
    /// - Parameters:
    ///   - key: 字段名，对应的数据表字段为 array 类型
    @objc public func pop(_ key: String) {
        recordParameter[key] = ["$pop": 1]
    }
    
    /// 从 Array 类型删除第一项
    ///
    /// - Parameters:
    ///   - key: 字段名， 对应的数据表字段为 array 类型
    @objc public func shift(_ key: String) {
        recordParameter[key] = ["$pop": -1]
    }

    func clear() {
        recordParameter.removeAll()
    }
}
