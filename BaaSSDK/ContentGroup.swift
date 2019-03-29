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

public class ContentGroup: BaseQuery {
    var contentGroupId: String
    var contengGroupName: String!

    public init(contentGroupId: String) {
        self.contentGroupId = contentGroupId
        super.init()
    }

    public func get(contentId: String, completion: @escaping ContentResultCompletion) {
        CcontentGroupProvider.request(.conentDetail(id: contentId)) { result in
            let (contentInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let content = ResultHandler.dictToContent(dict: contentInfo)
                completion(content, nil)
            }
        }
    }

    public func find(_ completion: @escaping ContentsResultCompletion) {
        queryArgs["content_group_id"] = contentGroupId
        CcontentGroupProvider.request(.contentList(prameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (contentsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContents(dict: contentsInfo)
                completion(contents, nil)
            }
        }
    }

    public func find(categoryId: String, completion: @escaping ContentsResultCompletion) {
        queryArgs["category_id"] = categoryId
        CcontentGroupProvider.request(.contentListInCategory(prameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (contentsInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let contents = ResultHandler.dictToContents(dict: contentsInfo)
                completion(contents, nil)
            }
        }
    }

    public func getCategoryList(_ completion: @escaping ContentCategorysResultCompletion) {
        CcontentGroupProvider.request(.categoryList(bodyParameters: ["content_group_id": contentGroupId], urlParameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categorysInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToContentCategorys(dict: categorysInfo)
                completion(categorys, nil)
            }
        }
    }

    public func getCategory(Id: String, completion: @escaping ContentCategoryResultCompletion) {
        CcontentGroupProvider.request(.categoryDetail(id: Id)) { result in
            let (categoryInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let category = ResultHandler.dictToContentCategory(dict: categoryInfo)
                completion(category, nil)
            }
        }
    }
}
