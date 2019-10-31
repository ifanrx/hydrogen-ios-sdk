//
//  OrderInfo.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/5/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

@objc(BaaSOrder)
open class Order: NSObject, Mappable {
    @objc public internal(set) var Id: String?
    @objc public internal(set) var tradeNo: String? // 真正的交易 ID, 业务方在微信后台对账时可看到此字段
    @objc public internal(set) var transactionNo: String? // 知晓云平台所记录的流水号
    @objc public internal(set) var currencyType: String?
    @objc public internal(set) var totalCost: Double = 0
    @objc public internal(set) var status: String?
    @objc public internal(set) var createdBy: String?
    @objc public internal(set) var createdAt: TimeInterval = 0
    @objc public internal(set) var updatedAt: TimeInterval = 0
    @objc public internal(set) var payAt: TimeInterval = 0
    @objc public internal(set) var refundStatus: String?
    @objc public internal(set) var gateWayType: String?
    @objc public internal(set) var gatewayExtraInfo: [String: Any]?
    @objc public internal(set) var merchandiseRecordId: String?
    @objc public internal(set) var merchandiseSchemaId: String?
    @objc public internal(set) var merchandiseDescription: String?
    @objc public internal(set) var merchandiseSnapshot: [String: Any]?
    var dictInfo: [String: Any]?

    @objc public override init() {
        super.init()
    }

    @objc required public init?(dict: [String: Any]) {
        self.dictInfo = dict
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

    var wxAppid: String? {
        var appId: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            appId = paymentParameters.getString("appid")
        } else {
            appId = self.dictInfo?.getString("appid")
        }
        return appId
    }

    var aliAppid: String? {
        var appId: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            appId = paymentParameters.getString("appid")
        } else {
            appId = self.dictInfo?.getString("appid")
        }
        return appId
    }

    var aliPaymenUrl: String? {
        var paymentUrl: String?
        if let paymentParameters = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            paymentUrl = paymentParameters.getString("payment_url")
        } else {
            paymentUrl = self.dictInfo?.getString("payment_url")
        }
        return paymentUrl
    }

    var wxPayReq: PayReq? {

        var payReq: PayReq!
        var payDict: [String: Any]?
        if let paymentParams = self.gatewayExtraInfo?.getDict("payment_parameters") as? [String: Any] {
            payDict = paymentParams
        } else {
            payDict = self.dictInfo
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
        let dict = self.dictInfo ?? [:]
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.dictInfo ?? [:]
        return dict.toJsonString
    }
}
