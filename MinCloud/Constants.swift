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

public typealias BOOLResultCompletion = (_ success: Bool, _ error: Error?) -> Void
public typealias COUNTResultCompletion = (_ count: Int?, _ error: Error?) -> Void
public typealias OBJECTResultCompletion = (_ object: [String: Any]?, _ error: Error?) -> Void

public typealias UserResultCompletion = (_ user: User?, _ error: Error?) -> Void
public typealias CurrentUserResultCompletion = (_ user: CurrentUser?, _ error: Error?) -> Void
public typealias UserListResultCompletion = (_ listResult: UserListResult?, _ error: Error?) -> Void
public typealias RecordResultCompletion = (_ record: TableRecord?, _ error: Error?) -> Void
public typealias RecordListResultCompletion = (_ records: RecordListResult?, _ error: Error?) -> Void

public typealias FileResultCompletion = (_ file: File?, _ error: Error?) -> Void
public typealias FileListResultCompletion = (_ listResult: FileListResult?, _ error: Error?) -> Void
public typealias FileCategoryResultCompletion = (_ file: FileCategory?, _ error: Error?) -> Void
public typealias FileCategoryListResultCompletion = (_ listResult: FileCategoryListResult?, _ error: Error?) -> Void

public typealias ContentResultCompletion = (_ content: Content?, _ error: Error?) -> Void
public typealias ContentListResultCompletion = (_ listResult: ContentListResult?, _ error: Error?) -> Void
public typealias ContentCategoryResultCompletion = (_ file: ContentCategory?, _ error: Error?) -> Void
public typealias ContentCategoryListResultCompletion = (_ listResult: ContentCategoryListResult?, _ error: Error?) -> Void

public typealias ProgressBlock = (_ progress: Progress?) -> Void
