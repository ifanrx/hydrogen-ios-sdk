//
//  FileTable.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASFileManager)
open class FileManager: BaseQuery {

    // MARK: File

    @discardableResult
    @objc open func get(_ fileId: String, completion:@escaping FileResultCompletion) -> RequestCanceller? {

        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.getFile(fileId: fileId)) { result in
            let (fileInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let file = ResultHandler.dictToFile(dict: fileInfo)
                completion(file, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc open func find(_ completion:@escaping FilesResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.findFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc open func delete(_ fileIds: [String], completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(false, HError.init(code: 604))
            return nil
        }

        queryArgs["id__in"] = fileIds
        let request = FileProvider.request(.deleteFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc open func upload(filename: String, localPath: String, categoryName: String? = nil, progressBlock: @escaping ProgressBlock, completion:@escaping FileResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.upload(parameters: ["filename": filename, "category_name": categoryName as Any])) { result in
            let (fileInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                guard fileInfo != nil, fileInfo?.getString("policy") != nil, fileInfo?.getString("authorization") != nil, fileInfo?.getString("file_link") != nil  else {
                    completion(nil, HError.init(code: 500))
                    return
                }

                let path = fileInfo?.getString("file_link")
                let id = fileInfo?.getString("id")
                let parameters: [String: String] = ["policy": (fileInfo?.getString("policy"))!, "authorization": (fileInfo?.getString("authorization"))!]
                FileProvider.request(.UPUpload(url: (fileInfo?.getString("upload_url"))!, localPath: localPath, parameters: parameters), callbackQueue: nil, progress: { progress in
                    progressBlock(progress.progressObject)
                }, completion: { result in
                    let (fileInfo, error) = ResultHandler.handleResult(result: result)
                    if error != nil {
                        completion(nil, error)
                    } else {
                        var file: File!
                        if let fileInfo = fileInfo {
                            file = File()
                            file.Id = id
                            file.createdAt = fileInfo.getDouble("time")
                            file.mimeType = fileInfo.getString("mimetype")
                            file.name = filename
                            file.size = fileInfo.getInt("file_size")
                            file.cdnPath = path
                        }
                        completion(file, nil)
                    }
                })
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc open func getCategoryList(_ completion:@escaping FileCategorysResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.findCategories(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categorysInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToFileCategorys(dict: categorysInfo)
                completion(categorys, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    // MARK: FileCategory

    @discardableResult
    @objc open func getCategory(Id: String, completion:@escaping FileCategoryResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.getCategory(categoryId: Id)) { result in
            let (categoryInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let category = ResultHandler.dictToFileCategory(dict: categoryInfo)
                completion(category, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc open func getFileList(categoryId: String, completion:@escaping FilesResultCompletion) -> RequestCanceller? {
        guard User.currentUser?.hadLogin ?? false else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["category_id"] = categoryId
        let request = FileProvider.request(.findFilesInCategory(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
