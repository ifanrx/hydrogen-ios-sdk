//
//  Constants.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BaaSOperator)
public enum Operator: Int {
    case equalTo = 0           // 等于
    case notEqualTo = 1        // 不等于
    case greaterThan           // 大于
    case greaterThanOrEqualTo  // 大于等于
    case lessThan              // 小于
    case lessThanOrEqualTo     // 小于等于
}

@objc(BaaSOrderStatus)
public enum OrderStatus: Int {
    case all = 0               // 全部，默认
    case success = 1           // 支付成功
    case pending = 2           // 待支付
}

@objc(BaaSRefundStatus)
public enum RefundStatus: Int {
    case all = 0               // 全部，默认
    case complete = 1          // 退款成功
    case partial = 2           // 部分退款
}

@objc(BaaSGateWayType)
public enum GateWayType: Int {
    case all = 0               // 全部，默认
    case weixin = 1            // 微信支付
    case alipay = 2            // 支付宝
    
}

public typealias BOOLResultCompletion = (_ success: Bool, _ error: NSError?) -> Void
public typealias COUNTResultCompletion = (_ count: Int?, _ error: NSError?) -> Void
public typealias OBJECTResultCompletion = (_ object: [String: Any]?, _ error: NSError?) -> Void

public typealias UserResultCompletion = (_ user: User?, _ error: NSError?) -> Void
public typealias CurrentUserResultCompletion = (_ user: CurrentUser?, _ error: NSError?) -> Void
public typealias UserListResultCompletion = (_ listResult: UserList?, _ error: NSError?) -> Void
public typealias RecordResultCompletion = (_ record: Record?, _ error: NSError?) -> Void
public typealias RecordListResultCompletion = (_ records: RecordList?, _ error: NSError?) -> Void

public typealias FileResultCompletion = (_ file: File?, _ error: NSError?) -> Void
public typealias FileListResultCompletion = (_ listResult: FileList?, _ error: NSError?) -> Void
public typealias FileCategoryResultCompletion = (_ file: FileCategory?, _ error: NSError?) -> Void
public typealias FileCategoryListResultCompletion = (_ listResult: FileCategoryList?, _ error: NSError?) -> Void

public typealias ContentResultCompletion = (_ content: Content?, _ error: NSError?) -> Void
public typealias ContentListResultCompletion = (_ listResult: ContentList?, _ error: NSError?) -> Void
public typealias ContentCategoryResultCompletion = (_ file: ContentCategory?, _ error: NSError?) -> Void
public typealias ContentCategoryListResultCompletion = (_ listResult: ContentCategoryList?, _ error: NSError?) -> Void

public typealias OrderCompletion = (_ order: Order?, _ error: NSError?) -> Void
public typealias OrderListCompletion = (_ listResult: OrderList?, _ error: NSError?) -> Void

public typealias ProgressBlock = (_ progress: Progress?) -> Void
