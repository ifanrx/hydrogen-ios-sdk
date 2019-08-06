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

    // 微信支付
    @discardableResult
    @objc public func wxPay(totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: Int64 = -1, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        guard !isPaying else {
            completion(nil, HError.init(code: 609) as NSError)
            return nil
        }

        self.isPaying = true
        // 创建订单，并获取预支付信息
        let canceller = self.pay(type: WXPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, completion: {(orderDict, error) in

            self.isPaying = false
            if error != nil {
                completion(nil, error)
            } else {
                let orderInfo = Order(dict: orderDict)
                orderInfo?.gateWayType = WXPay
                if let request = orderInfo?.wxPayReq, let appId = orderInfo?.wxAppid {
                    completion(orderInfo, nil)
                    // 调起微信支付
                    self.payWithWX(request, appId: appId)
                } else {
                    let payError = HError.init(code: 610) as NSError
                    completion(orderInfo, payError)
                }
            }
        })
        return canceller
    }

    // 支付宝支付
    @discardableResult
    @objc public func aliPay(totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: Int64 = -1, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        guard !isPaying else {
            completion(nil, HError.init(code: 609) as NSError)
            return nil
        }

        self.isPaying = true
        let canceller = self.pay(type: AliPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, completion: {(orderDict, error) in
            self.isPaying = false
            if error != nil {
                completion(nil, error)
            } else {
                let orderInfo = Order(dict: orderDict)
                orderInfo?.gateWayType = AliPay
                if let paymentUrl = orderInfo?.aliPaymenUrl, let appId = orderInfo?.aliAppid {
                    completion(orderInfo, nil)
                    self.payWithAli(paymentUrl, appId: appId)
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
        let request = PayProvider.request(.order(transactionID: transactionID)) { (result) in
            let (orderDict, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let orderInfo = Order(dict: orderDict)
                completion(orderInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    // 查询订单列表
    @discardableResult
    @objc public func orderList(query: Query? = nil, completion:@escaping OrderListCompletion) -> RequestCanceller? {
        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = PayProvider.request(.orderList(parameters: queryArgs)) { (result) in
            let (orderInfoDict, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let orderInfos = OrderList(dict: orderInfoDict)
                completion(orderInfos, nil)
            }
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
}

extension Pay {

    fileprivate func pay(type: String, totalCost: Float, merchandiseDescription: String, merchandiseSchemaID: Int64 = -1, merchandiseRecordID: String? = nil, merchandiseSnapshot: [String: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {

        var parameters: [String: Any] = ["gateway_type": type, "total_cost": totalCost, "merchandise_description": merchandiseDescription]
        if merchandiseSchemaID != -1 {
            parameters["merchandise_schema_id"] = merchandiseSchemaID
        }
        if let merchandiseRecordID = merchandiseRecordID {
            parameters["merchandise_record_id"] = merchandiseRecordID
        }
        if let merchandiseSnapshot = merchandiseSnapshot {
            parameters["merchandise_snapshot"] = merchandiseSnapshot
        }

        let request = PayProvider.request(.pay(parameters: parameters)) { result in
            let (orderInfo, error) = ResultHandler.handleResult(result)
            completion(orderInfo, error)
        }
        return RequestCanceller(cancellable: request)
    }

    fileprivate func payWithWX(_ request: PayReq, appId: String) {
        WXApi.registerApp(appId)
        WXApi.send(request)
    }

    fileprivate func payWithAli(_ paymentUrl: String, appId: String) {
        AlipaySDK.defaultService()?.payOrder(paymentUrl, fromScheme: appId, callback: nil)
    }
}

extension Pay: WXApiDelegate {

    // 微信支付结果
    public func onResp(_ resp: BaseResp) {
    }
}
