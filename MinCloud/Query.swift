//
//  BaseQuery.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

/// 查询条件
@objc(BaaSQuery)
open class Query: NSObject {
    
    /// 查询数目，每次获取 limit 条记录，默认为 20
    @objc public var limit: Int = 20
    
    /// 记录偏移值，每次查询按照某种排序获取记录，offset 为记录的起始序号。
    @objc public var offset: Int = 0
    
    ///
    @objc public var `where`: Where?
    
    /// 筛选请求返回的字段，设置需要返回的字段名，不需要返回的字段名前加 -。
    /// expand = ["name", "age"] 表示只获取 name 和 age 字段。
    /// expand = ["-name", "-age"] 表示获取除了 name 和 age 的其他所有字段。
    @objc public var select: [String]?
    
    /// 展开数据表中 pointer 类型的字段。
    /// pointer_value 为 pointer 类型
    /// 不使用 expand
    /// {
    ///     "id": "5a2fa9b008443e59e0e67829",
    ///     "name": "小米无线耳机",
    ///     "pointer_value": "5a2fa9xxxxxxxxxxxxxx"
    /// }
    ///
    /// 使用 expand
    /// {
    ///     "pointer_value": {
    ///         "created_at": 1516118400,
    ///         "name": "123",
    ///         "id": "5a2fa9xxxxxxxxxxxxxx"
    ///     },
    ///     "id": "5a2fa9b008443e59e0e67829",
    ///     "name": "小米无线耳机",
    /// }
    @objc public var expand: [String]?
    
    /// 控制使用升序或降序获取数据列表，设置需要排序的字段名，升序为字段名，降序在字段名前加 '-'。
    /// 升序
    /// orderBy = ["created_at"]
    /// 降序
    /// orderBy = ["-created_at"]
    /// 多重排序: 优先级 created_at > updated_at
    /// orderBy = ["created_at", "updated_at"]
    @objc public var orderBy: [String]?
    
    /// 在 ListResult 中是否返回记录的总数量，默认不返回
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

/// 订单查询条件，继承自 Query
@objc(BaaSOrderQuery)
open class OrderQuery: Query {
    
    /// 根据订单状态查询，默认获取所有状态
    @objc public var status: OrderStatus = .all
    
    /// 根据退款状态查询，默认获取所有状态
    @objc public var refundStatus: RefundStatus = .all
    
    /// 根据支付方式查询
    @objc public var gateWayType: GateWayType = .all
    
    /// 根据订单号查询
    @objc public var tradeNo: String?
    
    /// 根据流水号查询
    @objc public var transactionNo: String?
    
    /// 根据商品 Id 查询
    @objc public var merchandiseRecordId: String?
    
    /// 根据商品表 Id 查询
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
