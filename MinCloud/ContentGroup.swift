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

@objc(BAASContentGroup)
open class ContentGroup: NSObject {
    var Id: String
    var name: String!

    @objc public init(Id: String) {
        self.Id = Id
        super.init()
    }

    @discardableResult
    @objc open func get(_ contentId: String, completion: @escaping ContentResultCompletion) -> RequestCanceller? {
        return self.get(contentId, query: Query(), completion: completion)
    }

    /// 获取内容详情
    ///
    /// - Parameters:
    ///   - contentId: 内容 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func get(_ contentId: String, query: Query, completion: @escaping ContentResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.conentDetail(id: contentId, parameters: query.queryArgs)) { result in
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

    @discardableResult
    @objc open func find(_ completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        return self.find(query: Query(), completion: completion)
    }

    /// 查询内容列表
    ///
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的文件。
    /// 如果不设置条件，将获取所有文件。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func find(query: Query, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        query.queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.contentList(parameters: query.queryArgs)) { result in
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

    @discardableResult
    @objc open func find(categoryId: String, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        return self.find(categoryId: categoryId, query: Query(), completion: completion)
    }

    /// 查询指定分类下的内容列表
    ///
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的文件。
    /// 如果不设置条件，将获取所有文件。
    ///
    /// - Parameters:
    ///   - categoryId: 分类 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(categoryId: String, query: Query, completion: @escaping ContentListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        query.queryArgs["category_id"] = categoryId
        let request = ContentGroupProvider.request(.contentListInCategory(prameters: query.queryArgs)) { result in
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

    @discardableResult
    @objc open func getCategoryList(_ completion: @escaping ContentCategoryListResultCompletion) -> RequestCanceller? {
        return self.getCategoryList(query: Query(), completion: completion)
    }

    /// 获取分类列表
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getCategoryList(query: Query, completion: @escaping ContentCategoryListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        query.queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.categoryList(parameters: query.queryArgs)) { result in
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
    @objc open func getCategory(_ Id: String, completion: @escaping ContentCategoryResultCompletion) -> RequestCanceller? {
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
