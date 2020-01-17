//
//  ViewController.swift
//  Demo_Swift
//
//  Created by pengquanhua on 2019/4/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import MinCloud
import Photos
import AuthenticationServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var tableView: UITableView!
    var data: NSArray!
    var resultInfo: Order!
    var record: Record!
    let auth = Auth()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: self.view.frame, style: .plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView)

        let filePath = Bundle.main.path(forResource: "datasource", ofType: "plist")
        self.data = NSArray(contentsOfFile: filePath!)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = self.data[section] as? NSArray {
            return section.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Auth"
        case 1:
            return "User"
        case 2:
            return "Table"
        case 3:
            return "ContentGroup"
        case 4:
            return "File"
        case 5:
            return "Other"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify: String = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        if let array = self.data[indexPath.section] as? NSArray {
            cell.textLabel?.text = array[indexPath.row] as? String
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let table = Table(name: "Book")
        let contentGroup = ContentGroup(Id: "1551697162031508")

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // 用户名注册
                Auth.register(username: "ifanr", password: "12345") { _, _ in
                }
            case 1:
                // 邮箱注册
                Auth.register(email: "pengquanhua@ifanr.com", password: "12345") {_, _ in

                }
            case 2:
                // 用户名登录
                Auth.login(username: "ifanr", password: "12345") {_, _ in

                }
            case 3:
                // 邮箱登录
                Auth.login(email: "ifanr@ifanr.com", password: "12345") {_, _ in

                }
            case 4:
                // 匿名登录
                Auth.anonymousLogin {_, _ in

                }
            case 5:
                // 登出
                Auth.logout {_, _ in

                }
            case 6:
//                Auth.signIn(with: .apple) { (user, error) in
//
//                }

                break
            case 7:
                Auth.signIn(with: .wechat, createUser: true, syncUserProfile: .setnx) { (user, error) in
                    print("")
                }
                break
            case 8:
//                ThirdAuth.shared.setWeiBo(with: "542432732")
//                ThirdAuth.shared.signInWeibo { (result, error) in
//
//                }
                break
            case 9:
                Auth.associate(with: .wechat, syncUserProfile: .setnx) { (user, error) in
                    print("")
                }
                break
            case 10:
//                ThirdAuth.shared.setWeiBo(with: "542432732")
//                ThirdAuth.shared.associateWeibo { (result, error) in
//
//                }
                break
            case 11:
//                Auth.associate(with: .apple) { (user, error) in
//
//                }
                break
            case 12:
                Auth.signInWithSMS(phone: "15088057274", code: "", createUser: true) { (user, error) in
                    print("error: \(error)")
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                // 获取当前用户
                Auth.getCurrentUser({_, _ in

                })
            case 1:
                // 更新用户名
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.updateUsername("ifanr_new", completion: { (_, _) in

                        })
                    }
                }

            case 2:
                // 更新密码
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.updatePassword("12345", newPassword: "123456") { (result, error) in

                        }
                    }
                }
            case 3:
                // 更新邮箱
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.updateEmail("ifanr_new@ifanr.com", completion: { (_, _) in

                        })
                    }
                }
            case 4:
                // 更新自定义用户信息
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.updateUserInfo(["city": "guangzhou"], completion: { (_, _) in

                        })
                    }
                }
            case 5:
                // 请求邮箱验证
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.requestEmailVerification({ (_, _) in

                        })
                    }
                }
            case 6:
                // 通过邮箱设置密码
                Auth.getCurrentUser {user, _ in
                    if user != nil {
                        user?.resetPassword(email: "pengquanhua@ifanr.com", completion: { (_, _) in

                        })
                    }
                }
            case 7:
                let whereAgrs = Where.compare("age", operator: .equalTo, value: 23)
                let query = Query()
                query.where = whereAgrs
                query.limit = 10
                query.offset = 0
                query.orderBy = ["created_at"]
                query.expand = ["created_by"]
                query.select = ["-_username", "-created_by"]
                query.returnTotalCount = true
                User.find(query: query, completion: {_, _ in

                })
            case 8:
                // 获取指定用户
                User.get("92812581396859", select: ["-_username", "-created_by"], expand: ["created_by"]) {_, _ in

                }
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 2:
            switch indexPath.row {

            case 0:
                // 获取指定数据详情

                table.get("5d5e5d2e989c1c336aa7b6bd", select: ["color", "created_by"], expand: ["created_by"]) {_, _ in

                }
            case 1:

//                1. include
//                113.3432006836,23.0683609237
//                113.3857727051,23.0879434369
//                113.3524703979,23.0952071923
//                113.3432006836,23.0683609237
//                point：113.3299827576,23.1031810803
//                let whereArgs = Where.include(key: "polygon", point: GeoPoint(longitude: 113.3622550964, latitude: 23.0884171721))


//                let whereArgs = Where.withinCircle(key: "location", point: GeoPoint(longitude: 113.4196758270, latitude: 23.1348351120), radius: 3)
                // 单位为KM
//                let whereArgs = Where.withinRegion(key: "location", point: GeoPoint(longitude: 113.4196758270, latitude: 23.1348351120), minDistance: 0.1, maxDistance: 3)

                let whereArgs = Where.within("location", polygon: GeoPolygon(coordinates: [[113.4594583511,23.1265079048], [113.4705305099,23.1344010050], [113.4634065628,23.1390577162], [113.4564113617,23.1353481458], [113.4594583511,23.1265079048]]))
//                //let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 20)
////                let whereArgs = Where.compare(key: "writer", operator: .equalTo, value: table.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8"))
//                let whereAgrs = Where.compare(key: "color", operator: .equalTo, value: "brown")
                let query = Query()
                let `where` = Where.compare("price", operator: .lessThan, value: 15)
                //query.where = `where`
//                query.setWhere(whereAgrs)
                //query.where = whereArgs
                query.limit = 10
                query.offset = 0
                query.orderBy = ["created_at"]
                query.expand = ["created_by"]
                query.select = ["-name", "-price"]
                query.returnTotalCount = true
                table.find(query: query, completion: {_, _ in

                })

            case 2:
                // 更新数据
                record = table.getWithoutData(recordId: "5d8b20dcea9d7468f11411aa")
                record.set("color", value: "brown")
                record.set(["author": "hua", "name": "good book"])
                record.incrementBy("price", value: 1)
                record.append("recommender", value: ["hong"])
                // geoPoint 类型
                let point = GeoPoint(longitude: 2, latitude: 10)
                record.set("location", value: point)

                // polygon
                let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
                record.set("polygon", value: polygon)

                // object
                let pulish_info = ["name": "新华出版社"]
                record.set("publish_info", value: pulish_info)

                // array
                record.set("recommender", value: ["hua", "ming"])

                let authorTable = Table(name: "Author")
                let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
                record.set("writer", value: author)

                record.update {_, _ in
                }
            case 3:
                // 指定需要删除的记录
                let record = table.getWithoutData(recordId: "5d80a0f6b569376e0b1d5064")
                record.delete(completion: {_, _ in

                })
            case 4:
                // 批量删除，如删除所有 color 为 brown 的记录项。
                let whereArgs = Where.contains("color", value: "brown")
                let query = Query()
                query.where = whereArgs
                let options = ["enable_trigger": true]
                query.returnTotalCount = true
                table.delete(query: query, options: options, completion: {_, _ in

                })
            case 5:
                // 新增数据，创建一个空的记录项
                record = table.createRecord()

                // 逐个赋值
                record.set("description", value: "这是本好书")

                // 一次性赋值
                record.set(["price": 24, "name": "老人与海"])

                // date 类型
                //                let dateISO = ISO8601DateFormatter().string(from: Date())
                //                record.set(key: "publish_date", value: dateISO)

                // geoPoint 类型
                let point = GeoPoint(longitude: 2, latitude: 10)
                record.set("location", value: point)

                // polygon
                let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
                record.set("polygon", value: polygon)

                // object
                let pulish_info = ["name": "新华出版社"]
                record.set("publish_info", value: pulish_info)

                // array
                record.set("recommender", value: ["hua", "ming"])

                let authorTable = Table(name: "Author")
                let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
                record.set("writer", value: author)
                
                let file = File(dict: ["created_at": 1554287059, "id": "5ca489d3d625d846af4bf453", "mime_type": "image/png", "name": "test", "path": "https://cloud-minapp-25010.cloud.ifanrusercontent.com/1hBd47RKaLeXkOAF", "size": 2299])
                record.set("cover", value: file!)
                record.set("arrayFile", value: [file!])
                record.set("arrayPoint", value: [point])
                record.set("arrayPolygon", value: [polygon])

                record.save {_, _ in
                    
                }

            case 6:
                // 批量增加数据项
                let options = ["enable_trigger": true]
                let point = GeoPoint(longitude: 113.3622550964, latitude: 23.0884171721)
                let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
                let authorTable = Table(name: "Author")
                let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
                table.createMany([["name": "麦田里的守望者", "price": 30, "location": point, "writer": author], ["name": "三体", "price": 39, "polygon": polygon]], options: options) {_, _ in

                }
            case 7:
                // 批量更新数据，如将价钱小于15的记录的价钱 增加 1.
                let whereArgs = Where.compare("price", operator: .lessThan, value: 15)
                let query = Query()
                query.where = whereArgs
                let options = ["enable_trigger": true]
                let record = table.createRecord()
                //record.incrementBy(key: "price", value: 1)
                record.set("price", value: 9)
                let point = GeoPoint(longitude: 2, latitude: 10)
                record.set("location", value: point)

                // polygon
                let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
                record.set("polygon", value: polygon)

                // object
                let pulish_info = ["name": "新华出版社"]
                record.set("publish_info", value: pulish_info)

                // array
                record.set("recommender", value: ["hua", "ming"])

                let authorTable = Table(name: "Author")
                let author = authorTable.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8")
                record.set("writer", value: author)
                query.returnTotalCount = true
                table.update(record: record, query: query, options: options) { (_, _) in

                }
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 3:
            switch indexPath.row {
            case 0:
                // 获取内容详情
                contentGroup.get("1551697403189289") {content, error in

                }
            case 1:
                // 查询内容列表
                // 如需查询，过滤，查找 Table的方法
                let whereAgrs = Where.compare("title", operator: .equalTo, value: "article")
                let query = Query()
                query.where = whereAgrs
                query.limit = 10
                query.offset = 0
                query.orderBy = ["created_at"]
                query.select = ["title"]
                query.returnTotalCount = true
                contentGroup.find(query: query, completion: {_, _ in

                })
            case 2:
                // 在分类中，查询内容列表
                let query = Query()
                query.returnTotalCount = true
                contentGroup.find(categoryId: "1551697507400928", query: query) { (_, _) in

                }
            case 3:
                // 获取分类详情
                contentGroup.getCategory("1551697507400928") {_, _ in

                }
            case 4:
                // 获取分类列表
                // 如需查询，过滤，查找 Table的方法

                let query = Query()
                query.limit = 20
                query.offset = 0
                query.returnTotalCount = true
                contentGroup.getCategoryList(query: query) {_, _ in

                }
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                // 上传文件
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true) {

                    }
                }
            case 1:
                // 获取文件详情
                FileManager.get("5ca489d3d625d846af4bf453") {file, error in

                }
            case 2:
                // 查询文件列表
                //                let query = Where.contains(key: "name", value: "test")
                //                fileManager.setWhere(query)
                let whereAgrs = Where.compare("name", operator: .equalTo, value: "3.jpg")
                let query = Query()
                query.where = whereAgrs
                query.limit = 10
                query.offset = 0
                query.orderBy = ["size"]
                query.returnTotalCount = true
                FileManager.find(query: query, completion: {_, _ in

                })
            case 3:
                // 删除文件
                let file = File()
                // file.Id = "5cab1a941feb8f06a883800c"
                file.delete({_, _ in

                })
            case 4:
                // 删除多个文件
                FileManager.delete(["5cab1a981feb8f06a8838011", "5cab1a961feb8f074a68a01a"]) {_, _ in

                }
            case 5:
                // 获取文件分类详情
                //                fileManager.select(["id"])
                //                fileManager.limit(10)
                FileManager.getCategory("5ca489bb8c374f5039a8062b") {_, _ in

                }
            case 6:
                // 获取文件分类列表
                let query = Query()
                query.limit = 10
                query.offset = 0
