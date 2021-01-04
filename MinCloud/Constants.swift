//
//  Constants.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

/// 比较查询可设置的操作
@objc(BaaSOperator)
public enum Operator: Int {
    /// 等于
    case equalTo = 0
    /// 不等于
    case notEqualTo = 1
    /// 大于
    case greaterThan
    /// 大于等于
    case greaterThanOrEqualTo
    /// 小于
    case lessThan
    /// 小于等于
    case lessThanOrEqualTo
}

/// 订单状态
@objc(BaaSOrderStatus)
public enum OrderStatus: Int {
    /// 全部，默认
    case all = 0
    /// 支付成功
    case success = 1
    /// 待支付
    case pending = 2
}

/// 支付退款状态
@objc(BaaSRefundStatus)
public enum RefundStatus: Int {
    /// 全部退款，默认
    case all = 0
    /// 退款成功
    case complete = 1
    /// 部分退款
    case partial = 2
}

/// 支付方式
@objc(BaaSGateWayType)
public enum GateWayType: Int {
    /// 全部，默认
    case all = 0
    // 微信支付
    case weixin = 1
    // 支付宝
    case alipay = 2
    
}

// MARK: - Wamp

/// 订阅事件类型
@objc(BaaSSubscriptionEvent)
public enum SubscriptionEvent: Int {
    /// 创建表记录
    case onCreate = 0
    /// 更新表记录
    case onUpdate = 1
    /// 删除表记录
    case onDelete = 2
    
    internal var eventValue: String {
        switch self {
        case .onCreate:
            return "on_create"
        case .onUpdate:
            return "on_update"
        case .onDelete:
            return "on_delete"
        }
    }
}

// MARK: - 通用回调函数

public typealias BOOLResultCompletion = (_ success: Bool, _ error: NSError?) -> Void
public typealias COUNTResultCompletion = (_ count: Int?, _ error: NSError?) -> Void
public typealias OBJECTResultCompletion = (_ object: [String: Any]?, _ error: NSError?) -> Void

public typealias UserResultCompletion = (_ user: User?, _ error: NSError?) -> Void
public typealias CurrentUserResultCompletion = (_ user: CurrentUser?, _ error: NSError?) -> Void
public typealias UserListResultCompletion = (_ listResult: UserList?, _ error: NSError?) -> Void
public typealias RecordResultCompletion = (_ record: Record?, _ error: NSError?) -> Void
public typealias RecordListResultCompletion = (_ records: RecordList?, _ error: NSError?) -> Void

// MARK: - 文件回调函数
public typealias FileResultCompletion = (_ file: File?, _ error: NSError?) -> Void
public typealias FileListResultCompletion = (_ listResult: FileList?, _ error: NSError?) -> Void
public typealias FileCategoryResultCompletion = (_ file: FileCategory?, _ error: NSError?) -> Void
public typealias FileCategoryListResultCompletion = (_ listResult: FileCategoryList?, _ error: NSError?) -> Void

public typealias ProgressBlock = (_ progress: Progress?) -> Void

// MARK: - 内容库回调函数
public typealias ContentResultCompletion = (_ content: Content?, _ error: NSError?) -> Void
public typealias ContentListResultCompletion = (_ listResult: ContentList?, _ error: NSError?) -> Void
public typealias ContentCategoryResultCompletion = (_ file: ContentCategory?, _ error: NSError?) -> Void
public typealias ContentCategoryListResultCompletion = (_ listResult: ContentCategoryList?, _ error: NSError?) -> Void

// MARK: - 订单回调函数
public typealias OrderCompletion = (_ order: Order?, _ error: NSError?) -> Void
public typealias OrderListCompletion = (_ listResult: OrderList?, _ error: NSError?) -> Void
