//
//  MinCloudCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/16.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

protocol Sampledata {
    var testSampleData: Data { get }
}

class MinCloudCase: XCTestCase {

    override func setUp() {
        BaaS.register(clientID: "196ba98487ebc358955d")
        Auth.AuthProvider = MoyaProvider<AuthAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [AuthPlugin()])
        User.UserProvider = MoyaProvider<UserAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [UserPlugin()])
        Table.TableProvider = MoyaProvider<TableAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [TablePlugin()])
        Record.TableRecordProvider = MoyaProvider<TableRecordAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [RecordPlugin()])
        FileManager.FileProvider = MoyaProvider<FileAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [FilePlugin()])
        ContentGroup.ContentGroupProvider = MoyaProvider<ContentGroupAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [ContentPlugin()])
        Pay.PayProvider = MoyaProvider<PayAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [OrderPlugin()])
        BaaS.BaasProvider = MoyaProvider<BaaSAPI>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, plugins: [BaaSPlugin()])
        
    }

    override func tearDown() {
    }

}

func customEndpointClosure(_ target: AuthAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: UserAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: TableAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: TableRecordAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: ContentGroupAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: PayAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: BaaSAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}

func customEndpointClosure(_ target: FileAPI) -> Endpoint {
    return Endpoint(url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
}
