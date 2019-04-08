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
open class ContentGroup: BaseQuery {
    var Id: String
    var name: String!

    @objc public init(Id: String) {
        self.Id = Id
        super.init()
    }

    @discardableResult
    @objc open func get(_ contentId: String, completion: @escaping ContentResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.conentDetail(id: contentId)) { result in
            let (contentInfo, error) = ResultHandler.handleResult(result: result)
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
    @objc open func find(_ completion: @escaping ContentsResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["content_group_id"] = Id
        let request = ContentGroupProvider.request(.contentList(prameters: queryArgs)) { [weak self] result in
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

    @discardableResult
    @objc open func find(categoryId: String, completion: @escaping ContentsResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
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

    @discardableResult
    @objc open func getCategoryList(_ completion: @escaping ContentCategorysResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.categoryList(parameters: ["content_group_id": Id])) { [weak self] result in
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

    @discardableResult
    @objc open func getCategory(_ Id: String, completion: @escaping ContentCategoryResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = ContentGroupProvider.request(.categoryDetail(id: Id)) { result in
            let (categoryInfo, error) = ResultHandler.handleResult(result: result)
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
