//
//  Pay.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/5/14.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

/// 创建支付订单时，所有可以提交的参数
@objc(PaymentOptionKey)
public class PaymentOptionKey: NSObject, NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let aCopy = PaymentOptionKey(key: key)
        return aCopy
    }
    
    let key: String
    private init(key: String) {
        self.key = key
        super.init()
    }
    
    /// 商品表 Id，可用于定位用户购买的物品
    /// 该参数对应值为 String 类型
    @objc public static let merchandiseSchemaID = PaymentOptionKey(key: "merchandise_schema_id")
    
    /// 商品记录 Id，可用于定位用户购买的物品
    /// 该参数对应值为 String 类型
    @objc public static let merchandiseRecordID = PaymentOptionKey(key: "merchandise_record_id")
    
    /// 根据业务需求自定义的数据
    /// 该参数对应值为 [String: Any] 类型
    @objc public static let merchandiseSnapshot = PaymentOptionKey(key: "merchandise_snapshot")
    
    /// 当前订单是否需要分账，该参数仅用于*微信支付*。
    /// 分账功能仅商用版及商用版以上版本可以使用。
    /// 该参数对应值为 Bool 类型
    @objc public static let profitSharing = PaymentOptionKey(key: "profit_sharing")
    
    /// 支付金额
    /// 该参数对应值为 Float 类型
    static let totalCost = PaymentOptionKey(key: "total_cost")
    
    /// 支付凭证-商品详情的内容
    /// 该参数对应值为 String 类型
    static let merchandiseDescription = PaymentOptionKey(key: "merchandise_description")
    
    /// 支付方式：微信/支付宝
    /// 该参数对应值为 String 类型
    static let gatewayType = PaymentOptionKey(key: "gateway_type")
}

/// 支付
/// 目前支持微信支付及支付宝支付
@objc(BaaSPay)
open class Pay: NSObject {

    @objc public static let shared = Pay()
    @objc public var isPaying: Bool = false
    @objc public var callBackQueue: DispatchQueue = .main
    
    static var PayProvider = MoyaProvider<PayAPI>(plugins: logPlugin)

    /// 微信支付
    ///
    /// - Parameters:
    ///     - totalCost: 支付总额，单位：元
    ///     - merchandiseDescription: 微信支付凭证-商品详情的内容
    ///     - options: 支付参数，参考 PaymentOptionKey
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public func wxPay(totalCost: Float, merchandiseDescription: String, options: [PaymentOptionKey: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        objc_sync_enter(self)
        guard !isPaying else {
            objc_sync_exit(self)
            callBackQueue.async {
                completion(nil, HError.init(code: 609) as NSError)
            }
            return nil
        }
        self.isPaying = true
        objc_sync_exit(self)
        
        // 创建订单，并获取预支付信息
        let canceller = self.pay(type: WXPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, options: options ?? [:], completion: {(order, error) in

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

    /// 支付宝支付
    ///
    /// - Parameters:
    ///     - totalCost: 支付总额，单位：元
    ///     - merchandiseDescription: 支付宝支付凭证-商品详情的内容
    ///     - options: 支付参数，参考 PaymentOptionKey
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public func aliPay(totalCost: Float, merchandiseDescription: String, options: [PaymentOptionKey: Any]? = nil, completion:@escaping OrderCompletion) -> RequestCanceller? {
        
        objc_sync_enter(self)
        guard !isPaying else {
            objc_sync_exit(self)
            callBackQueue.async {
                completion(nil, HError.init(code: 609) as NSError)
            }
            return nil
        }
        self.isPaying = true
        objc_sync_exit(self)
        
        let canceller = self.pay(type: AliPay, totalCost: totalCost, merchandiseDescription: merchandiseDescription, options: options ?? [:], completion: {(order, error) in
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

    /// 获取订单详情
    ///
    /// - Parameters:
    ///   - transactionID: 交易号
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func order(_ transactionID: String, completion:@escaping OrderCompletion) -> RequestCanceller? {
        let request = Pay.PayProvider.request(.order(transactionID: transactionID), callbackQueue: callBackQueue) { (result) in
            ResultHandler.parse(result, handler: { (order: Order?, error: NSError?) in
                completion(order, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询订单列表
    /// - Parameters:
    ///     - query: 查询条件，满足条件的文件将被返回。可选
    @discardableResult
    @objc public func orderList(query: Query? = nil, completion:@escaping OrderListCompletion) -> RequestCanceller? {
        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = Pay.PayProvider.request(.orderList(parameters: queryArgs), callbackQueue: callBackQueue) { (result) in
            ResultHandler.parse(result, handler: { (listResult: OrderList?, error: NSError?) in
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // 未支付状态，重新支付
    @objc func repay(_ order: Order, completion:@escaping OrderCompletion) {
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

    fileprivate func pay(type: String, totalCost: Float, merchandiseDescription: String, options: [PaymentOptionKey: Any], completion:@escaping OrderCompletion) -> RequestCanceller? {

        var parameters: [String: Any] = [PaymentOptionKey.gatewayType.key: type, PaymentOptionKey.totalCost.key: totalCost, PaymentOptionKey.merchandiseDescription.key: merchandiseDescription]
        if let merchandiseSchemaID = options[PaymentOptionKey.merchandiseSchemaID] as? String {
            parameters[PaymentOptionKey.merchandiseSchemaID.key] = merchandiseSchemaID
        }
        if let merchandiseRecordID = options[PaymentOptionKey.merchandiseRecordID] as? String {
            parameters[PaymentOptionKey.merchandiseRecordID.key] = merchandiseRecordID
        }
        if let merchandiseSnapshot = options[PaymentOptionKey.merchandiseSnapshot] as? [String: Any] {
            var merchandiseSnapshotStr = merchandiseSnapshot.toJsonString
            merchandiseSnapshotStr = merchandiseSnapshotStr.trimmingCharacters(in: NSCharacterSet.whitespaces)
            merchandiseSnapshotStr = merchandiseSnapshotStr.trimmingCharacters(in: NSCharacterSet.newlines)
            parameters[PaymentOptionKey.merchandiseSnapshot.key] = merchandiseSnapshotStr
        }
        if let profitSharing = options[PaymentOptionKey.profitSharing] as? Bool {
            parameters[PaymentOptionKey.profitSharing.key] = profitSharing
        }

        let request = Pay.PayProvider.request(.pay(parameters: parameters), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (order: Order?, error: NSError?) in
                completion(order, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
