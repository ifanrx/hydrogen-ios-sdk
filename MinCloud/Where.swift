//
//  Query.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

/// 查询语句
@objc(BaaSWhere)
open class Where: NSObject {

    var conditon: [String: Any]

    init(conditon: [String: Any]) {
        self.conditon = conditon
        super.init()
    }

    override init() {
        self.conditon = [:]
        super.init()
    }

    /// 组合查询
    /// - Parameter wheres: 组合多个 where 语句，获取满足其中任何 where 语句的记录
    /// - Returns: 组合后的语句
    @objc static public func or(_ wheres: [Where]) -> Where {
        var conditons: [[String: Any]] = []
        for wherearg in wheres {
            conditons.append(wherearg.conditon)
        }
        return Where(conditon: ["$or": conditons])
    }
    
    /// 组合查询
    /// - Parameter wheres: 组合多个 where 语句，获取满足所有 where 语句的记录
    /// - Returns: 组合后的语句
    @objc static public func and(_ wheres: [Where]) -> Where {
        var conditons: [[String: Any]] = []
        for wherearg in wheres {
            conditons.append(wherearg.conditon)
        }
        return Where(conditon: ["$and": conditons])
    }

    
    /// 比较查询
    /// - Parameters:
    ///   - key: 数据表字段
    ///   - opt: 比较类型 Operator
    ///   - value: 比较值
    /// - Returns: 比较查询语句
    @objc static public func compare(_ key: String, operator opt: Operator, value: Any) -> Where {
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

    
    /// 正则匹配查询
    /// - Parameters:
    ///   - key: 数据表字段
    ///   - regx: 正则表达式，使用的是 JavaScript 的语法规则，请参考 https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp
    /// - Returns: 正则匹配查询语句
    @objc static public func matches(_ key: String, regx: String) -> Where {
        let results = regx.components(separatedBy: "/").filter { !$0.isEmpty }
        assert(results.count == 1 || results.count == 2, "the regx does not match the schema.")

        var regxCondition: [String: Any] = ["$regex": results[0]]

        if results.count == 2 {
            regxCondition["$options"] = results[1]
        }
        return Where(conditon: [key: regxCondition])
    }
    
    /// 范围查询
    /// - Parameters:
    ///   - key: 数据表字段，为 integer 或 number 类型
    ///   - start: 范围左边界
    ///   - end: 范围右边界
    /// - Returns: 范围查询语句
    @objc static public func range(_ key: String, start: Double, end: Double) -> Where {
        return Where(conditon: [key: ["$range": [start, end]]])
    }

    
    /// 字符串查询，返回满足包含相应字符串的记录（区分大小写）
    /// - Parameters:
    ///   - key: 数据表字段，string 类型
    ///   - value: 需查询的字符串
    /// - Returns: 字符串查询语句
    @objc static public func contains(_ key: String, value: String) -> Where {
        return Where(conditon: [key: ["$contains": value]])
    }

    /// 字符串查询，返回满足包含相应字符串的记录（不区分大小写）
    /// - Parameters:
    ///   - key: 数据表字段，string 类型
    ///   - value: 需查询的字符串
    /// - Returns: 字符串查询语句
    @objc static public func icontains(_ key: String, value: String) -> Where {
        return Where(conditon: [key: ["$icontains": value]])
    }
    
    /// 数组查询，数据表中的字段的类型不限制，字段的值含有 list 数组中的一个或多个元素
    /// - Parameters:
    ///   - key: 数据表字段
    ///   - list: 需查询的数组
    /// - Returns: 数组查询语句
    @objc static public func inList(_ key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$in": list]])
    }

    /// 数组查询，字段的值不含有 list 数组中的任何一个元素
    /// - Parameters:
    ///   - key: 数据表字段，类型不限制
    ///   - list: 需查询的数组
    /// - Returns: 数组查询语句
    @objc static public func notInList(_ key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$nin": list]])
    }
    
    /// 数组查询，数据表中的字段的类型必须为数组，字段的值包含 list 数组中每一个元素
    /// 如果希望查找数组中只包含指定数组中所有的值的记录，可以使用 compare 查询
    /// - Parameters:
    ///   - key: 数据表字段，array 类型
    ///   - list: 需查询的数组
    /// - Returns: 数组查询语句
    @objc static public func arrayContains(_ key: String, list: [Any]) -> Where {
        return Where(conditon: [key: ["$all": list]])
    }

    
    /// 空查询，字段值为 null 的记录
    /// - Parameter key: 数据表字段
    /// - Returns: 空查询语句
    @objc static public func isNull(_ key: String) -> Where {
        return Where(conditon: [key: ["$isnull": true]])
    }
    
    /// 非空查询，字段值非 null 的记录
    /// - Parameter key: 数据表字段
    /// - Returns: 非空查询语句
    @objc static public func isNotNull(_ key: String) -> Where {
        return Where(conditon: [key: ["$isnull": false]])
    }

    /// 非空查询，字段值存在的记录
    /// - Parameter key: 数据表字段
    /// - Returns: 非空查询语句
    @objc static public func exists(_ key: String) -> Where {
        return Where(conditon: [key: ["$exists": true]])
    }

    /// 空查询，字段值不存在的记录
    /// - Parameter key: 数据表字段
    /// - Returns: 非空查询语句
    @objc static public func notExists(_ key: String) -> Where {
        return Where(conditon: [key: ["$exists": false]])
    }

    
    /// 获取 object 类型的字段内存在 fieldName 属性的记录。
    /// - Parameters:
    ///   - key: 数据表字段，且该字段为 object。
    ///   - fieldName: object 内的属性名称，只能包含字母、数字和下划线，必须以字母开头
    /// - Returns: where 语句
    /// 假设数据表有如下数据行
    /// [
    ///    {
    ///         id: '59a3c2b5afb7766a5ec6e84e',
    ///          name: '战争与和平',
    ///          publisherInfo: {
    ///          name: 'abc出版社',
    ///         },
    ///     },
    ///     {
    ///         id: '59a3c2b5afb7766a5ec6e84g',
    ///         name: '西游记',
    ///         publisherInfo: {
    ///         name: 'efg出版社',
    ///         location: '广东省广州市天河区五山路 100 号'
    ///         },
    ///     },
    /// ]
    /// 查询字段 publisherInfo 中存在 location 属性的数据行
    /// Where.hasKey("publisherInfo", fieldName: "location")
    /// [
    ///    {
    ///         id: '59a3c2b5afb7766a5ec6e84g',
    ///         name: '西游记',
    ///         publisherInfo: {
    ///         abc: {
    ///         name: 'efg出版社',
    ///         location: '广东省广州市天河区五山路 100 号'
    ///         }
    ///      },
    ///     }
    /// ]
    @objc static public func hasKey(_ key: String, fieldName: String) -> Where {
        return Where(conditon: [key: ["$has_key": fieldName]])
    }

    @objc static public func within(_ key: String, polygon: GeoPolygon) -> Where {
        return Where(conditon: [key: ["$within": polygon.geoJson]])
    }

    /// 在指定多边形集合中找出包含某一点的多边形
    @objc static public func include(_ key: String, point: GeoPoint) -> Where {
        return Where(conditon: [key: ["$intersects": point.geoJson]])
    }

    /// 在指定点集合中，查找包含在指定圆心和指定半径所构成的圆形区域中的点，半径单位为 千米(km), (返回结果随机排序)
    @objc static public func withinCircle(_ key: String, point: GeoPoint, radius: Double) -> Where {
        let data: [String: Any] = ["radius": radius, "coordinates": [point.longitude, point.latitude]]
        let dataJson = data as NSDictionary
        return Where(conditon: [key: ["$center": dataJson]])
    }

    /// 在指定点集合中，查找包含在以指定点为圆点，以最大和最小距离为半径，所构成的圆环区域中的点。半径单位为千米(km)。（返回结果按从近到远排序）
    @objc static public func withinRegion(_ key: String, point: GeoPoint, minDistance: Double, maxDistance: Double) -> Where {
        let data: [String: Any] = ["geometry": point.geoJson, "min_distance": minDistance * 1000, "max_distance": maxDistance * 1000]
        return Where(conditon: [key: ["$nearsphere": data]])
    }
}
