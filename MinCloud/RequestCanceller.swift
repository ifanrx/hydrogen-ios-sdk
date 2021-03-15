//
//  RequestCanceller.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/29.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

/// 网络请求取消器
@objc public class RequestCanceller: NSObject {
    var cancellable: Cancellable?

    public init(cancellable: Cancellable?) {
        self.cancellable = cancellable
        super.init()
    }

    public convenience override init() {
        self.init(cancellable: nil)
    }

    /// 取消当前请求
    @objc public func cancel() {
        cancellable?.cancel()
    }

    /// 是否已经取消
    @objc public var isCancelled: Bool {
        return cancellable?.isCancelled ?? false
    }
}
