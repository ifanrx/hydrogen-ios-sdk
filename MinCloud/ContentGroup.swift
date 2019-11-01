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
    @objc public internal(set) var Id: String?
    @objc public internal(set) var name: String?
    
    static var ContentGroupProvider = MoyaProvider<ContentGroupAPI>(plugins: logPlugin)

    @objc public init(Id: String) {
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
    @objc open func get(_ contentId: String, select: [String]? = nil, completion: @escaping ContentResultCompletion) -> RequestCanceller? {

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        let request = ContentGroup.ContentGroupProvider.request(.conentDetail(id: contentId, parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (content: Content?, error: NSError?) in
                completion(content, error)
            })
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

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["content_group_id"] = Id
        let request = ContentGroup.ContentGroupProvider.request(.contentList(parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: ContentList?, error: NSError?) in
                completion(listResult, error)
            })
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
    @objc open func find(categoryId: String, query: Query? = nil, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["category_id"] = categoryId
        let request = ContentGroup.ContentGroupProvider.request(.contentListInCategory(prameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: ContentList?, error: NSError?) in
                completion(listResult, error)
            })
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

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["content_group_id"] = Id
        let request = ContentGroup.ContentGroupProvider.request(.categoryList(parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: ContentCategoryList?, error: NSError?) in
                completion(listResult, error)
            })
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
    @objc open func getCategory(_ Id: String, completion: @escaping ContentCategoryResultCompletion) -> RequestCanceller? {

        let request = ContentGroup.ContentGroupProvider.request(.categoryDetail(id: Id)) { result in
            ResultHandler.parse(result, handler: { (category: ContentCategory?, error: NSError?) in
                completion(category, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
