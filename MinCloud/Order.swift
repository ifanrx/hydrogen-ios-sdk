//
//  OrderInfo.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/5/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

/// 订单
@objc(BaaSOrder)
open class Order: NSObject, Mappable {
    /// 订单 Id
    @objc public internal(set) var Id: String?
    /// 交易号，业务方在(微信/支付宝)后台对账时可看到此字段
    @objc public internal(set) var tradeNo: String?
    /// 知晓云平台所记录的流水号
    @objc public internal(set) var transactionNo: String?
    /// 货币类型
    @objc public internal(set) var currencyType: String?
    /// 交易金额
    @objc public internal(set) var totalCost: Double = 0
    /// 交易状态
    @objc public internal(set) var status: String?
    /// 订单创建者的 Id
    @objc public internal(set) var createdBy: String?
    /// 订单创建时间
    @objc public internal(set) var createdAt: TimeInterval = 0
    /// 订单更新时间
    @objc public internal(set) var updatedAt: TimeInterval = 0
    /// 订单支付时间
    @objc public internal(set) var payAt: TimeInterval = 0
    /// 退款状态
    @objc public internal(set) var refundStatus: String?
    /// 支付方式
    @objc public internal(set) var gateWayType: String?
    /// 支付成功后回调的订单详细信息，目前仅支持微信支付。
    @objc public internal(set) var gatewayExtraInfo: [String: Any]?
    /// 商品 Id 可用于定位用户购买的物品
    @objc public internal(set) var merchandiseRecordId: String?
    /// 商品表 Id，可用于定位用户购买的物品
    @objc public internal(set) var merchandiseSchemaId: String?
    /// 支付凭证-商品详情的内容
    @objc public internal(set) var merchandiseDescription: String?
    /// 根据业务需求自定义的数据
    @objc public internal(set) var merchandiseSnapshot: [String: Any]?
    
    /// 所有订单信息
    @objc public var orderInfo: [String: Any] = [:]

    @objc public override init() {
        super.init()
    }

    @objc required public init?(dict: [String: Any]) {
        self.orderInfo = dict
        self.Id = dict.getString("id")
        self.tradeNo = dict.getString("trade_no")
        self.transactionNo = dict.getString("transaction_no")
        self.totalCost = dict.getDouble("total_cost")
        self.status = dict.getString("status")
        self.createdBy = dict.getString("created_by")
        self.createdAt = dict.getDouble("created_at")
        self.updatedAt = dict.getDouble("updated_at")
        self.payAt = dict.getDouble("pay_at")
        self.refundStatus = dict.getString("refund_status")
        self.currencyType = dict.getString("currency_type")
        self.gateWayType = dict.getString("gateway_type")
        self.gatewayExtraInfo = dict.getDict("gateway_extra_info") as? [String: Any]
        self.merchandiseRecordId = dict.getString("merchandise_record_id")
        self.merchandiseSchemaId = dict.getString("merchandise_schema_id")
        self.merchandiseSnapshot = dict.getDict("merchandise_snapshot") as? [String: Any]
        self.merchandiseDescription = dict.getString("merchandise_description")
    }

    /// 根据 key 获取值
    @objc public func get(_ key: String) -> Any? {
        return orderInfo[key]
    }

    var wxAppid: String? {
        var appId: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            appId = paymentParameters.getString("appid")
        } else {
            appId = self.orderInfo.getString("appid")
        }
        return appId
    }

    var aliAppid: String? {
        var appId: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            appId = paymentParameters.getString("appid")
        } else {
            appId = self.orderInfo.getString("appid")
        }
        return appId
    }

    var aliPaymenUrl: String? {
        var paymentUrl: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            paymentUrl = paymentParameters.getString("payment_url")
        } else {
            paymentUrl = self.orderInfo.getString("payment_url")
        }
        return paymentUrl
    }

    var wxPayReq: PayReq? {

        var payReq: PayReq!
        var payDict: [String: Any]?
        if let paymentParams = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            payDict = paymentParams
        } else {
            payDict = self.orderInfo
        }
        if let dict = payDict {
            payReq = PayReq()
            if let prepayId = dict.getString("prepayid") {
                payReq.prepayId = prepayId
            }
            if let partnerId = dict.getString("partnerid") {
                payReq.partnerId = partnerId
            }
            if let nonceStr = dict.getString("noncestr") {
                payReq.nonceStr = nonceStr
            }
            if let timeStampStr = dict.getString("timestamp"), let timeStamp = UInt32(timeStampStr) {
                payReq.timeStamp = timeStamp
            }
            if let sign = dict.getString("sign") {
                payReq.sign = sign
            }
            if let package = dict.getString("package") {
                payReq.package = package
            }
        }
        return payReq
    }

    @objc override open var description: String {
        let dict = self.orderInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.orderInfo
        return dict.toJsonString
    }
}
