//
//  ContentGroup.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BaaSContentGroup)
open class ContentGroup: NSObject {
    var Id: Int64
    var name: String!

    @objc public init(Id: Int64) {
        self.Id = Id
        super.init()
    }

    /// 获取内容详情
    ///
    /// - Parameters:
    ///   - contentId: 内容 Id
    ///   - select: 筛选条件，只返回指定的字段。可选
    ///   - expand: 扩展条件。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func get(_ contentId: Int64, select: [String]? = nil, expand: [String]? = nil, completion: @escaping ContentResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = ContentGroupProvider.request(.conentDetail(id: contentId, parameters: parameters)) { result in
            let (contentInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let content = ResultHandler.dictToContent(dict: contentInfo)
                completion(content, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询内容列表
    ///
    /// - Parameter:
    ///   - query: 查询条件，满足条件的内容件将被返回。可选
    ///   - completion: 结果回调
    ///
    /// - Parameter completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func find(query: Query? = nil, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.contentList(parameters: queryArgs)) { result in
            let (contentsInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContentListResult(dict: contentsInfo)
                completion(contents, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询指定分类下的内容列表
    ///
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的文件。
    /// 如果不设置条件，将获取所有文件。
    ///
    /// - Parameters:
    ///   - categoryId: 分类 Id
    ///   - query: 查询条件，满足条件的分类将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(categoryId: Int64, query: Query? = nil, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["category_id"] = categoryId
        let request = ContentGroupProvider.request(.contentListInCategory(prameters: queryArgs)) { result in
            let (contentsInfo, error) = ResultHandler.handleResult( result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContentListResult(dict: contentsInfo)
                completion(contents, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取分类列表
    ///
    /// - Parameter:
    ///   - query: 查询条件，满足条件的分类将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getCategoryList(query: Query? = nil, completion: @escaping ContentCategoryListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.categoryList(parameters: queryArgs)) { result in
            let (categorysInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToContentCategoryListResult(dict: categorysInfo)
                completion(categorys, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取分类详情
    ///
    /// - Parameters:
    ///   - Id: 分类 Id
    ///   - completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func getCategory(_ Id: Int64, completion: @escaping ContentCategoryResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.categoryDetail(id: Id)) { result in
            let (categoryInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let category = ResultHandler.dictToContentCategory(dict: categoryInfo)
                completion(category, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
