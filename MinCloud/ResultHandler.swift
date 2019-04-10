//
//  ResultHandler.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

class ResultHandler {
    static func handleResult(clearer: RecordClearer? = nil,
                             result: Result<Moya.Response, MoyaError>) -> ([String: Any]?, Error?) {
        if let clearer = clearer {
            clearer.clear()
        }
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                Storage.shared.reset()
            }

            if response.statusCode >= 200 && response.statusCode <= 299 {
                if let data = try? response.mapJSON(), let dict = data as? [String: Any] {
                    printDebugInfo(dict)
                    return (dict, nil)
                }
                return (["code": response.statusCode], nil)
            } else if let data = try? response.mapJSON(), let dict = data as? [String: Any] { // 内部定义网络错误
                let errorMsg = dict.getString("error_msg")
                let error = HError(code: response.statusCode, description: errorMsg)
                printErrorInfo(error)
                return (nil, error)
            } else if let message = try? response.mapString() {
                let error = HError(code: response.statusCode, description: message)
                printErrorInfo(error)
                return (nil, error)
            } else {
                let error = HError(code: response.statusCode, description: nil)
                printErrorInfo(error)
                return (nil, error)
            }
        case .failure(let error):
            printErrorInfo(error)
            return (nil, error)
        }
    }
}

// MARK: UserResult

extension ResultHandler {
    static func dictToLoginUser(dict: [String: Any]?) -> CurrentUser? {
        if let dict = dict {
            let Id = dict.getInt("id")

            Storage.shared.userId = Id
            Storage.shared.token = dict.getString("token")
            Storage.shared.expiresIn = dict.getDouble("expires_in") + Date().timeIntervalSince1970

            let user = ResultHandler.dictToCurrentUser(dict: dict)
            return user
        }
        return nil
    }

    static func dictToCurrentUser(dict: [String: Any]?) -> CurrentUser? {
        if let dict = dict {
            let Id = dict.getInt("id")

            let user = CurrentUser(Id: Id)
            user.email = dict.getString("_email")
            user.avatar = dict.getString("avatar")
            user.isAuthorized = dict.getBool("is_authorized")
            user.username = dict.getString("_username")
            user.nickname = dict.getString("nickname")
            user.gender = dict.getInt("gender")
            user.country = dict.getString("country")
            user.province = dict.getString("province")
            user.city = dict.getString("city")
            user.language = dict.getString("language")
            user.unionid = dict.getString("unionid")
            user.emailVerified = dict.getBool("_email_verified")
            user.provider = dict.getDict("_provider") as? [String: Any]
            if let createdBy = dict.getDict("created_by") as? [String: Any] {
                user.createdBy = createdBy
            } else {
                user.createdById = dict.getInt("created_by")
            }
            user.createdAt = dict.getDouble("created_at")
            user.updatedAt = dict.getDouble("created_at")
            user.userInfo = dict
            return user
        }
        return nil
    }

    static func dictToUser(dict: [String: Any]?) -> User? {
        if let dict = dict {
            let Id = dict.getInt("id")

            let user = User(Id: Id)
            user.email = dict.getString("_email")
            user.avatar = dict.getString("avatar")
            user.isAuthorized = dict.getBool("is_authorized")
            user.username = dict.getString("_username")
            user.nickname = dict.getString("nickname")
            user.gender = dict.getInt("gender")
            user.country = dict.getString("country")
            user.province = dict.getString("province")
            user.city = dict.getString("city")
            user.language = dict.getString("language")
            user.unionid = dict.getString("unionid")
            user.emailVerified = dict.getBool("_email_verified")
            user.provider = dict.getDict("_provider") as? [String: Any]
            if let createdBy = dict.getDict("created_by") as? [String: Any] {
                user.createdBy = createdBy
            } else {
                user.createdById = dict.getInt("created_by")
            }
            user.createdAt = dict.getDouble("created_at")
            user.updatedAt = dict.getDouble("created_at")
            user.userInfo = dict
            return user
        }
        return nil
    }

    static func dictToUserListResult(dict: [String: Any]?) -> UserListResult? {
        var listResults: UserListResult!
        if let dict = dict {
            listResults = UserListResult()
            if let meta = dict["meta"] as? [String: Any] {

                listResults.limit = meta.getInt("limit")
                listResults.offset = meta.getInt("offset")
                listResults.totalCount = meta.getInt("total_count")
            }

            var users: [User]!
            if let objects = dict["objects"] as? [[String: Any]] {
                users = []
                for userDict in objects {
                    let user = ResultHandler.dictToUser(dict: userDict)
                    if let user = user {
                        users.append(user)
                    }
                }
            }
            listResults.users = users
        }
        return listResults
    }
}

// MARK: TableResult

extension ResultHandler {
    static func dictToRecord(identify: String, dict: [String: Any]?) -> TableRecord? {
        if let dict = dict {
            let recordId = dict.getString("_id")
            let record = TableRecord(tableIdentify: identify, Id: recordId)
            if let createdBy = dict.getDict("created_by") as? [String: Any] {
                record.createdBy = createdBy
            } else {
                record.createdById = dict.getInt("created_by")
            }
            record.createdAt = dict.getDouble("created_at")
            record.updatedAt = dict.getDouble("updated_at")
            record.acl = dict.getString("acl")
            record.recordInfo = dict
            return record
        }
        return nil
    }

    static func dictToRecords(identify: String, dict: [String: Any]?) -> [TableRecord]? {
        var records: [TableRecord]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            records = []
            for fileDict in objects {
                let recordId = fileDict.getString("_id")
                let record = TableRecord(tableIdentify: identify, Id: recordId)
                if let createdBy = dict.getDict("created_by") as? [String: Any] {
                    record.createdBy = createdBy
                } else {
                    record.createdById = dict.getInt("created_by")
                }
                record.createdAt = dict.getDouble("created_at")
                record.updatedAt = dict.getDouble("updated_at")
                record.acl = dict.getString("acl")
                record.recordInfo = fileDict
                records.append(record)
            }
        }
        return records
    }
}

