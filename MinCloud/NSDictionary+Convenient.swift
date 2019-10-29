//
//  NSDictionary+Convenient.swift
//  ifanr
//
//  Created by catch on 15/11/28.
//  Copyright © 2015年 ifanr. All rights reserved.
//

import Foundation

// MARK: - 字典取值
extension NSDictionary {
    func getBool(_ keys: String..., defaultValue: Bool = false) -> Bool {
        for key in keys {
            if let result = self[key] as? Bool {
                return result
            }
        }
        return defaultValue
    }

    func getDouble(_ keys: String..., defaultValue: Double = 0.0, minValue: Double? = nil, maxValue: Double? = nil) -> Double {
        for key in keys {
            if var result = self[key] as? Double {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getInt(_ keys: String..., defaultValue: Int = 0, minValue: Int? = nil, maxValue: Int? = nil) -> Int {
        for key in keys {
            if var result = self[key] as? Int {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getInt64(_ keys: String..., defaultValue: Int64 = 0, minValue: Int64? = nil, maxValue: Int64? = nil) -> Int64 {
        for key in keys {
            if var result = self[key] as? Int64 {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getString(_ keys: String..., defaultValue: String? = nil) -> String? {
        for key in keys {
            if let result = self[key] as? String {
                return result
            }
        }
        return defaultValue
    }

    func getDict(_ keys: String..., defaultValue: NSDictionary? = nil) -> NSDictionary? {
        for key in keys {
            if let result = self[key] as? NSDictionary {
                return result
            }
        }
        return defaultValue
    }

    func getArray<T>(_ keys: String..., type: T.Type) -> [T] {
        for key in keys {
            if let result = self[key] as? [T] {
                return result
            }
        }
        return []
    }

    var toJsonString: String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return "{}"
    }
}

extension Dictionary where Key == String {

    func getBool(_ keys: String..., defaultValue: Bool = false) -> Bool {
        for key in keys {
            if let result = self[key] as? Bool {
                return result
            }
        }
        return defaultValue
    }

    func getDouble(_ keys: String..., defaultValue: Double = 0.0, minValue: Double? = nil, maxValue: Double? = nil) -> Double {
        for key in keys {
            if var result = self[key] as? Double {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            } else if let resultStr = self[key] as? String, var result = Double(resultStr) {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getInt(_ keys: String..., defaultValue: Int = 0, minValue: Int? = nil, maxValue: Int? = nil) -> Int {
        for key in keys {
            if var result = self[key] as? Int {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            } else if let resultStr = self[key] as? String, var result = Int(resultStr) {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getInt64(_ keys: String..., defaultValue: Int64 = 0, minValue: Int64? = nil, maxValue: Int64? = nil) -> Int64 {
        for key in keys {
            if var result = self[key] as? Int64 {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            } else if let resultStr = self[key] as? String, var result = Int64(resultStr) {
                if let minValue = minValue {
                    result = Swift.max(minValue, result)
                }
                if let maxValue = maxValue {
                    result = Swift.min(maxValue, result)
                }
                return result
            }
        }
        return defaultValue
    }

    func getString(_ keys: String..., defaultValue: String? = nil) -> String? {
        for key in keys {
            if let result = self[key] as? String {
                return result
            } else if let result = self[key] as? Int {
                return String(result)
            } else if let result = self[key] as? Int64 {
                return String(result)
            }
        }
        return defaultValue
    }

    func getDict(_ keys: String..., defaultValue: NSDictionary? = nil) -> NSDictionary? {
        for key in keys {
            if let result = self[key] as? NSDictionary {
                return result
            } else if let resultStr = self[key] as? String {
                let result = convertStringToDictionary(text: resultStr)
                return result
            }
        }
        return defaultValue
    }

    func getOptionalObject<T>(_ keys: String..., type: T.Type, defaultValue: T? = nil) -> T? {
        for key in keys {
            if let result = self[key] as? T {
                return result
            }
        }
        return defaultValue
    }

    func getObject<T>(_ keys: String..., type: T.Type, defaultValue: T) -> T {
        for key in keys {
            if let result = self[key] as? T {
                return result
            }
        }
        return defaultValue
    }

    func getArray<T>(_ keys: String..., type: T.Type) -> [T] {
        for key in keys {
            if let result = self[key] as? [T] {
                return result
            }
        }
        return []
    }

    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// :param dictionaries A comma seperated list of dictionaries
    mutating func merge<K, V>(_ dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                if let v = value as? Value, let k = key as? Key {
                    self.updateValue(v, forKey: k)
                }
            }
        }
    }

    var toJsonString: String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return "{}"
    }

    func convertStringToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func jsonValue() -> [String: Any] {
        var newDict: [String: Any] = [:]
        for (key, value) in self {
            if let baseRecord = value as? BaseRecord {
                newDict[key] = baseRecord.Id
            } else if let point = value as? GeoPoint {
                newDict[key] = point.geoJson
            } else if let polygon = value as? GeoPolygon {
                newDict[key] = polygon.geoJson
            } else if let pointArray = value as? [GeoPoint] {
                var pointValues: [[String: Any]] = []
                for point in pointArray {
                    pointValues.append(point.geoJson)
                }
                newDict[key] = pointValues
            } else if let polygonArray = value as? [GeoPolygon] {
                var polygonValues: [[String: Any]] = []
                for polygon in polygonArray {
                    polygonValues.append(polygon.geoJson)
                }
                newDict[key] = polygonValues
            } else if let file  = value as? File {
                newDict[key] = file.fileInfo
            } else if let arrayFile = value as? [File] {
                var fileValues: [[String: Any]] = []
                for file in arrayFile {
                    fileValues.append(file.fileInfo)
                }
                newDict[key] = fileValues
            }
            else {
                newDict[key] = value
            }
        }
        return newDict
    }
}
