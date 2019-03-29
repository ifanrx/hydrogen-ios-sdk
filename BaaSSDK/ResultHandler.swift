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
    static func handleResult(clearer: RecordClearer? = nil, result: Result<Moya.Response, MoyaError>) -> ([String: Any]?, Error?) {
        if let clearer = clearer {
            clearer.clear()
        }
        switch result {
        case .success(let response):
            if response.statusCode >= 200 && response.statusCode <= 299 {
                if let data = try? response.mapJSON(), let dict = data as? [String: Any] {
                    printDebugInfo(dict)
                    return (dict, nil)
                }
                return (nil, nil)
            } else if let data = try? response.mapJSON(), let dict = data as? [String: Any] { // 内部定义网络错误
                let errorMsg = dict.getString("error_msg")
                let error = HError(code: response.statusCode, errorDescription: errorMsg)
                printErrorInfo(error)
                return (nil, error)
            } else if let message = try? response.mapString() {
                let error = HError(code: response.statusCode, errorDescription: message)
                printErrorInfo(error)
                return (nil, error)
            } else {
                let error = HError(code: response.statusCode, errorDescription: nil)
                printErrorInfo(error)
                return (nil, error)
            }
        case .failure(let error):
            printErrorInfo(error)
            return (nil, error)
        }
    }

    static func dictToUser(dict: [String: Any]?) -> User? {
        if let dict = dict {
            let user = User()
            user.userId = dict.getInt("user_id")
            user.token = dict.getString("token")
            user.expiresIn = dict.getDouble("expires_in")
            user.email = dict.getString("_email")
            user.avatar = dict.getString("avatar")
            user.isAuthorized = dict.getBool("is_authorized")
            user.username = dict.getString("_username")
            user.userInfo = dict
            User.currentUser = user
            return user
        }
        return nil
    }

    static func dictToUsers(dict: [String: Any]?) -> [User]? {
        var users: [User]!
        if let dict = dict, let objects = dict["objects"] as? [[String: Any]] {
            users = []
            for userDict in objects {
                let user = User()
                user.userId = userDict.getInt("user_id")
                user.token = userDict.getString("token")
                user.expiresIn = userDict.getDouble("expires_in")
                user.email = userDict.getString("_email")
                user.avatar = userDict.getString("avatar")
                user.isAuthorized = userDict.getBool("is_authorized")
                user.username = userDict.getString("_username")
                user.userInfo = userDict
                users.append(user)
            }
        }
        return users
    }

    static func dictToRecord(identify: String, dict: [String: Any]?) -> TableRecord? {
        if let dict = dict {
            let recordId = dict.getString("_id")
            let record = TableRecord(tableIdentify: identify, recordId: recordId)
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
                let record = TableRecord(tableIdentify: identify, recordId: recordId)
                record.recordInfo = fileDict
                records.append(record)
            }
        }
        return records
    }

    static func dictToFile(dict: [String: Any]?) -> File? {
        var file: File!
        if let fileDict = dict {
            file = File()
            file.fileId = fileDict.getString("id")
            file.name = fileDict.getString("name")
            file.mimeType = fileDict.getString("mime_type")
            file.size = fileDict.getInt("size")
            file.cdnPath = fileDict.getString("path")
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
                file.fileId = fileDict.getString("id")
                file.name = fileDict.getString("name")
                file.mimeType = fileDict.getString("mime_type")
                file.size = fileDict.getInt("size")
                file.cdnPath = fileDict.getString("path")
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
