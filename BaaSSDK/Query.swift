//
//  Query.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASQuery)
open class Query: NSObject {

    var conditon: [String: Any]

    @objc public init(conditon: [String: Any]) {
        self.conditon = conditon
        super.init()
    }

    @objc public override init() {
        self.conditon = [:]
        super.init()
    }

    @objc static public func or(querys: [Query]) -> Query {
        var conditons: [[String: Any]] = []
        for query in querys {
            conditons.append(query.conditon)
        }
        return Query(conditon: ["$or": conditons])
    }

    @objc static public func and(querys: [Query]) -> Query {
        var conditons: [[String: Any]] = []
        for query in querys {
            conditons.append(query.conditon)
        }
        return Query(conditon: ["$and": conditons])
    }

    @objc static public func compare(key: String, operator opt: Operator, value: Any) -> Query {
        var op = "eq"
        switch opt {
        case .equalTo:
            op = "eq"
        case .notEqualTo:
            op = "ne"
        case .lessThan:
            op = "lt"
        case .greaterThan:
            op = "gt"
        case .greaterThanOrEqualTo:
            op = "gte"
        case .lessThanOrEqualTo:
            op = "lte"
        }
        return Query(conditon: [key: ["$\(op)": value]])
    }

    @objc static public func range(key: String, start: Double, end: Double) -> Query {
        return Query(conditon: [key: ["$range": [start, end]]])
    }

    @objc static public func contains(key: String, value: String) -> Query {
        return Query(conditon: [key: ["$contains": value]])
    }

    @objc static public func icontains(key: String, value: String) -> Query {
        return Query(conditon: [key: ["$icontains": value]])
    }

    @objc static public func inList(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$in": list]])
    }

    @objc static public func notInList(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$nin": list]])
    }

    @objc static public func arrayContains(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$all": list]])
    }

    @objc static public func isNull(key: String) -> Query {
        return Query(conditon: [key: ["$isnull": true]])
    }

    @objc static public func isNotNull(key: String) -> Query {
        return Query(conditon: [key: ["$isnull": false]])
    }

    @objc static public func exists(key: String) -> Query {
        return Query(conditon: [key: ["$exists": true]])
    }

    @objc static public func notExists(key: String) -> Query {
        return Query(conditon: [key: ["$exists": false]])
    }

    @objc static public func hasKey(_ key: String, fieldName: String) -> Query {
        return Query(conditon: [key: ["$has_key": fieldName]])
    }

    @objc static public func within(key: String, polygon: GeoPolygon) -> Query {
        return Query(conditon: [key: ["$intersects": polygon.geoJson]])
    }

    @objc static public func include(key: String, point: GeoPoint) -> Query {
        return Query(conditon: [key: ["$intersects": point.geoJson]])
    }

    @objc static public func withinCircle(key: String, point: GeoPoint, radius: Float) -> Query {
        let data: [String: Any] = ["radius": radius, "coordinates": [point.longitude, point.latitude]]
        let dataJson = data as NSDictionary
        return Query(conditon: [key: ["$center": dataJson]])
    }

    @objc static public func withinRegion(key: String, point: GeoPoint, minDistance: Float, maxDistance: Float) -> Query {
        let data: [String: Any] = ["geometry": point.geoJson, "min_distance": minDistance, "max_distance": maxDistance]
        return Query(conditon: [key: ["$nearsphere": data]])
    }
}
