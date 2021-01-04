//
//  JSONSwampSerializer.swift
//  Pods
//
//  Created by Yossi Abraham on 21/08/2016.
//
//

import Foundation

class JSONSwampSerializer: SwampSerializer {
    
    public init() {}
    
    open func pack(_ data: [Any]) -> Data? {
        if !JSONSerialization.isValidJSONObject(data) {
             return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    }
    
    open func unpack(_ data: Data) -> [Any]? {
        if JSONSerialization.isValidJSONObject(data) {
             return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any]
    }
}
