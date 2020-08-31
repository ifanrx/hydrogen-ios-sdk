//
//  Pay.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/5/14.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

@objc(BaaSPay)
open class Pay: NSObject {

    @objc public static let shared = Pay()
    @objc public var isPaying: Bool = false
    
    static var PayProvider = MoyaProvider<PayAPI>(plugins: logPlugin)

    // 微信支付
    @discardableResult
    @objc public func wxPay(totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: String? = nil, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        guard !isPaying else {
            completion(nil, HError.init(code: 609) as NSError)
            return nil
        }

        self.isPaying = true
        // 创建订单，并获取预支付信息
        let canceller = self.pay(type: WXPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, merchandiseSchemaID: merchandiseSchemaID, merchandiseRecordID: merchandiseRecordID, merchandiseSnapshot: merchandiseSnapshot, completion: {(order, error) in

            self.isPaying = false
            if error != nil {
                completion(nil, error)
            } else {
                order?.gateWayType = WXPay
                if let request = order?.wxPayReq, let appId = order?.wxAppid {
                    // 调起微信支付
                    self.payWithWX(request, appId: appId)
                    completion(order, nil)
                } else {
                    let payError = HError.init(code: 610) as NSError
                    completion(order, payError)
                }
            }
        })
        return canceller
    }

    // 支付宝支付
    @discardableResult
    @objc public func aliPay(totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: String? = nil, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        guard !isPaying else {
            completion(nil, HError.init(code: 609) as NSError)
            return nil
        }

        self.isPaying = true
        let canceller = self.pay(type: AliPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, merchandiseSchemaID: merchandiseSchemaID, merchandiseRecordID: merchandiseRecordID, merchandiseSnapshot: merchandiseSnapshot, completion: {(order, error) in
            self.isPaying = false
            if error != nil {
                completion(nil, error)
            } else {
                order?.gateWayType = AliPay
                if let paymentUrl = order?.aliPaymenUrl, let appId = order?.aliAppid {
                    self.payWithAli(paymentUrl, appId: appId)
                    completion(order, nil)
                } else {
                    completion(nil, HError.init(code: 610) as NSError)
                }
            }
        })
        return canceller
    }

    // 查询订单
    @discardableResult
    @objc public func order(_ transactionID: String, completion:@escaping OrderCompletion) -> RequestCanceller? {
        let request = Pay.PayProvider.request(.order(transactionID: transactionID)) { (result) in
            ResultHandler.parse(result, handler: { (order: Order?, error: NSError?) in
                completion(order, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // 查询订单列表
    @discardableResult
    @objc public func orderList(query: Query? = nil, completion:@escaping OrderListCompletion) -> RequestCanceller? {
        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = Pay.PayProvider.request(.orderList(parameters: queryArgs)) { (result) in
            ResultHandler.parse(result, handler: { (listResult: OrderList?, error: NSError?) in
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // 未支付状态，重新支付
    @objc public func repay(_ order: Order, completion:@escaping OrderCompletion) {
        guard !isPaying else {
            completion(nil, HError.init(code: 609) as NSError)
            return
        }
        guard let gateWayType = order.gateWayType else {
            completion(nil, HError.init(code: 400) as NSError)
            return
        }
        if gateWayType == WXPay {
            if let request = order.wxPayReq, let appId = order.wxAppid {
                // 调起微信支付
                self.payWithWX(request, appId: appId)
            } else {
                let error = HError.init(code: 610) as NSError
                completion(order, error)
            }

        } else if gateWayType == AliPay {
            if let paymentUrl = order.aliPaymenUrl, let appId = order.aliAppid {
                self.payWithAli(paymentUrl, appId: appId)
            } else {
                completion(nil, HError.init(code: 610) as NSError)
            }
        }

    }
    
    func payWithWX(_ request: PayReq, appId: String) {
        assert(Config.wechatAppId != nil, Localisation.Wechat.registerAppId)
        
        WXApi.send(request)
    }
    
    func payWithAli(_ paymentUrl: String, appId: String) {
        AlipaySDK.defaultService()?.payOrder(paymentUrl, fromScheme: appId, callback: nil)
    }
}

extension Pay {

    fileprivate func pay(type: String, totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: String? = nil, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {

        var parameters: [String: Any] = ["gateway_type": type, "total_cost": totalCost, "merchandise_description": merchandiseDescription]
        if let merchandiseSchemaID = merchandiseSchemaID {
            parameters["merchandise_schema_id"] = merchandiseSchemaID
        }
        if let merchandiseRecordID = merchandiseRecordID {
            parameters["merchandise_record_id"] = merchandiseRecordID
        }
        if let merchandiseSnapshot = merchandiseSnapshot {
            var merchandiseSnapshotStr = merchandiseSnapshot.toJsonString
            merchandiseSnapshotStr = merchandiseSnapshotStr.trimmingCharacters(in: NSCharacterSet.whitespaces)
            merchandiseSnapshotStr = merchandiseSnapshotStr.trimmingCharacters(in: NSCharacterSet.newlines)
            parameters["merchandise_snapshot"] = merchandiseSnapshotStr
        }

        let request = Pay.PayProvider.request(.pay(parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (order: Order?, error: NSError?) in
                completion(order, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
