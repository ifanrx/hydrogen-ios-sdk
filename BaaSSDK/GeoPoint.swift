//
//  GeoPoint.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

// 坐标点
@objc(BAASGeoPoint)
open class GeoPoint: NSObject {
    @objc public var longitude: Double
    @objc public var latitude: Double

    @objc public var geoJson: [String: Any] {
        return ["type": "Point", "coordinates": [longitude, latitude]]
    }

    @objc public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
        super.init()
    }
}

// 地理形状
@objc(BAASGeoPolygon)
public class GeoPolygon: NSObject {
    var coordinates: [[Double]] = []
    @objc public init?(points: [Any]) {
        for point in points {
            if let point = point as? GeoPoint {
                coordinates.append([point.longitude, point.latitude])
            } else if let point = point as? [Double], point.count == 2 {
                coordinates.append(point)
            } else {
                return nil
            }
        }
        super.init()
    }
    @objc public var geoJson: [String: Any] {
        return ["type": "Polygon", "coordinates": coordinates]
    }
}
