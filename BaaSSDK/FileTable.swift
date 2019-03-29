//
//  FileTable.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

public class FileTable: BaseQuery {

    // MARK: File

    public func get(fileId: String, completion:@escaping FileResultCompletion) {
        FileProvider.request(.getFile(fileId: fileId)) { result in
            let (fileInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let file = ResultHandler.dictToFile(dict: fileInfo)
                completion(file, nil)
            }
        }
    }

    public func find(_ completion:@escaping FilesResultCompletion) {
        FileProvider.request(.findFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
    }

    public func delete(fileIds: [String], completion:@escaping BOOLResultCompletion) {
        queryArgs["id__in"] = fileIds
        FileProvider.request(.deleteFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    public func upload(filename: String, localPath: String, categoryName: String, progressBlock: @escaping ProgressBlock, completion:@escaping FileResultCompletion) {
        FileProvider.request(.upload(parameters: ["filename": filename, "category_name": categoryName])) { result in
            let (fileInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let path = fileInfo?.getString("file_link")
                let id = fileInfo?.getString("id")
                let parameters: [String: String] = ["policy": (fileInfo?.getString("policy")!)!, "authorization": (fileInfo?.getString("authorization")!)!]
                FileProvider.request(.UPUpload(url: (fileInfo?.getString("upload_url")!)!, localPath: localPath, parameters: parameters), callbackQueue: nil, progress: { progress in
                    print("progress = \(progress)")
                    progressBlock(progress.progressObject)
                }, completion: { result in
                    let (fileInfo, error) = ResultHandler.handleResult(result: result)
                    if error != nil {
                        completion(nil, error)
                    } else {
                        let file = File()
                        file.fileId = id
                        file.createdAt = fileInfo?.getDouble("time")
                        file.mimeType = fileInfo?.getString("mimetype")
                        file.name = filename
                        file.size = fileInfo?.getInt("file_size")
                        file.cdnPath = path
                        completion(file, nil)
                    }
                })
            }
        }
    }

    public func findCategoryList(_ completion:@escaping FileCategorysResultCompletion) {
        FileProvider.request(.findCategories(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categorysInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToFileCategorys(dict: categorysInfo)
                completion(categorys, nil)
            }
        }
    }

    // MARK: FileCategory

    public func getCategory(Id: String, completion:@escaping FileCategoryResultCompletion) {
        FileProvider.request(.getCategory(categoryId: Id)) { result in
            let (categoryInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let category = ResultHandler.dictToFileCategory(dict: categoryInfo)
                completion(category, nil)
            }
        }
    }

    public func getFileList(categoryId: String, completion:@escaping FilesResultCompletion) {
        queryArgs["category_id"] = categoryId
        FileProvider.request(.findFilesInCategory(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
    }
}
