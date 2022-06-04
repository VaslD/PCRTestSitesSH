#if canImport(Foundation)
import Foundation
#endif

public extension Jason {
    /// 尝试将此 JSON 转换为 `Bool` 类型。
    ///
    /// 当原始 JSON 为 `true`, `false` 以及它们的文本形式、或者为任何形式的 `0` 和 `1` 时转换都会成功；而数组、字典（对象）和
    /// `null` 都会导致失败。
    ///
    /// > Warning:
    /// 此方法不能用于检查原始 JSON 是否只为 `true` 或 `false`，对应检查请使用 ``rawValue``。
    ///
    /// - Returns: 成功转换的 `Bool` 或 `nil`。
    func asBool() -> Bool? {
        switch self {
        case .array, .dictionary, .empty:
            return nil
        case let .boolean(value):
            return value
        case let .string(value):
            return Bool(value)
        case let .integer(value):
            switch value {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case let .unsigned(value):
            switch value {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case let .float(value):
            switch value {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        }
    }

    /// 尝试将此 JSON 转换为 `String` 类型。
    ///
    /// 当原始 JSON 为 `true`, `false` 或者为字符串、数字时转换都会成功；而数组、字典（对象）和 `null` 都会导致失败。
    ///
    /// > Warning:
    /// 此方法不能用于检查原始 JSON 是否只为 `String`，对应检查请使用 ``rawValue``。
    ///
    /// - Returns: 成功转换的 `String` 或 `nil`。
    func asString() -> String? {
        switch self {
        case .array, .dictionary, .empty:
            return nil
        case let .boolean(value):
            return String(value)
        case let .string(value):
            return value
        case let .integer(value):
            return String(value)
        case let .unsigned(value):
            return String(value)
        case let .float(value):
            return String(value)
        }
    }

    /// 尝试将此 JSON 转换为 `Int` 类型。
    ///
    /// 当原始 JSON 为整数数值时将尝试取值；`true`, `false` 将被转换为 `1` 和 `0`；字符串将尝试解析；而小数数值、`Int`
    /// 越界、数组、字典（对象）和 `null` 都会导致失败。
    ///
    /// > Warning:
    /// 此方法不能用于检查原始 JSON 是否只为 `Int`，对应检查请使用 ``rawValue``。JSON 标准并不区分 `Int`, `UInt` 和 `Double`，因此
    /// JSON 无法完全还原来源的数值类型；有关 Jason 如何决定数值的类型，请阅读 ``integer(_:)``, ``unsigned(_:)``, ``float(_:)``
    /// 枚举成员的文档。
    ///
    /// - Returns: 成功转换的 `Int` 或 `nil`。
    func asInt() -> Int? {
        switch self {
        case .array, .dictionary, .empty:
            return nil
        case let .boolean(value):
            return value ? 1 : 0
        case let .string(value):
            return Int(value)
        case let .integer(value):
            return value
        case let .unsigned(value):
            return Int(exactly: value)
        case let .float(value):
            return Int(exactly: value)
        }
    }

    /// 尝试将此 JSON 转换为 `UInt` 类型。
    ///
    /// 当原始 JSON 为正整数数值时尝试取值；`true`, `false` 将被转换为 `1` 和 `0`；字符串将尝试解析；而小数数值、`UInt`
    /// 越界、数组、字典（对象）和 `null` 都会导致失败。
    ///
    /// > Warning:
    /// 此方法不能用于检查原始 JSON 是否为 `UInt`，对应检查请使用 ``rawValue`` 并检查是否 `Int` 越界。JSON 标准并不区分 `Int`,
    /// `UInt` 和 `Double`，因此 JSON 无法完全还原来源的数值类型；有关 Jason 如何决定数值的类型，请阅读 ``integer(_:)``,
    /// ``unsigned(_:)``, ``float(_:)`` 枚举成员的文档。
    ///
    /// - Returns: 成功转换的 `UInt` 或 `nil`。
    func asUInt() -> UInt? {
        switch self {
        case .array, .dictionary, .empty:
            return nil
        case let .boolean(value):
            return value ? 1 : 0
        case let .string(value):
            return UInt(value)
        case let .integer(value):
            return UInt(exactly: value)
        case let .unsigned(value):
            return value
        case let .float(value):
            return UInt(exactly: value)
        }
    }

    /// 尝试将此 JSON 转换为 `Double` 类型。
    ///
    /// 当原始 JSON 为数值时将尝试取值；`true`, `false` 将被转换为 `1` 和 `0`；字符串将尝试解析；而数组、字典（对象）和
    /// `null` 都会导致失败。
    ///
    /// > Warning:
    /// 此方法不能用于检查原始 JSON 是否只为 `Double`。JSON 标准并不区分 `Int`, `UInt` 和 `Double`，因此 JSON
    /// 无法完全还原来源的数值类型；有关 ``Jason`` 如何决定数值的 Swift 类型，请阅读 ``integer(_:)``, ``unsigned(_:)``,
    /// ``float(_:)`` 枚举成员的文档。
    ///
    /// - Returns: 成功转换的 `Double` 或 `nil`。
    func asDouble() -> Double? {
        switch self {
        case .array, .dictionary, .empty:
            return nil
        case let .boolean(value):
            return value ? 1 : 0
        case let .string(value):
            return Double(value)
        case let .integer(value):
            return Double(value)
        case let .unsigned(value):
            return Double(value)
        case let .float(value):
            return value
        }
    }

#if canImport(Foundation)
    /// 将此 JSON 转换为 `Decodable` 类型。
    ///
    /// > Important:
    /// 不推荐使用此方法转换为 Swift 标准库基本类型（例如 `String`）。请直接从枚举成员中取值，或使用 ``asBool()``, ``asString()``,
    /// ``asInt()``, ``asUInt()``, ``asDouble()`` 方法，因为这些方法包含针对基本类型的特殊处理。
    ///
    /// - Parameters:
    ///   - type: 遵循 `Decodable` 的类型
    ///   - encoder: 编码此 JSON 使用的 `JSONEncoder`
    ///   - decoder: 解码为 `Decodable` 时使用的 `JSONDecoder`
    /// - Returns: 解码后的实例
    func `as`<T: Decodable>(_ type: T.Type, encoder: JSONEncoder = JSONEncoder(),
                            decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data = try encoder.encode(self)
        return try decoder.decode(type, from: data)
    }
#endif

    /// 使用此 JSON 构造任意类型 `T` 的实例。
    ///
    /// - Parameters:
    ///   - transform: 构造方法
    /// - Returns: 构造的实例
    func `as`<T>(_ transform: (Jason) throws -> T) rethrows -> T {
        try transform(self)
    }
}
