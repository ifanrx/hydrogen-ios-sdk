//
//  Constants.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASOperator)
public enum Operator: Int {
    case equalTo = 0
    case notEqualTo = 1
    case greaterThan
    case greaterThanOrEqualTo
    case lessThan
    case lessThanOrEqualTo
}

public typealias BOOLResultCompletion = (_ success: Bool, _ error: Error?) -> Void
public typealias COUNTResultCompletion = (_ count: Int?, _ error: Error?) -> Void
public typealias OBJECTResultCompletion = (_ object: [String: Any]?, _ error: Error?) -> Void

public typealias UserResultCompletion = (_ user: User?, _ error: Error?) -> Void
public typealias UsersResultCompletion = (_ users: [CurrentUser]?, _ error: Error?) -> Void
public typealias RecordResultCompletion = (_ record: TableRecord?, _ error: Error?) -> Void
public typealias RecordsResultCompletion = (_ records: [TableRecord]?, _ error: Error?) -> Void

public typealias FileResultCompletion = (_ file: File?, _ error: Error?) -> Void
public typealias FilesResultCompletion = (_ files: [File]?, _ error: Error?) -> Void
public typealias FileCategoryResultCompletion = (_ file: FileCategory?, _ error: Error?) -> Void
public typealias FileCategorysResultCompletion = (_ file: [FileCategory]?, _ error: Error?) -> Void

public typealias ContentResultCompletion = (_ content: Content?, _ error: Error?) -> Void
public typealias ContentsResultCompletion = (_ contents: [Content]?, _ error: Error?) -> Void
public typealias ContentCategoryResultCompletion = (_ file: ContentCategory?, _ error: Error?) -> Void
public typealias ContentCategorysResultCompletion = (_ file: [ContentCategory]?, _ error: Error?) -> Void

public typealias ProgressBlock = (_ progress: Progress?) -> Void

public typealias CurrentUserResultCompletion = (_ user: CurrentUser?, _ error: Error?) -> Void

public typealias UserListResultCompletion = (_ userListResult: UserListResult?, _ error: Error?) -> Void
