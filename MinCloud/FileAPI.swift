//
//  FileAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

let FileProvider = MoyaProvider<FileAPI>()

enum FileAPI {
    case upload(parameters: [String: Any]) // 上传文件
    case getFile(fileId: String)
    case findFiles(parameters: [String: Any])
    case findCategories(parameters: [String: Any])
    case deleteFile(fileId: String)
    case deleteFiles(parameters: [String: Any])
    case getCategory(categoryId: String)
    case UPUpload(url: String, localPath: String, parameters: [String: String])
    case findFilesInCategory(parameters: [String: Any])
}

extension FileAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .UPUpload(let url, _, _):
            return URL(string: url)!
        default:
            return URL(string: Config.baseURL)!
        }

    }

    var path: String {
        switch self {
        case .upload:
            return Config.File.upload
        case .getFile(let fileId):
            return Config.File.fileDetail(fileId: fileId)
        case .findFiles, .findFilesInCategory:
            return Config.File.fileList
        case .deleteFile(let fileId):
            return Config.File.deleteFile(fileId: fileId)
        case .deleteFiles:
            return Config.File.deleteFiles
        case .getCategory(let categoryId):
            return Config.File.categoryDetail(categoryId: categoryId)
        case .UPUpload:
            return ""
        case .findCategories:
            return Config.File.fileCategoryList
        }
    }

    var method: Moya.Method {
        switch self {
        case .upload, .UPUpload:
            return .post
        case .getFile, .findFiles, .getCategory, .findCategories, .findFilesInCategory:
            return .get
        case .deleteFiles, .deleteFile:
            return .delete
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .deleteFile:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        case .upload(let parameters), .deleteFiles(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getFile, .getCategory:
            return .requestPlain
        case .findFiles(let parameters), .findCategories(let parameters), .findFilesInCategory(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .UPUpload(_, let localPath, let parameters):
            let url = URL(fileURLWithPath: localPath)
            var formDatas: [MultipartFormData] = []
            var formData = MultipartFormData(provider: .file(url), name: "file")
            formDatas.append(formData)
            for (key, value) in parameters {
                formData = MultipartFormData(provider: .data(value.data(using: .utf8)!), name: key)
                formDatas.append(formData)
            }
            return .uploadMultipart(formDatas)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .UPUpload:
            return ["Content-Type": "multipart/form-data"]
        default:
            return Config.HTTPHeaders
        }
    }
}
