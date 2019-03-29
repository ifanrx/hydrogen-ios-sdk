//
//  Query.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

public class Query: NSObject {

    var conditon: [String: Any]

    fileprivate init(conditon: [String: Any]) {
        self.conditon = conditon
        super.init()
    }

    fileprivate override init() {
        self.conditon = [:]
        super.init()
    }

    static public func or(querys: [Query]) -> Query {
        var conditons: [[String: Any]] = []
        for query in querys {
            conditons.append(query.conditon)
        }
        return Query(conditon: ["$or": conditons])
    }

    static public func and(querys: [Query]) -> Query {
        var conditons: [[String: Any]] = []
        for query in querys {
            conditons.append(query.conditon)
        }
        return Query(conditon: ["$and": conditons])
    }

    static public func compare(key: String, operator opt: String, value: Any) -> Query {
        // TODO: 检查 key，opt，value 类型
        var op = "eq"
        switch opt {
        case "=":
            op = "eq"
        case "!=":
            op = "ne"
        case "<":
            op = "lt"
        case ">":
            op = "gt"
        case ">=":
            op = "gte"
        case "<=":
            op = "lte"
        default:
            // TODO: 抛出异常
            break
        }
        return Query(conditon: [key: ["$\(op)": value]])
    }

    static public func range(key: String, start: Float, end: Float) -> Query {  // TODO: Float 表示数字是否合适
        return Query(conditon: [key: ["$range": [start, end]]])
    }

    static public func contains(key: String, value: String) -> Query {
        return Query(conditon: [key: ["$contains": value]])
    }

    static public func icontains(key: String, value: String) -> Query {
        return Query(conditon: [key: ["$icontains": value]])
    }

    static public func inList(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$in": list]])
    }

    static public func notInList(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$nin": list]])
    }

    static public func arrayContains(key: String, list: [Any]) -> Query {
        return Query(conditon: [key: ["$all": list]])
    }

    static public func isNull(key: String) -> Query {
        return Query(conditon: [key: ["$isnull": true]])
    }

    static public func isNotNull(key: String) -> Query {
        return Query(conditon: [key: ["$isnull": false]])
    }

    static public func exists(key: String) -> Query {
        return Query(conditon: [key: ["$exists": true]])
    }

    static public func notExists(key: String) -> Query {
        return Query(conditon: [key: ["$exists": false]])
    }

    static public func hasKey(key: String, fieldName: String) -> Query {
        return Query(conditon: [key: ["$has_key": fieldName]])
    }

    static public func within(key: String, polygon: GeoPolygon) -> Query {
        return Query(conditon: [key: ["$intersects": polygon.geoJson]])
    }

    static public func include(key: String, point: GeoPoint) -> Query {
        return Query(conditon: [key: ["$intersects": point.geoJson]])
    }

    static public func withinCircle(key: String, point: GeoPoint, radius: Float) -> Query {
        let data: [String: Any] = ["radius": radius, "coordinates": [point.longitude, point.latitude]]
        let dataJson = data as NSDictionary
        return Query(conditon: [key: ["$center": dataJson]])
    }

    static public func withinRegion(key: String, point: GeoPoint, minDistance: Float, maxDistance: Float?) -> Query {
        var data: [String: Any] = ["geometry": point.geoJson, "min_distance": minDistance]
        if let maxDistance = maxDistance {
            data["max_distance"] = maxDistance
        }
        return Query(conditon: [key: ["$nearsphere": data]])
    }
}
