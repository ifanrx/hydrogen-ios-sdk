//
//  FileTestCase.swift
//  MinCloudTests
//
//  Created by pengquanhua on 2019/4/11.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class FileTestCase: XCTestCase {

    var data: NSDictionary?
    var deleteFile: File?
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        BaaS.register(clientID: "fdc4feb5403a985fe681")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
    }

    override func tearDown() {

    }

    // 获取文件详情
    func testGetFile() {
        let promise = expectation(description: "Status code: 201")

        let fileId = (data?.getString("fileId"))!
        FileManager.get(fileId) { (file, error) in
            XCTAssertNotNil(file, "记录为 nil")
            XCTAssertNotNil(file!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 获取分类详情
    func testGetFileCategory() {
        let promise = expectation(description: "Status code: 201")

        let categoryId = (data?.getString("file_categoryId"))!
        FileManager.getCategory(categoryId) { (category, error) in
            XCTAssertNotNil(category, "记录为 nil")
            XCTAssertNotNil(category!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 文件列表
    func testFindFileList() {
        let promise = expectation(description: "Status code: 201")

        FileManager.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "内容列表为 nil")
            if listResult?.files?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.files?[0].Id, "内容 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 分类列表
    func testFindCategoryList() {
        let promise = expectation(description: "Status code: 201")

        FileManager.getCategoryList(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "分类列表为 nil")
            if listResult?.fileCategorys?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.fileCategorys?[0].Id, "分类 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 获取某分类下的文件列表
    func testFindFileListInCategory() {
        let promise = expectation(description: "Status code: 201")

        let categoryId = (data?.getString("file_categoryId"))!
        FileManager.find(categoryId: categoryId, completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "内容列表为 nil")
            if listResult?.files?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.files?[0].Id, "内容 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 删除文件
    // 删除本记录
    func testDeleteFile() {
        let promise = expectation(description: "Status code: 201")

        let fileId = (data?.getString("file_deleteId"))!
        deleteFile = File()
        deleteFile?.Id = fileId

        deleteFile?.delete { (result, error) in
            if error != nil {
                XCTAssertTrue(error?.code == 404)
            } else {
                XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
                XCTAssertTrue(result)
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 批量删除记录
    func testDeletRecords() {
        let promise = expectation(description: "Status code: 201")

        let files = (data?.getArray("file_deleteIds", type: String.self))!
        FileManager.delete(files, completion: { (_, error) in
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 上传文件
    func testUploadFile() {
        let promise = expectation(description: "Status code: 201")
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: "1", ofType: "png")
        FileManager.upload(filename: "test", localPath: filePath!,
                           progressBlock: { _ in }, completion: {(file, error) in
            XCTAssertNotNil(file, "记录为 nil")
            XCTAssertNotNil(file!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")
            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

}
