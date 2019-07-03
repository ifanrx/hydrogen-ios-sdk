//
//  BaseQuery.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

protocol RecordClearer {
    func clear()
}

@objc(BaaSQuery)
open class Query: NSObject {

    lazy var queryArgs: [String: Any] = [:]

    @objc public func setWhere(_ whereArgs: Where) {
        let conditon = whereArgs.conditon as NSDictionary
        queryArgs["where"] = conditon.toJsonString
    }

    @objc public func select(_ args: [String]) {
        queryArgs["keys"] = args.joined(separator: ",")
    }

    @objc public func expand(_ args: [String]) {
        queryArgs["expand"] = args.joined(separator: ",")
    }

    @objc public func limit(_ value: Int) {
        queryArgs["limit"] = value
    }

    @objc public func offset(_ value: Int) {
        queryArgs["offset"] = value
    }

    @objc public func orderBy(_ args: [String]) {
        queryArgs["order_by"] = args.joined(separator: ",")
    }

    func clear() {
        queryArgs = [:]
    }
}

@objc(BaaSOrderQuery)
open class OrderQuery: Query {

    // 订单状态
    @objc public func status(_ value: String) {
        queryArgs["status"] = value
    }

    //
    @objc public func tradeNo(_ value: String) {
        queryArgs["trade_no"] = value
    }

    @objc public func transactionNo(_ value: String) {
        queryArgs["transaction_no"] = value
    }

    // 记录 ID
    @objc public func merchandiseRecordId(_ value: String) {
        queryArgs["merchandise_record_id"] = value
    }

    // 表 ID
    @objc public func merchandiseSchemaId(_ value: String) {
        queryArgs["merchandise_schema_id"] = value
    }
}
