#if canImport(CoreFoundation)
import CoreFoundation
#endif

// MARK: - Jason + RawRepresentable

extension Jason: RawRepresentable {
    /// 通过支持的 Swift 基本类型构造 ``Jason``。
    ///
    /// > Note:
    /// `init(rawValue:)` 需要消耗资源进行类型检查、桥接和转换。 ``Jason`` 提供大量其他构造方法，推荐直接使用字面量 (literal)
    /// 赋值、由编译器决定调用的构造方法，或传入已知 Swift 类型的变量通过 ``boolean(_:)``, ``string(_:)``, ``integer(_:)``,
    /// ``unsigned(_:)``, ``float(_:)`` 等直接构造枚举成员，而非调用 `init(rawValue:)` 方法。
    ///
    /// 此构造方法仅支持以下类型：
    /// - `Jason`：创建原数据拷贝，枚举成员不变。
    /// - `nil` 和 `NSNull`：创建 ``empty`` 成员。
    /// - `Bool`, `ObjCBool`, `CFBoolean`：创建 ``boolean(_:)`` 成员，携带 `Bool` 值。
    /// - `String`, `NSString`：创建 ``string(_:)`` 成员，携带 `String` 值。
    /// - `Int`, `Int8`, `Int16`, `Int32`, `Int64`：创建 ``integer(_:)`` 成员，携带 `Int` 值。
    /// - `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`：创建 ``unsigned(_:)`` 成员，携带 `UInt` 值。
    /// - `Float`, `Float16`, `Float80`：创建 ``float(_:)`` 成员，携带转换为 `Double` 的值。
    /// - `Double`：创建 ``float(_:)`` 成员，携带 `Double` 值。
    /// - `[Jason]`：创建 ``array(_:)`` 成员，携带原数据拷贝，元素不变。
    /// - `[Any]`：按照此列表中支持的类型，尝试将数组中每个元素转换为 ``Jason``。如果成功，创建 ``array(_:)`` 成员携带
    ///   `[Jason]`；任意元素转换失败将导致构造方法整体失败。
    /// - `[String: Jason]`：创建 ``dictionary(_:)`` 成员，携带原数据拷贝，键值不变。
    /// - `[String: Any]`：按照此列表中支持的类型，尝试将字典中每个值转换为 ``Jason``。如果成功，创建 ``dictionary(_:)`` 成员携带
    ///   `[String: Jason]`，保持键不变；任意键值转换失败将导致构造方法整体失败。
    /// - ``JasonEncodable``：尝试编码为 ``Jason``，否则构造失败。
    public init?(rawValue: Any) {
#if canImport(CoreFoundation)
        // CFBoolean 可以同时桥接到 Swift Bool, Int, UInt 类型（as 语法均成功），因此需要提前判断 CFTypeID 处理 CFBoolean。
        let object = rawValue as AnyObject
        if CFGetTypeID(object) == CFBooleanGetTypeID(), let bool = rawValue as? Bool {
            self = .boolean(bool)
            return
        }
#endif

        switch rawValue {
        case Optional<Any>.none:
            self = .empty

        // 部分 NS/CF 整数类型可以桥接到 Swift Bool，必须最后判断 as Bool。
        case let int as Int:
            self = .integer(int)
        case let uint as UInt:
            self = .unsigned(uint)
        case let bool as Bool:
            self = .boolean(bool)

        case let string as String:
            self = .string(string)
        case let float as Float:
            self = .float(Double(float))
        case let double as Double:
            self = .float(double)

        // Jason, [Jason], [String: Jason] 等在此处会被直接包装返回，不再需要深入枚举其中的元素。
        // CGFloat 等常见 Foundation 类型也会被一同特殊处理。
        case let representable as JasonRepresentable:
            self = representable.toJason()

        // 深入（递归）检查 Array 中无法表示的元素将导致失败。
        case let array as [Any]:
            var value = [Jason]()
            for element in array {
                guard let converted = Jason(rawValue: element) else {
                    return nil
                }
                value.append(converted)
            }
            self = .array(value)

        // 深入（递归）检查 Dictionary 中无法表示的元素将导致失败。
        case let dict as [String: Any]:
            var value = [String: Jason]()
            for (key, element) in dict {
                guard let converted = Jason(rawValue: element) else {
                    return nil
                }
                value[key] = converted
            }
            self = .dictionary(value)

        // 实现 `JasonEncodable` 的类型将被尝试编码。
        case let encodable as JasonEncodable:
            guard let value = try? encodable.encode() else {
                return nil
            }
            self = value

        default:
            return nil
        }
    }

    /// 将 ``Jason`` 解包为 Swift 基本类型。
    ///
    /// > Note:
    /// 此方法仅解包原始 JSON 携带的值，并不转换类型或尝试修正显而易见的错误。例如，当原始 JSON 携带文本形式的数字 `"1"`
    /// 时，此方法返回类型为 `String` 而非 `Int` 或 `Bool`。如果需要转换为固定的类型，请使用 ``asBool()``, ``asString()``,
    /// ``asInt()``, ``asUInt()``, ``asDouble()`` 等方法。
    ///
    /// > Important: 当 ``Jason`` 为 ``empty``（原始 JSON 为 `null`）时，此方法返回的值为 `nil`，类型为 `Any? as Any`。
    ///
    /// > Important:
    /// 如果 ``Jason`` 为 ``array(_:)`` 或 ``dictionary(_:)``，此方法将递归解包所有 ``Jason``，返回值中不会包含 ``Jason``
    /// 类型。请预先测试和统计相关使用场景的性能，以避免非预期的复杂数据导致运行时阻塞其他任务。
    ///
    /// > Important:
    /// JSON 标准只有一种数值类型、并不区分 `Int`, `UInt`, `Double`，有关 ``Jason`` 和此方法如何决定 JSON 数值的 Swift 类型，请阅读
    /// ``integer(_:)``, ``unsigned(_:)``, ``float(_:)`` 枚举成员的文档。
    public var rawValue: Any {
        switch self {
        case .empty:
            return Any?.none as Any
        case let .boolean(value):
            return value
        case let .string(value):
            return value
        case let .integer(value):
            return value
        case let .unsigned(value):
            return value
        case let .float(value):
            return value
        case let .array(value):
            return value.map(\.rawValue)
        case let .dictionary(value):
            return value.mapValues(\.rawValue)
        }
    }
}

public extension Jason {
    init?<T: RawRepresentable>(rawValue: T) {
        guard !(T.RawValue.self is T) else {
            return nil
        }
        if let value = Jason(rawValue: rawValue.rawValue) {
            self = value
            return
        }

        return nil
    }

    init?<T: SignedInteger>(rawValue: T) {
        self = .integer(Int(rawValue))
    }

    init?<T: UnsignedInteger>(rawValue: T) {
        self = .unsigned(UInt(rawValue))
    }

    init?<T: BinaryFloatingPoint>(rawValue: T) {
        self = .float(Double(rawValue))
    }
}
