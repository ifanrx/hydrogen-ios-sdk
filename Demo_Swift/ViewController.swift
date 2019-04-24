//
//  ViewController.swift
//  Demo_Swift
//
//  Created by pengquanhua on 2019/4/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import MinCloud

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var data: NSArray!

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
        let contentGroup = ContentGroup(Id: 1551697162031508)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // 用户名注册
                Auth.register(username: "test0410", password: "1111") {_, _ in

                }
            case 1:
                // 邮箱注册
                Auth.register(email: "test0410@yeah.net", password: "1111") {_, _ in

                }
            case 2:
                // 用户名登录
                Auth.login(username: "test0410", password: "1111") {_, _ in

                }
            case 3:
                // 邮箱登录
                Auth.login(email: "test0410@yeah.net", password: "1111") {_, _ in

                }
            case 4:
                // 匿名登录
                Auth.anonymousLogin {_, _ in

                }
            case 5:
                // 登出
                Auth.logout {_, _ in

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
                Auth.getCurrentUser {_, _ in

                }

            case 2:
                // 更新密码
                Auth.getCurrentUser {_, _ in

                }
            case 3:
                // 更新邮箱
                Auth.getCurrentUser {_, _ in

                }
            case 4:
                // 更新自定义用户信息
                Auth.getCurrentUser {_, _ in

                }
            case 5:
                // 请求邮箱验证
                Auth.getCurrentUser {_, _ in

                }
            case 6:
                // 通过邮箱设置密码
                Auth.getCurrentUser {_, _ in

                }
            case 7:
                // 批量查询用户列表，如 获取年龄小于 25 的用户
                let whereArgs = Where.compare(key: "age", operator: .equalTo, value: 19)
                let query = Query()
                query.setWhere(whereArgs)
                User.find(query: query, completion: {_, _ in

                })
            case 8:
                // 获取指定用户
                User.get(36845069853014, select: ["nickname", "gender"]) {

                }
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 2:
            switch indexPath.row {

            case 0:
                // 获取指定数据详情

                table.get("5cb43f3f66e4804bb158bc4f", select: ["color", "created_by"], expand: ["created_by"]) {_, _ in

                }
            case 1:
                // let whereArgs = Where.include(key: "polygon", point: GeoPoint(latitude: 5, longitude: 25))
                //let whereArgs = Where.withinCircle(key: "location", point: GeoPoint(longitude: 5.0, latitude: 5.0), radius: 100)
                //let whereArgs = Where.withinRegion(key: "location", point: GeoPoint(longitude: 5, latitude: 5), minDistance: 1.0, maxDistance: 5.0)
                //let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 20)
                let whereArgs = Where.compare(key: "writer", operator: .equalTo, value: table.getWithoutData(recordId: "5ca4769f8c374f34dfa80ad8"))
                let query = Query()
                query.setWhere(whereArgs)
                table.find(query: query, completion: {

                })

            case 2:
                // 更新数据
                let record = table.getWithoutData(recordId: "5cb550395c29454d25fba03a")
                record.set(key: "color", value: "brown")
                record.set(record: ["author": "hua", "name": "good book"])
                record.incrementBy(key: "price", value: 1)
                record.append(key: "recommender", value: ["hong"])

                record.update {_, _ in

                }
            case 3:
                // 指定需要删除的记录
                let record = table.getWithoutData(recordId: "5cad89bdcb1e060359405460")
                record.delete(completion: {_, _ in

                })
            case 4:
                // 批量删除，如删除所有 color 为 brown 的记录项。
                let whereArgs = Where.contains(key: "color", value: "brown")
                let query = Query()
                query.setWhere(whereArgs)
                let options = ["enable_trigger": true]
                table.delete(query: query, options: options, completion: {_, _ in

                })
            case 5:
                // 新增数据，创建一个空的记录项
                let record = table.createRecord()

                // 逐个赋值
                record.set(key: "description", value: "这是本好书")

                // 一次性赋值
                record.set(record: ["price": 24, "name": "老人与海"])

                // date 类型
                //                let dateISO = ISO8601DateFormatter().string(from: Date())
                //                record.set(key: "publish_date", value: dateISO)

                // geoPoint 类型
                let point = GeoPoint(longitude: 2, latitude: 10)
                record.set(key: "location", value: point)

                // polygon
                let polygon = GeoPolygon(coordinates: [[10, 10], [40, 40], [20, 40], [10, 20], [10, 10]])
                record.set(key: "polygon", value: polygon)

                // object
                let pulish_info = ["name": "新华出版社"]
                record.set(key: "publish_info", value: pulish_info)

                // array
                record.set(key: "recommender", value: ["hua", "ming"])

                let authorTable = Table(name: "Author")
                let author = authorTable.getWithoutData(recordId: "5cb5501466e48071100a0eb0")
                record.set(key: "author", value: author)

                record.save {_, _ in

                }

            case 6:
                // 批量增加数据项
                let options = ["enable_trigger": true]
                table.createMany([["name": "麦田里的守望者", "price": 19], ["name": "三体", "price": 19]], options: options) {_, _ in

                }
            case 7:
                // 批量更新数据，如将价钱小于15的记录的价钱 增加 1.
                let whereArgs = Where.compare(key: "price", operator: .lessThan, value: 15)
                let query = Query()
                query.setWhere(whereArgs)
                let options = ["enable_trigger": true]
                let record = table.createRecord()
                record.incrementBy(key: "price", value: 1)
                table.update(record: record, query: query, options: options) { (_, _) in

                }
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 3:
            switch indexPath.row {
            case 0:
                // 获取内容详情
                contentGroup.get(1551697403189289, select: ["title"]) {_, _ in

                }
            case 1:
                // 查询内容列表
                // 如需查询，过滤，查找 Table的方法
                contentGroup.find(completion: {_, _ in

                })
            case 2:
                // 在分类中，查询内容列表
                contentGroup.find(categoryId: 1551697507400928) { (_, _) in

                }
            case 3:
                // 获取分类详情
                contentGroup.getCategory(1551697507400928) {_, _ in

                }
            case 4:
                // 获取分类列表
                // 如需查询，过滤，查找 Table的方法
                contentGroup.getCategoryList {_, _ in

                }
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                // 上传文件
                let filePath = Bundle.main.path(forResource: "1", ofType: "png")
                FileManager.upload(filename: "test", localPath: filePath!, categoryName: "category1",
                                   progressBlock: { progress in print("\(String(describing: progress?.fractionCompleted))") },
                                   completion: {_, _ in })
            case 1:
                // 获取文件详情
                FileManager.get("5cac34631071240a7f8c492d", select: ["size"]) {_, _ in

                }
            case 2:
                // 查询文件列表
                //                let query = Where.contains(key: "name", value: "test")
                //                fileManager.setWhere(query)
                FileManager.find(completion: {_, _ in

                })
            case 3:
                // 删除文件
//                let file = File()
//                // file.Id = "5cab1a941feb8f06a883800c"
//                file.delete({_, _ in
//
//                })
                break
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
                FileManager.getCategoryList(completion: {_, _ in

                })
            case 7:
                // 获取文件列表
                FileManager.find(categoryId: "5ca489bb8c374f5039a8062b") { (_, _) in

                }
            case 8:
                let params: [String: Any] = ["source": "xxxxxxxxxx",
                              "save_as": "hello.png",
                              "point": "00:00:10",
                              "category_id": "5c18bc794e1e8d20dbfcddcc",
                              "random_file_link": false]
                FileManager.genVideoSnapshot(params) {

                }
            case 9:
                let params: [String: Any] = ["m3u8s": ["xxxxxxxxxx", "xxxxxxxxxx"],
                                             "save_as": "hello.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]
                FileManager.videoConcat(params) {

                }
            case 10:
                let params: [String: Any] = ["m3u8s": ["xxxxxxxxxx", "xxxxxxxxxx"],
                                             "save_as": "hello.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]
                FileManager.videoConcat(params) {

                }
            case 11:
                let params: [String: Any] = ["m3u8": "xxxxxxxxxx",
                                             "include": [0, 20],
                                             "save_as": "0s_20s.m3u8",
                                             "category_id": "5c18bc794e1e8d20dbfcddcc",
                                             "random_file_link": false]

                FileManager.videoClip(params) {

                }
            case 12:
                FileManager.videoMeta("xxxx") {

                }
            case 13:
                FileManager.videoAudioMeta("xxxx") {

                }
            default:
                break
            }
        case 5:
            switch indexPath.row {
            case 0:
                // 云函数
                BaaS.invoke(name: "helloWorld", data: ["name": "MinCloud"], sync: true) {

                }
            case 1:
                // 发送验证码
                BaaS.sendSmsCode(phone: "15088057274") {

                }
            case 2:
                // 验证手机验证码
                BaaS.verifySmsCode(phone: "15088057274", code: "") {

                }
            default:
                break
            }
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

//    func showMessage(message: String) {
//        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
}
