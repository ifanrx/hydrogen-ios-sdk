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

    // 订单状态: 成功 success，待支付 pending
    @objc public func status(_ value: OrderStatus) {
        var statusArg: String
        switch value {
        case .pending:
            statusArg = "pending"
        default:
            statusArg = "success"
        }
        queryArgs["status"] = statusArg
    }

    // 退款状态: 完成 complete，部分退款 partial
    @objc public func refundStatus(_ value: RefundStatus) {
        var statusArg: String
        switch value {
        case .partial:
            statusArg = "partial"
        default:
            statusArg = "complete"
        }
        queryArgs["refund_status"] = statusArg
    }

    @objc public func gateWayType(_ value: GateWayType) {
        var type: String
        switch value {
        case .weixin:
            type = "weixin_tenpay_app"
        case .alipay:
            type = "alipay_app"
        }
        queryArgs["gateway_type"] = type
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
