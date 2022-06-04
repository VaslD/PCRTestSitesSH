#if canImport(Foundation)
import Foundation
#endif

#if canImport(Foundation)
public extension Jason {
    /// 序列化 ``Jason`` 为 JSON 数据。
    ///
    /// 此方法使用 `JSONSerialization` 将 ``Jason`` 转换为 JSON 数据。由于不需要经过 Codable 框架的容器机制，此方法比使用
    /// `JSONEncoder` 更快。
    ///
    /// > Note: 在 DEBUG 编译配置下，此方法输出经过键排序和缩进格式化的 JSON。
    ///
    /// - Returns: UTF-8 编码的 JSON 字符串数据
    func serialize() throws -> Data {
        let raw = self.rawValue
        guard JSONSerialization.isValidJSONFragment(raw) else {
            throw JasonError.inconvertible
        }
#if DEBUG
        let options: JSONSerialization.WritingOptions = [.fragmentsAllowed, .sortedKeys, .prettyPrinted]
#else
        let options: JSONSerialization.WritingOptions = [.fragmentsAllowed]
#endif
        return try JSONSerialization.data(withJSONObject: raw, options: options)
    }

    /// 序列化输入并返回新的 ``Jason/Jason/string(_:)`` 包含序列化的 JSON 文本。
    ///
    /// 此方法通常用于在键值中嵌套 JSON。由于类型和层级限制嵌套的 JSON 必须以文本形式存储。
    ///
    /// > Important: 使用默认参数时，即使输入 ``Jason/Jason/string(_:)``，输出的 ``Jason/Jason`` 仍然会被二次嵌套。例如：输入
    ///   `"abc"`，此方法将输出 `Jason.string("\"abc\"")`。通过 `serializeStringAsIs` 参数调整此行为。
    ///
    /// > Note: 与 ``Jason/Jason/serialize()`` 不同，此方法在 DEBUG 编译配置下仍然会对嵌套的 JSON 进行键排序，但不会进行格式化。
    ///
    /// - Parameters:
    ///   - value: 待序列化的 ``Jason/Jason`` 实例。
    ///   - serializeStringAsIs: 当输入为 ``Jason/Jason/string(_:)`` 时直接输出。默认为 `false`，表示输入总是会被嵌套。
    /// - Returns: 新的 ``Jason/Jason`` 实例，此实例保证为 ``Jason/Jason/string(_:)`` 枚举成员。
    static func serialized(_ value: Jason, serializeStringAsIs: Bool = false) throws -> Jason {
        if serializeStringAsIs, case .string = value {
            return value
        }
        let raw = value.rawValue
        guard JSONSerialization.isValidJSONFragment(raw) else {
            throw JasonError.inconvertible
        }
#if DEBUG
        let options: JSONSerialization.WritingOptions = [.fragmentsAllowed, .sortedKeys]
#else
        let options: JSONSerialization.WritingOptions = [.fragmentsAllowed]
#endif
        let data = try JSONSerialization.data(withJSONObject: raw, options: options)
        guard let string = String(data: data, encoding: .utf8) else {
            throw JasonError.inconvertible
        }
        return .string(string)
    }

    /// 解析 JSON 数据并构造 ``Jason``。
    ///
    /// 此方法使用 `JSONSerialization` 读取和解析 JSON 数据。由于不需要经过 Codable 框架的容器机制，此方法比使用
    /// `JSONDecoder` 快至少 10 倍。在支持的系统上，此方法允许解析 JSON 5 语法。
    ///
    /// - Parameter data: JSON 数据
    /// - Returns: JSON 对应的 ``Jason`` 实例
    static func deserialize(_ data: Data) throws -> Jason {
        guard !data.isEmpty else {
            return .empty
        }

        var options: JSONSerialization.ReadingOptions = .fragmentsAllowed
#if compiler(>=5.5.2)
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, macCatalyst 15.0, *) {
            options.formUnion(.json5Allowed)
        }
#endif
#endif
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        guard let result = Jason(rawValue: object) else {
            throw JasonError.inconvertible
        }
        return result
    }

    /// 解析 JSON 字符串并构造 ``Jason``。
    ///
    /// 此方法使用 `JSONSerialization` 读取和解析 JSON 数据。由于不需要经过 Codable 框架的容器机制，此方法比使用
    /// `JSONDecoder` 快约 10 倍。
    ///
    /// - Parameter string: JSON 字符串
    /// - Returns: JSON 对应的 ``Jason`` 实例
    static func deserialize(_ string: String) throws -> Jason {
        guard !string.isEmpty else {
            return .empty
        }

        guard let data = string.data(using: .utf8) else {
            throw JasonError.inconvertible
        }
        return try Self.deserialize(data)
    }
}
#endif
