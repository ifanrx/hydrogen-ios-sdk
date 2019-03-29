//
//  GeoPoint.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

// 坐标点
public class GeoPoint: NSObject {
    public let longitude: Double
    public let latitude: Double

    public var geoJson: [String: Any] {
        return ["type": "Point", "coordinates": [longitude, latitude]]
    }

    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
        super.init()
    }
}

// 地理形状
public class GeoPolygon: NSObject {
    var coordinates: [[Double]] = []
    init(points: [Any]) {
        for point in points {
            if let point = point as? GeoPoint {
                coordinates.append([point.longitude, point.latitude])
            } else if let point = point as? [Double], point.count == 2 {
                coordinates.append(point)
            } else {
                // TODO: 抛出异常
            }
        }
        super.init()
    }
    var geoJson: [String: Any] {
        return ["type": "Polygon", "coordinates": coordinates]
    }
}
