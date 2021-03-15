//
//  Transport.swift
//  swamp
//
//  Created by Yossi Abraham on 18/08/2016.
//  Copyright © 2016 Yossi Abraham. All rights reserved.
//

import Foundation

protocol SwampTransportDelegate: class {
    func swampTransportDidConnectWithSerializer(_ serializer: SwampSerializer)
    func swampTransportConnectFailed(_ error: NSError?, reason: String?)
    func swampTransportReceivedData(_ data: Data)
    func swampTransportReceivedPing()
}

protocol SwampTransport {
    var delegate: SwampTransportDelegate? { get set }
    func connect()
    func disconnect(_ reason: String)
    func sendData(_ data: Data)
}
