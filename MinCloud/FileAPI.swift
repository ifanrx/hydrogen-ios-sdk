//
//  FileAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum FileAPI {
    case upload(parameters: [String: Any]) // 上传文件
    case getFile(fileId: String)
    case findFiles(parameters: [String: Any])
    case findCategories(parameters: [String: Any])
    case deleteFile(fileId: String)
    case deleteFiles(parameters: [String: Any])
    case getCategory(categoryId: String)
    case UPUpload(url: String, formDatas: [MultipartFormData])
    case findFilesInCategory(parameters: [String: Any])
    case genVideoSnapshot(parameters: [String: Any])
    case videoConcat(parameters: [String: Any])
    case videoClip(parameters: [String: Any])
    case videoMeta(parameters: [String: Any])
    case videoAudioMeta(parameters: [String: Any])
}

extension FileAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .UPUpload(let url, _):
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
        case .genVideoSnapshot:
            return Config.File.videoSnapshot
        case .videoConcat:
            return Config.File.m3u8Concat
        case .videoClip:
            return Config.File.m3u8Clip
        case .videoMeta:
            return Config.File.m3u8Meta
        case .videoAudioMeta:
            return Config.File.videoAudioMeta
        }
    }

    var method: Moya.Method {
        switch self {
        case .upload, .UPUpload, .genVideoSnapshot, .videoConcat, .videoClip, .videoMeta, .videoAudioMeta:
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
        case .findFiles(let parameters), .findCategories(let parameters), .findFilesInCategory(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .UPUpload(_, let formDatas):
            return .uploadMultipart(formDatas)
        case .getCategory, .getFile:
            return .requestPlain
        case .videoConcat(let parameters), .videoClip(let parameters), .videoMeta(let parameters), .videoAudioMeta(let parameters), .genVideoSnapshot(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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
