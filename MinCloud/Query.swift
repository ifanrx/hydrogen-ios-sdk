//
//  BaseQuery.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

@objc(BaaSQuery)
open class Query: NSObject {
    
    @objc public var limit: Int = 20
    
    @objc public var offset: Int = 0
    
    @objc public var `where`: Where?
    
    @objc public var select: [String]?
    
    @objc public var expand: [String]?
    
    @objc public var orderBy: [String]?
    
    @objc public var returnTotalCount: Bool = false
    
    var queryArgs: [String: Any] {
        var args: [String: Any] = [:]
        args["limit"] = limit
        
        args["offset"] = offset
        
        args["return_total_count"] = returnTotalCount
        
        if let `where` = `where` {
            args["where"] = `where`.conditon.toJsonString
        }
        
        if let select = select {
            args["keys"] = select.joined(separator: ",")
        }
        
        if let expand = expand {
            args["expand"] = expand.joined(separator: ",")
        }
        
        if let orderBy = orderBy {
            args["order_by"] = orderBy.joined(separator: ",")
        }
        
        return args
        
    }
}

@objc(BaaSOrderQuery)
open class OrderQuery: Query {
    
    @objc public var status: OrderStatus = .all
    
    @objc public var refundStatus: RefundStatus = .all
    
    @objc public var gateWayType: GateWayType = .all
    
    @objc public var tradeNo: String?
    
    @objc public var transactionNo: String?
    
    @objc public var merchandiseRecordId: String?
    
    @objc public var merchandiseSchemaId: String?
    
    override var queryArgs: [String : Any] {
        var args = super.queryArgs
        
        if let tradeNo = tradeNo {
            args["trade_no"] = tradeNo
        }

        if let transactionNo = transactionNo {
            args["transaction_no"] = transactionNo
        }

        // 记录 ID
        if let merchandiseRecordId = merchandiseRecordId {
            args["merchandise_record_id"] = merchandiseRecordId
        }

        // 表 ID
        if let merchandiseSchemaId = merchandiseSchemaId {
            args["merchandise_schema_id"] = merchandiseSchemaId
        }
        
        // 订单状态: 成功 success，待支付 pending
        switch status {
        case .success:
             args["status"] = "success"
        case .pending:
            args["status"] = "pending"
        default:
            break
        }
        
        // 退款状态: 完成 complete，部分退款 partial
        switch refundStatus {
        case .complete:
            args["refund_status"] = "complete"
        case .partial:
            args["refund_status"] = "partial"
        default:
            break
        }
        
        switch gateWayType {
        case .weixin:
            args["gateway_type"] = "weixin_tenpay_app"
        case .alipay:
            args["gateway_type"] = "alipay_app"
        default:
            break
        }
        return args
    }
}
