//
//  GeoPoint.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import CoreLocation

/// 坐标点
@objc(BaaSGeoPoint)
open class GeoPoint: NSObject {
    /// 经度
    @objc public var longitude: CLLocationDegrees
    /// 纬度
    @objc public var latitude: CLLocationDegrees

    /// 坐标点对应的 json 信息
    @objc public var geoJson: [String: Any] {
        return ["type": "Point", "coordinates": [longitude, latitude]]
    }

    @objc public init(longitude: CLLocationDegrees, latitude: CLLocationDegrees) {
        self.longitude = longitude
        self.latitude = latitude
        super.init()
    }
}

/// 地理形状
@objc(BaaSGeoPolygon)
public class GeoPolygon: NSObject {
    @objc public var coordinates: [[CLLocationDegrees]]

    /// 通过一组 GeoPoint 来创建地理形状
    @objc public init(points: [GeoPoint]) {
        coordinates = []
        for point in points {
            coordinates.append([point.longitude, point.latitude])
        }
        super.init()
    }

    /// 通过一组坐标来创建地理形状
    @objc public init(coordinates: [[CLLocationDegrees]]) {
        self.coordinates = coordinates
        super.init()
    }

    @objc public var geoJson: [String: Any] {
        return ["type": "Polygon", "coordinates": [coordinates]]
    }
}
