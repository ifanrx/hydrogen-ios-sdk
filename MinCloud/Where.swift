//
//  Query.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BaaSWhere)
open class Where: NSObject {

    var conditon: [String: Any]

    @objc public init(conditon: [String: Any]) {
        self.conditon = conditon
        super.init()
    }

    @objc public override init() {
        self.conditon = [:]
        super.init()
    }

    @objc static public func or(wheres: [Where]) -> Where {
        var conditons: [[String: Any]] = []
        for wherearg in wheres {
            conditons.append(wherearg.conditon)
        }
        return Where(conditon: ["$or": conditons])
    }

    @objc static public func and(wheres: [Where]) -> Where {
        var conditons: [[String: Any]] = []
        for wherearg in wheres {
            conditons.append(wherearg.conditon)
        }
        return Where(conditon: ["$and": conditons])
    }

    @objc static public func compare(key: String, operator opt: Operator, value: Any) -> Where {
        var tempValue = value
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
        if let baseRecord = value as? BaseRecord {
            tempValue = baseRecord.Id ?? ""
        }
        return Where(conditon: [key: ["$\(op)": tempValue]])
    }

    @objc static public func matches(key: String, regx: String) -> Where {
        let results = regx.components(separatedBy: "/").filter { !$0.isEmpty }
        assert(results.count == 1 || results.count == 2, "the regx does not match the schema.")

        var regxCondition: [String: Any] = ["$regex": results[0]]

        if results.count == 2 {
            regxCondition["$options"] = results[1]
        }
        return Where(conditon: [key: regxCondition])
    }

    @objc static public func range(key: String, start: Double, end: Double) -> Where {
        return Where(conditon: [key: ["$range": [start, end]]])
    }

    @objc static public func contains(key: String, value: String) -> Where {
        return Where(conditon: [key: ["$contains": value]])
    }

    @objc static public func icontains(key: String, value: String) -> Where {
        return Where(conditon: [key: ["$icontains": value]])
    }

    @objc static public func inList(key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$in": list]])
    }

    @objc static public func notInList(key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$nin": list]])
    }

    @objc static public func arrayContains(key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$all": list]])
    }

    @objc static public func isNull(key: String) -> Where {
        return Where(conditon: [key: ["$isnull": true]])
    }

    @objc static public func isNotNull(key: String) -> Where {
        return Where(conditon: [key: ["$isnull": false]])
    }

    @objc static public func exists(key: String) -> Where {
        return Where(conditon: [key: ["$exists": true]])
    }

    @objc static public func notExists(key: String) -> Where {
        return Where(conditon: [key: ["$exists": false]])
    }

    @objc static public func hasKey(_ key: String, fieldName: String) -> Where {
        return Where(conditon: [key: ["$has_key": fieldName]])
    }

    @objc static public func within(key: String, polygon: GeoPolygon) -> Where {
        return Where(conditon: [key: ["$within": polygon.geoJson]])
    }

    @objc static public func include(key: String, point: GeoPoint) -> Where {
        return Where(conditon: [key: ["$intersects": point.geoJson]])
    }

    @objc static public func withinCircle(key: String, point: GeoPoint, radius: Double) -> Where {
        let data: [String: Any] = ["radius": radius, "coordinates": [point.longitude, point.latitude]]
        let dataJson = data as NSDictionary
        return Where(conditon: [key: ["$center": dataJson]])
    }

    @objc static public func withinRegion(key: String, point: GeoPoint, minDistance: Double, maxDistance: Double) -> Where {
        let data: [String: Any] = ["geometry": point.geoJson, "min_distance": minDistance * 1000, "max_distance": maxDistance * 1000]
        return Where(conditon: [key: ["$nearsphere": data]])
    }
}
