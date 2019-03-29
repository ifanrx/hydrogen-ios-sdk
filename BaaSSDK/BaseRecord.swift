//
//  BaseRecord.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

public class BaseRecord: NSObject, RecordClearer {

    var recordId: String?

    var record: [String: Any] = [:]

    public init(recordId: String?) {
        self.recordId = recordId
        super.init()
    }

    public func set(key: String, value: Any) {
        record["$set"] = [key: value]
    }

    public func cancelSet() {

    }

    public func set(record: [String: Any]) {
        self.record["$set"] = record
    }

    public func unset(key: String) {
        record["$unset"] = [key: ""]
    }

    public func unset(keys: [String]) {
        var keyDict: [String: Any] = [:]
        for key in keys {
            keyDict[key] = ""
        }
        record["$unset"] = keyDict
    }

    public func incrementBy(key: String, value: NSNumber) {
        record[key] = ["$incr_by": value]
    }

    public func append(key: String, value: [Any]) {
        record[key] = ["$append": value]
    }

    public func uAppend(key: String, value: [Any]) {
        record[key] = ["$append_unique": value]
    }

    public func remove(key: String, value: [Any]) {
        record[key] = ["$remove": value]
    }

    public func updateObject(key: String, value: [String: Any]) {
        record[key] = ["$update": value]
    }

    func clear() {
        record = [:]
    }

}
