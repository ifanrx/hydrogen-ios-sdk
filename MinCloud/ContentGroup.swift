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
open class ContentGroup: Query {
    var Id: String
    var name: String!

    @objc public init(Id: String) {
        self.Id = Id
        super.init()
    }

    /// 获取内容详情
    ///
    /// - Parameters:
    ///   - contentId: 内容 Id
    ///   - completion: 结果结果
    /// - Returns:
    @discardableResult
    @objc open func get(_ contentId: String, completion: @escaping ContentResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.conentDetail(id: contentId, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (contentInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
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
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的文件。
    /// 如果不设置条件，将获取所有文件。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func find(_ completion: @escaping ContentsResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.contentList(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (contentsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContents(dict: contentsInfo)
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
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(categoryId: String, completion: @escaping ContentsResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["category_id"] = categoryId
        let request = ContentGroupProvider.request(.contentListInCategory(prameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (contentsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContents(dict: contentsInfo)
                completion(contents, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取分类列表
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getCategoryList(_ completion: @escaping ContentCategorysResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.categoryList(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categorysInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToContentCategorys(dict: categorysInfo)
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

        let request = ContentGroupProvider.request(.categoryDetail(id: Id, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categoryInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
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
