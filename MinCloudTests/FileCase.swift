//
//  FileCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

fileprivate var file_list_option = false

class FileCase: MinCloudCase {

    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_upload() {
        let dict = SampleData.File.file_upload.toDictionary()
        let filePath = "/Users/quanhua/Library/Developer/CoreSimulator/Devices/E2C75831-5E87-4D86-A4C8-24B8C14619AF/data/Containers/Bundle/Application/6E2F629A-07DE-41B4-8C76-A12A6EEDAF08/Demo_Swift.app/1.png"
        FileManager.upload(filename: "test", localPath: filePath, categoryName: "category1",
                           progressBlock: { progress in print("\(String(describing: progress?.fractionCompleted))") },
                           completion: { (file, error) in
                            XCTAssertNotNil(file)
                            XCTAssertEqual(file?.Id, dict?.getString("id"))
                            XCTAssertEqual(file?.cdnPath, dict?.getString("file_link"))
                            
        })
    }
    
    func test_get_file() {
        let dict = SampleData.File.get_file.toDictionary()
        FileManager.get("5ca489d3d625d846af4bf453") { (file, error) in
            ModelCase.fileEqual(file: file!, dict: dict!)
        }
    }
    
    func test_file_list_option() {
        file_list_option = true
        let dict = SampleData.File.file_list_option.toDictionary()
        let whereAgrs = Where.compare(key: "name", operator: .equalTo, value: "3.jpg")
        let query = Query()
        query.setWhere(whereAgrs)
        query.limit(10)
        query.offset(0)
        query.orderBy(["size"])
        FileManager.find(query: query, completion: {fileList, error in
            ModelCase.fileListEqual(list: fileList!, dict: dict!)
            file_list_option = false
        })
    }
    
    func test_file_list() {
        let dict = SampleData.File.file_list.toDictionary()
        FileManager.find(completion: {fileList, error in
            ModelCase.fileListEqual(list: fileList!, dict: dict!)
        })
    }
    
    func test_file_delete() {
        let file = File()
        file.Id = "5cab1a941feb8f06a883800c"
        file.delete({ success, error in
            XCTAssertTrue(true)
        })
    }
    
    func test_file_delete_id_invalid() {
        let file = File()
        file.delete({ success, error in
            XCTAssertFalse(success)
            XCTAssertEqual(error?.code, 400)
        })
    }

    
    func test_delete_many_files() {
        FileManager.delete(["5cab1a981feb8f06a8838011", "5cab1a961feb8f074a68a01a"]) { success, error in
            XCTAssertTrue(true)
        }
    }
    
    func test_get_category() {
        FileManager.getCategory("5ca489bb8c374f5039a8062b") {category, error in
            XCTAssertNotNil(category)
        }
    }
    
    func get_file_list_in_category() {
        let dict = SampleData.File.file_list_in_category.toDictionary()
        FileManager.find(categoryId: "5ca489bb8c374f5039a8062b") { (fileList, error) in
            ModelCase.fileListEqual(list: fileList!, dict: dict!)
        }
    }
    
    func test_get_category_list() {
        let dict = SampleData.File.get_category_list.toDictionary()
        let query = Query()
        query.limit(10)
        query.offset(0)
        FileManager.getCategoryList(query: query, completion: {categoryList, error in
            ModelCase.fileCategoryListEqual(list: categoryList!, dict: dict!)
        })
    }
    
    func test_genVideoSnapshot() {
        let params: [String: Any] = ["source": "123", "save_as": "HH:MM:SS", "category_id": "123", "random_file_link": true, "size": 1024, "format": "jpg"]
        FileManager.genVideoSnapshot(params) { (result, error) in
            
        }
    }
    
    func test_videoConcat() {
        let params: [String: Any] = ["m3u8s": ["123", "345"], "save_as": "HH:MM:SS", "category_id": "123", "random_file_link": true]
        FileManager.videoConcat(params) { (result, error) in
            
        }
    }
    
    func test_videoClip() {
        let params: [String: Any] = ["m3u8": "123", "save_as": "HH:MM:SS", "category_id": "123", "random_file_link": true, "include": 1, "exclude": 10]
        FileManager.videoClip(params) { (result, error) in
            
        }
    }
    
    func test_videoMeta() {
        FileManager.videoMeta("123") { (result, error) in
            
        }
    }
    
    func test_videoAudioMeta() {
        FileManager.videoAudioMeta("123") { (result, error) in
            
        }
    }
}

extension FileAPI {
    var testSampleData: Data {
        switch self {
        case .upload:
            return SampleData.File.file_upload
        case .UPUpload:
            return SampleData.File.file_upload_UP
        case .getFile:
            return SampleData.File.get_file
        case .getCategory:
            return SampleData.File.get_category
        case .findFiles:
            if file_list_option {
                return SampleData.File.file_list_option
            }
            return SampleData.File.file_list
        case .findCategories:
            return SampleData.File.get_category_list
        case .findFilesInCategory:
            return SampleData.File.file_list_in_category
        default:
            return Data()
        }
    }
}

class FilePlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let api = target as? FileAPI else {
            XCTFail("发送 AuthAPI 错误")
            return request
        }
        
        // 测试 path
        test_path(target: api)
        
        // 测试 method
        test_method(target: api)
        
        // 测试参数
        test_params(target: api)
        
        
        return request
    }
    
    private func test_path(target: FileAPI) {
        let path = target.path
        switch target {
        case .upload:
            XCTAssertEqual(path, Path.File.upload)
        case .getFile(let fileId):
            XCTAssertEqual(path, Path.File.fileDetail(fileId: fileId))
        case .findFiles, .findFilesInCategory:
            XCTAssertEqual(path, Path.File.fileList)
        case .deleteFile(let fileId):
            XCTAssertEqual(path, Path.File.deleteFile(fileId: fileId))
        case .deleteFiles:
            XCTAssertEqual(path, Path.File.deleteFiles)
        case .getCategory(let categoryId):
            XCTAssertEqual(path, Path.File.categoryDetail(categoryId: categoryId))
        case .UPUpload:
            XCTAssertEqual(path, "")
        case .findCategories:
            XCTAssertEqual(path, Path.File.fileCategoryList)
        case .genVideoSnapshot:
            XCTAssertEqual(path, Path.File.videoSnapshot)
        case .videoConcat:
            XCTAssertEqual(path, Path.File.m3u8Concat)
        case .videoClip:
            XCTAssertEqual(path, Path.File.m3u8Clip)
        case .videoMeta:
            XCTAssertEqual(path, Path.File.m3u8Meta)
        case .videoAudioMeta:
            XCTAssertEqual(path, Path.File.videoAudioMeta)
        }
    }
    
    private func test_method(target: FileAPI) {
        let method = target.method
        switch target {
        case .upload, .UPUpload, .genVideoSnapshot, .videoConcat, .videoClip, .videoMeta, .videoAudioMeta:
            XCTAssertEqual(method, Moya.Method.post)
        case .getFile, .findFiles, .getCategory, .findCategories, .findFilesInCategory:
            XCTAssertEqual(method, Moya.Method.get)
        case .deleteFiles, .deleteFile:
            XCTAssertEqual(method, Moya.Method.delete)
        }
    }
    
    private func test_params(target: FileAPI) {
        switch target {
        case .deleteFile:
            break
        case .upload(let parameters):
            XCTAssertTrue(parameters.keys.contains("filename"))
            XCTAssertTrue(parameters.keys.contains("category_name"))
        case .UPUpload(_ , let localPath, let parameters):
            XCTAssertTrue(parameters.keys.contains("policy"))
            XCTAssertTrue(parameters.keys.contains("authorization"))
            XCTAssertEqual("/Users/quanhua/Library/Developer/CoreSimulator/Devices/E2C75831-5E87-4D86-A4C8-24B8C14619AF/data/Containers/Bundle/Application/6E2F629A-07DE-41B4-8C76-A12A6EEDAF08/Demo_Swift.app/1.png", localPath)
        case .getFile:
            break
        case .findFiles(let parameters):
            if file_list_option {
                XCTAssertTrue(parameters.keys.contains("where"))
                XCTAssertTrue(parameters.keys.contains("limit"))
                XCTAssertTrue(parameters.keys.contains("offset"))
                XCTAssertTrue(parameters.keys.contains("order_by"))
            }
        case .findCategories(let parameters):
            XCTAssertTrue(parameters.keys.contains("limit"))
            XCTAssertTrue(parameters.keys.contains("offset"))
        case .getCategory:
            break
        case .deleteFiles(let parameters):
            XCTAssertTrue(parameters.keys.contains("id__in"))
        case .findFilesInCategory(let parameters):
            XCTAssertTrue(parameters.keys.contains("category_id"))
        case .genVideoSnapshot(let parameters):
            XCTAssertTrue(parameters.keys.contains("source"))
            XCTAssertTrue(parameters.keys.contains("save_as"))
            XCTAssertTrue(parameters.keys.contains("category_id"))
            XCTAssertTrue(parameters.keys.contains("random_file_link"))
            XCTAssertTrue(parameters.keys.contains("size"))
            XCTAssertTrue(parameters.keys.contains("format"))
        case .videoConcat(let parameters):
            XCTAssertTrue(parameters.keys.contains("m3u8s"))
            XCTAssertTrue(parameters.keys.contains("save_as"))
            XCTAssertTrue(parameters.keys.contains("category_id"))
            XCTAssertTrue(parameters.keys.contains("random_file_link"))
        case .videoClip(let parameters):
            XCTAssertTrue(parameters.keys.contains("m3u8"))
            XCTAssertTrue(parameters.keys.contains("save_as"))
            XCTAssertTrue(parameters.keys.contains("category_id"))
            XCTAssertTrue(parameters.keys.contains("random_file_link"))
            XCTAssertTrue(parameters.keys.contains("include"))
            XCTAssertTrue(parameters.keys.contains("exclude"))
        case .videoMeta(let parameters):
            XCTAssertTrue(parameters.keys.contains("m3u8"))
        case .videoAudioMeta(let parameters):
            XCTAssertTrue(parameters.keys.contains("source"))
        }
    }
}
