//
//  BaseRecord.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASRecord)
open class BaseRecord: NSObject, RecordClearer {

    @objc public internal(set) var Id: String?

    @objc public internal(set) var createdById: Int = -1

    @objc public internal(set) var createdBy: [String: Any]?

    @objc public internal(set) var createdAt: TimeInterval = 0

    @objc public internal(set) var updatedAt: TimeInterval = 0

    @objc var record: [String: Any] = [:]

    @objc public func set(key: String, value: Any) {
        record[key] = value
    }

    @objc public func set(record: [String: Any]) {
        self.record.merge(record)
    }

    @objc public func unset(key: String) {
        record["$unset"] = [key: ""]
    }

    @objc public func unset(keys: [String]) {
        var keyDict: [String: Any] = [:]
        for key in keys {
            keyDict[key] = ""
        }
        record["$unset"] = keyDict
    }

    @objc public func incrementBy(key: String, value: NSNumber) {
        record[key] = ["$incr_by": value]
    }

    @objc public func append(key: String, value: [Any]) {
        record[key] = ["$append": value]
    }

    @objc public func uAppend(key: String, value: [Any]) {
        record[key] = ["$append_unique": value]
    }

    @objc public func remove(key: String, value: [Any]) {
        record[key] = ["$remove": value]
    }

    @objc public func updateObject(key: String, value: [String: Any]) {
        record[key] = ["$update": value]
    }

    func clear() {
        record = [:]
    }
}
