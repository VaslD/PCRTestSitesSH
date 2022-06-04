#if canImport(Foundation)
import Foundation
#endif

#if canImport(Foundation)
public extension JSONSerialization {
    /// 检查输入是否合法 JSON。此方法返回 `true` 时，序列化必须指定 `JSONSerialization.WritingOptions.fragmentsAllowed`。
    ///
    /// > Warning: 与 `JSONSerialization.isValidJSONObject(_:)` 不同，此方法对于不是 JSON **对象**但仍然是合法 JSON 的输入返回
    ///   `true`。使用 `JSONSerialization` 编码指定输入时，必须同时指定
    ///   `JSONSerialization.WritingOptions.fragmentsAllowed`，否则将导致崩溃。
    ///
    /// - Parameter fragment: 任意基本类型实例。
    /// - Returns: 此实例可否被编码为合法 JSON。
    static func isValidJSONFragment(_ fragment: Any) -> Bool {
        if JSONSerialization.isValidJSONObject(fragment) {
            return true
        }
        switch fragment {
        case is Bool:
            return true
        case is String:
            return true
        case is Int:
            return true
        case is UInt:
            return true
        case is Double:
            return true
        default:
            return false
        }
    }
}
#endif