// MARK: FileResult

extension ResultHandler {
    static func dictToFile(dict: [String: Any]?) -> File? {
        var file: File!
        if let fileDict = dict {
            file = File()
            file.Id = fileDict.getString("id")
            file.name = fileDict.getString("name")
            file.mimeType = fileDict.getString("mime_type")
            file.size = fileDict.getInt("size")
            file.cdnPath = fileDict.getString("path")
            file.createdAt = fileDict.getDouble("created_at")
            let category = FileCategory()
            category.categoryId = fileDict.getDict("category")?.getString("id")
            category.name = fileDict.getDict("category")?.getString("name")
            file.category = category
        }
        return file
    }

    static func dictToFiles(dict: [String: Any]?) -> [File]? {
        var files: [File]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            files = []
            for fileDict in objects {
                let file = File()
                file.Id = fileDict.getString("id")
                file.name = fileDict.getString("name")
                file.mimeType = fileDict.getString("mime_type")
                file.size = fileDict.getInt("size")
                file.cdnPath = fileDict.getString("path")
                file.createdAt = fileDict.getDouble("created_at")
                let category = FileCategory()
                category.categoryId = fileDict.getDict("category")?.getString("id")
                category.name = fileDict.getDict("category")?.getString("name")
                file.category = category
                files.append(file)
            }
        }
        return files
    }

    static func dictToFileCategory(dict: [String: Any]?) -> FileCategory? {
        var category: FileCategory!
        if let categoryDict = dict {
            category = FileCategory()
            category.categoryId = categoryDict.getString("id")
            category.name = categoryDict.getString("name")
            category.files = categoryDict.getInt("files")
        }
        return category
    }

    static func dictToFileCategorys(dict: [String: Any]?) -> [FileCategory]? {
        var categorys: [FileCategory]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            categorys = []
            for categoryDict in objects {
                let category = FileCategory()
                category.categoryId = categoryDict.getString("id")
                category.name = categoryDict.getString("name")
                category.files = categoryDict.getInt("files")
                categorys.append(category)
            }
        }
        return categorys
    }
}

// MARK: ContentResult

extension ResultHandler {
    static func dictToContent(dict: [String: Any]?) -> Content? {
        var content: Content!
        if let contentDict = dict {
            content = Content()
            content.contentId = contentDict.getInt("id")
            content.title = contentDict.getString("title")
            content.cover = contentDict.getString("cover")
            content.desc = contentDict.getString("description")
            content.categories = contentDict.getArray("categories", type: Int.self)
            content.groupId = contentDict.getInt("group_id")
            content.content = contentDict.getString("content")
            if let createdBy = contentDict.getDict("created_by") as? [String: Any] {
                content.createdBy = createdBy
            } else {
                content.createdById = contentDict.getInt("created_by")
            }
            content.createdAt = contentDict.getDouble("created_at")
            content.updatedAt = contentDict.getDouble("created_at")
        }
        return content
    }

    static func dictToContents(dict: [String: Any]?) -> [Content]? {
        var contents: [Content]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            contents = []
            for contentDict in objects {
                let content = Content()
                content.contentId = contentDict.getInt("id")
                content.title = contentDict.getString("title")
                content.cover = contentDict.getString("cover")
                content.desc = contentDict.getString("description")
                content.categories = contentDict.getArray("categories", type: Int.self)
                content.groupId = contentDict.getInt("group_id")
                content.content = contentDict.getString("content")
                if let createdBy = dict.getDict("created_by") as? [String: Any] {
                    content.createdBy = createdBy
                } else {
                    content.createdById = dict.getInt("created_by")
                }
                content.createdAt = dict.getDouble("created_at")
                content.updatedAt = dict.getDouble("created_at")
                contents.append(content)
            }
        }
        return contents
    }

    static func dictToContentCategory(dict: [String: Any]?) -> ContentCategory? {
        var category: ContentCategory!
        if let categoryDict = dict {
            category = ContentCategory()
            category.categoryId = categoryDict.getString("id")
            category.name = categoryDict.getString("name")
            category.haveChildren = categoryDict.getBool("have_children")
            let children = categoryDict.getArray("children", type: [String: Any].self)
            var subCategorys: [ContentCategory] = []
            for subDict in children {
                let subCategory = ContentCategory()
                subCategory.categoryId = subDict.getString("id")
                subCategory.name = subDict.getString("name")
                subCategory.haveChildren = subDict.getBool("have_children")
                subCategorys.append(subCategory)
            }
            category.children = subCategorys
        }
        return category
    }

    static func dictToContentCategorys(dict: [String: Any]?) -> [ContentCategory]? {
        var categorys: [ContentCategory]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            categorys = []
            for categoryDict in objects {
                let category = ContentCategory()
                category.categoryId = categoryDict.getString("id")
                category.name = categoryDict.getString("name")
                category.haveChildren = categoryDict.getBool("have_children")
                let children = categoryDict.getArray("children", type: [String: Any].self)
                var subCategorys: [ContentCategory] = []
                for subDict in children {
                    let subCategory = ContentCategory()
                    subCategory.categoryId = subDict.getString("id")
                    subCategory.name = subDict.getString("name")
                    subCategory.haveChildren = subDict.getBool("have_children")
                    subCategorys.append(subCategory)
                }
                category.children = subCategorys
                categorys.append(category)
            }
        }
        return categorys
    }
}