//                query.returnTotalCount(true)
                FileManager.getCategoryList(query: query, completion: {_, _ in

                })
            case 7:
                // 获取文件列表
                let query = Query()
                query.returnTotalCount = true
                FileManager.find(categoryId: "5ca489bb8c374f5039a8062b", query: query) { (_, _) in

                }
            case 8:
                let params: [String: Any] = ["source": "xxxxxxxxxx",
                              "save_as": "hello.png",
                              "point": "00:00:10",
                              "category_id": "5c18bc794e1e8d20dbfcddcc",
                              "random_file_link": false]
                FileManager.genVideoSnapshot(params) {_, _ in

                }
            case 9:
                let params: [String: Any] = ["m3u8s": ["xxxxxxxxxx", "xxxxxxxxxx"],
                                             "save_as": "hello.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]
                FileManager.videoConcat(params) {_, _ in

                }
            case 10:
                let params: [String: Any] = ["m3u8s": ["xxxxxxxxxx", "xxxxxxxxxx"],
                                             "save_as": "hello.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]
                FileManager.videoConcat(params) {_, _ in

                }
            case 11:
                let params: [String: Any] = ["m3u8": "xxxxxxxxxx",
                                             "include": [0, 20],
                                             "save_as": "0s_20s.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]

                FileManager.videoClip(params) {_, _ in

                }
            case 12:
                FileManager.videoMeta("xxxx") {_, _ in

                }
            case 13:
                FileManager.videoAudioMeta("xxxx") {_, _ in

                }
            default:
                break
            }
        case 5:
            switch indexPath.row {
            case 0:
                // 云函数
                BaaS.invoke(name: "helloWorld", data: ["name": "MinCloud", "version": "0.2.0"], sync: true) {result, error in

                }
            case 1:
                // 发送验证码
                BaaS.sendSmsCode(phone: "15088057274") {_, _ in

                }
            case 2:
                // 验证手机验证码
                BaaS.verifySmsCode(phone: "15088057274", code: "") {_, _ in

                }
            case 3:
                //获取服务器时间
                BaaS.getServerTime() { result, error in
                    
                }
            default:
                break
            }
        case 6:

            switch indexPath.row {
            case 0:
                Pay.shared.wxPay(totalCost: 0.01, merchandiseDescription: "微信支付", completion: { (result, error) in
                    self.resultInfo = result
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "支付失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                })
            case 1:
                Pay.shared.aliPay(totalCost: 0.02, merchandiseDescription: "支付宝", completion: { (result, error) in
                    self.resultInfo = result
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "支付失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                })
            case 2:
                if self.resultInfo == nil {
                    self.showMessage(message: "请创建订单")
                } else {
                    Pay.shared.order(self.resultInfo.transactionNo!) { (result, error) in
                        if error != nil {
                            self.showMessage(message: error?.localizedDescription ?? "获取订单失败")
                        } else {
                            self.showMessage(message: result?.description ?? "")
                        }
                    }
                }

            case 3:
                if self.resultInfo == nil {
                    self.showMessage(message: "请创建订单")
                } else {
                    Pay.shared.repay(self.resultInfo) { (result, error) in
                        if error != nil {
                            self.showMessage(message: error?.localizedDescription ?? "支付失败")
                        } else {
                            self.showMessage(message: result?.description ?? "")
                        }
                    }
                }
            case 4:
                let query = Query()
                query.limit = 10
                query.offset = 0
                Pay.shared.orderList(query: query) { (result, error) in
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "获取订单列表失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                }
            case 5:
                let query = OrderQuery()
                query.status = .pending
                Pay.shared.orderList(query: query) { (result, error) in
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "获取订单列表失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                }
            case 6:
                let query = OrderQuery()
                query.status = .success
                Pay.shared.orderList(query: query) { (result, error) in
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "获取订单列表失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                }
            case 7:
                let query = OrderQuery()
                query.gateWayType = .weixin
                query.limit = 10
                Pay.shared.orderList(query: query) { (result, error) in
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "获取订单列表失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                }
            case 8:
                let query = OrderQuery()
                query.transactionNo = "fBEyihJVn2QRV5H8bD9JuP7W9wwnm7cD"
                Pay.shared.orderList(query: query) { (result, error) in
                    if error != nil {
                        self.showMessage(message: error?.localizedDescription ?? "获取订单列表失败")
                    } else {
                        self.showMessage(message: result?.description ?? "")
                    }
                }

            default:
                break
            }
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func showMessage(message: String) {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpg"
        let imageData = pickedImage.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        if fileManager.fileExists(atPath: filePath) {
            FileManager.upload(filename: "test", localPath: filePath, categoryName: "category1",
                               progressBlock: { progress in print("\(String(describing: progress?.fractionCompleted))") },
                               completion: {file, error in
                                
            })
        }
        
        picker.dismiss(animated: true) {
            
        }
        
    }
}

extension String {

    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    func base64Decoded() -> String? {
        let str = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        if let data = Data(base64Encoded: str) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

//extension ViewController: ASAuthorizationControllerDelegate {
//    @available(iOS 13.0, *)
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//
//            if let token = appleIDCredential.identityToken {
//                let tokenStr = String(data: token, encoding: .utf8)
////                Auth.signInWithApple(authToken: tokenStr!, nickname: "apple") { (result, error) in
////
////                }
//                ThirdAuth.shared.associateApple(authToken: tokenStr!, nickname: "apple") { (result, error) in
//
//                }
//            }
//        }
//    }
//
//    @available(iOS 13.0, *)
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        // Handle error.
//    }
//}
//
//extension ViewController: ASAuthorizationControllerPresentationContextProviding {
//    @available(iOS 13.0, *)
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}
