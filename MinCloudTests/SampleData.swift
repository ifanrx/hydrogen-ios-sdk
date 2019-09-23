//
//  SampleData.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/16.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

class SampleData {
    static let shared = SampleData()
    struct Auth {
        static let loginUsername = SampleData.shared.sampleData(fileName: "login_username")
        static let loginEmail = SampleData.shared.sampleData(fileName: "login_email")
        static let registerUsername = SampleData.shared.sampleData(fileName: "register_username")
        static let registerEmail = SampleData.shared.sampleData(fileName: "register_email")
        static let anonymous = SampleData.shared.sampleData(fileName: "login_anonymous")
        static let curUser = SampleData.shared.sampleData(fileName: "user_info")
    }
    
    struct User {
        static let userInfo = SampleData.shared.sampleData(fileName: "user_info")
        static let userInfo_option = SampleData.shared.sampleData(fileName: "user_info_option")
        static let userList = SampleData.shared.sampleData(fileName: "user_list")
        static let userList_option = SampleData.shared.sampleData(fileName: "user_list_option")
        static let updateUserName = SampleData.shared.sampleData(fileName: "update_username")
        static let updateEmail = SampleData.shared.sampleData(fileName: "update_email")
        static let updatePwd = SampleData.shared.sampleData(fileName: "update_pwd")
        static let updateUserInfo = SampleData.shared.sampleData(fileName: "update_userinfo")
    }
    
    struct Table {
        static let get_record = SampleData.shared.sampleData(fileName: "get_record")
        static let get_record_option = SampleData.shared.sampleData(fileName: "get_record_option")
        static let record_list = SampleData.shared.sampleData(fileName: "record_list")
        static let record_list_option = SampleData.shared.sampleData(fileName: "record_list_option")
        static let create_one_record = SampleData.shared.sampleData(fileName: "create_one_record")
        static let create_many_record = SampleData.shared.sampleData(fileName: "create_many_records")
        static let batch_update = SampleData.shared.sampleData(fileName: "batch_update")
        static let batch_delete = SampleData.shared.sampleData(fileName: "batch_delete")
    }
    
    struct Record {
        static let create_record = SampleData.shared.sampleData(fileName: "create_record")
        static let update_record = SampleData.shared.sampleData(fileName: "update_record")
        static let base_record = SampleData.shared.sampleData(fileName: "base_record")
        static let base_record_created_by_dict = SampleData.shared.sampleData(fileName: "base_record_created_by_dict")

    }
    
    struct Content {
        static let get_content = SampleData.shared.sampleData(fileName: "get_content")
        static let get_content_option = SampleData.shared.sampleData(fileName: "get_content_option")
        static let get_category = SampleData.shared.sampleData(fileName: "get_content_category")
        static let content_list = SampleData.shared.sampleData(fileName: "content_list")
        static let content_list_option = SampleData.shared.sampleData(fileName: "content_list_option")
        static let content_list_in_category = SampleData.shared.sampleData(fileName: "content_list_in_category")
        static let category_list = SampleData.shared.sampleData(fileName: "category_list")
    }
    
    struct File {
        static let file_upload = SampleData.shared.sampleData(fileName: "file_upload")
        static let file_upload_UP = SampleData.shared.sampleData(fileName: "file_upload_UP")
        static let get_file = SampleData.shared.sampleData(fileName: "get_file")
        static let file_list = SampleData.shared.sampleData(fileName: "file_list")
        static let file_list_option = SampleData.shared.sampleData(fileName: "file_list_option")
        static let file_list_in_category = SampleData.shared.sampleData(fileName: "file_list_in_category")
        static let get_category_list = SampleData.shared.sampleData(fileName: "get_category_list")
        static let get_category = SampleData.shared.sampleData(fileName: "get_category")
    }
    
    struct Order {
        static let wx_pay = SampleData.shared.sampleData(fileName: "wx_pay")
        static let ali_pay = SampleData.shared.sampleData(fileName: "ali_pay")
        static let get_order = SampleData.shared.sampleData(fileName: "get_order")
        static let order_list = SampleData.shared.sampleData(fileName: "order_list")
    }
    
    struct BaaS {
        static let invoke = SampleData.shared.sampleData(fileName: "invoke")
    }
    
    struct Network {
        static let network_error_json = SampleData.shared.sampleData(fileName: "network_error_json")
    }
    
    func sampleData(fileName: String) -> Data {
        let url = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}

extension Data {
    func toDictionary() -> [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! [String: Any]
            return dic
        } catch _ {
                return nil
        }
    }
}

