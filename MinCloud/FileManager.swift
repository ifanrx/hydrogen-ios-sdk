//
//  FileTable.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BaaSFileManager)
open class FileManager: NSObject {

    // MARK: File

    /// 获取文件详情
    ///
    /// - Parameters:
    ///   - fileId: 文件 Id
    ///   - select: 筛选条件，只返回指定的字段。可选
    ///   - expand: 扩展条件。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func get(_ fileId: String, select: [String]? = nil, expand: [String]? = nil, completion:@escaping FileResultCompletion) -> RequestCanceller? {

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = FileProvider.request(.getFile(fileId: fileId, parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (file: File?, error: NSError?) in
                completion(file, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询文件列表
    /// - Parameter:
    ///   - query: 查询条件，满足条件的文件将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func find(query: Query? = nil, completion:@escaping FileListResultCompletion) -> RequestCanceller? {

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = FileProvider.request(.findFiles(parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: FileList?, error: NSError?) in
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 删除多个文件
    ///
    /// - Parameters:
    ///   - fileIds: 文件 Id 数组
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func delete(_ fileIds: [String], completion:@escaping BOOLResultCompletion) -> RequestCanceller? {

        let request = FileProvider.request(.deleteFiles(parameters: ["id__in": fileIds])) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 上传文件
    ///
    /// - Parameters:
    ///   - filename: 文件名称
    ///   - localPath: 文件本地路径
    ///   - categoryName: 文件分类
    ///   - progressBlock: progressBlock
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func upload(filename: String, localPath: String, categoryName: String? = nil, progressBlock: @escaping ProgressBlock, completion:@escaping FileResultCompletion) -> RequestCanceller? {

        let canceller = RequestCanceller()

        let request = FileProvider.request(.upload(parameters: ["filename": filename, "category_name": categoryName as Any])) { result in

            ResultHandler.parse(result, handler: { (resultInfo: MappableDictionary?, error: NSError?) in
                if error != nil {
                    completion(nil, error)
                } else {
                    let fileInfo = resultInfo?.value
                    guard fileInfo != nil, fileInfo?.getString("policy") != nil, fileInfo?.getString("authorization") != nil, fileInfo?.getString("file_link") != nil  else {
                        completion(nil, HError.init(code: 500) as NSError)
                        return
                    }

                    let path = fileInfo?.getString("file_link")
                    let id = fileInfo?.getString("id")
                    let parameters: [String: String] = ["policy": (fileInfo?.getString("policy"))!, "authorization": (fileInfo?.getString("authorization"))!]
                    let uploadRequest = FileProvider.request(.UPUpload(url: (fileInfo?.getString("upload_url"))!, localPath: localPath, parameters: parameters), callbackQueue: nil, progress: { progress in
                        progressBlock(progress.progressObject)
                    }, completion: { result in
                        ResultHandler.parse(result, handler: { (file: File?, error: NSError?) in
                            file?.Id = id
                            file?.name = filename
                            file?.cdnPath = path
                            completion(file, error)
                        })
                    })
                    canceller.cancellable = uploadRequest
                }
            })

        }
        canceller.cancellable = request
        return canceller
    }

    /// 获取文件分类
    /// - Parameter:
    ///   - query: 查询条件，满足条件的分类将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func getCategoryList(query: Query? = nil, completion:@escaping FileCategoryListResultCompletion) -> RequestCanceller? {

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = FileProvider.request(.findCategories(parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: FileCategoryList?, error: NSError?) in
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // MARK: FileCategory

    /// 获取分类详情
    ///
    /// - Parameters:
    ///   - Id: 分类 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func getCategory(_ Id: String, completion:@escaping FileCategoryResultCompletion) -> RequestCanceller? {

        let request = FileProvider.request(.getCategory(categoryId: Id)) { result in
            ResultHandler.parse(result, handler: { (category: FileCategory?, error: NSError?) in
                completion(category, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 指定分类下的文件列表
    ///
    /// - Parameters:
    ///   - categoryId: 分类 Id
    ///   - query: 查询条件，满足条件的文件将被返回。可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func find(categoryId: String, query: Query? = nil, completion: @escaping FileListResultCompletion) -> RequestCanceller? {

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs["category_id"] = categoryId
        let request = FileProvider.request(.findFilesInCategory(parameters: queryArgs)) { result in
            ResultHandler.parse(result, handler: { (listResult: FileList?, error: NSError?) in
                completion(listResult, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 从 M3U8，MP4 或其他格式视频中获取一张截图。
    ///
    /// - Parameters:
    ///   - parameters: 参数，可设置的字段如下
    ///     - source: 视频文件的 id；必填
    ///     - save_as: 截图时间格式，格式：HH:MM:SS；必填
    ///     - category_id: 文件所属类别 ID；选填
    ///     - random_file_link: 是否使用随机字符串作为文件的下载地址，不随机可能会覆盖之前的文件；可选，默认为 true
    ///     - size: 截图尺寸，格式为 宽x高，默认是视频尺寸；可选
    ///     - format: 截图格式，可选值为 jpg，png, webp, 默认根据 save_as 的后缀生成；可选
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public static func genVideoSnapshot(_ parameters: [String: Any], completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = FileProvider.request(.genVideoSnapshot(parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (user: MappableDictionary?, error: NSError?) in
                completion(user?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)

    }

    /// 多个 M3U8 拼接成一个。
    ///
    /// - Parameters:
    ///   - parameters: 参数，可设置的字段如下
    ///     - m3u8s: 数组，包含视频文件的 id， 拼接 M3U8 的存储地址，按提交的顺序进行拼接；必填
    ///     - save_as: 截图时间格式，格式：HH:MM:SS；必填
    ///     - category_id: 文件所属类别 ID；选填
    ///     - random_file_link: 是否使用随机字符串作为文件的下载地址，不随机可能会覆盖之前的文件；可选，默认为 true
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public static func videoConcat(_ parameters: [String: Any], completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = FileProvider.request(.videoConcat(parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (user: MappableDictionary?, error: NSError?) in
                completion(user?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)

    }

    /// 从 M3U8 中剪辑一段，或去掉一段保留前后两段。
    ///
    /// - Parameters:
    ///   - parameters: 参数，可设置的字段如下
    ///     - m3u8: 视频文件的 id；必填
    ///     - save_as: 截图时间格式，格式：HH:MM:SS；必填
    ///     - category_id: 文件所属类别 ID；选填
    ///     - random_file_link: 是否使用随机字符串作为文件的下载地址，不随机可能会覆盖之前的文件；可选，默认为 true
    ///     - include: 包含某段内容的开始结束时间，单位是秒。当 index 为 false 时，为开始结束分片序号；可选，数组类型
    ///     - exclude: 不包含某段内容的开始结束时间，单位是秒。当 index 为 false 时，为开始结束分片序号；可选，数组类型
    ///     说明: index include 或者 exclude 中的值是否为 ts 分片序号，默认为 false；可选，数组类型
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public static func videoClip(_ parameters: [String: Any], completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = FileProvider.request(.videoClip(parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (user: MappableDictionary?, error: NSError?) in
                completion(user?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)

    }

    /// 获取 M3U8 时长和分片信息。
    ///
    /// - Parameters:
    ///   - fileId: 数组，包含视频文件的 id
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public static func videoMeta(_ fileId: String, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = FileProvider.request(.videoMeta(parameters: ["m3u8": fileId])) { result in
            ResultHandler.parse(result, handler: { (user: MappableDictionary?, error: NSError?) in
                completion(user?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)

    }

    /// 获取音视频的元信息。
    ///
    /// - Parameters:
    ///     - fileId: 文件的 id
    ///   - completion: 回调结果
    /// - Returns:
    @discardableResult
    @objc public static func videoAudioMeta(_ fileId: String, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = FileProvider.request(.videoAudioMeta(parameters: ["source": fileId])) { result in
            ResultHandler.parse(result, handler: { (user: MappableDictionary?, error: NSError?) in
                completion(user?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)

    }
}
