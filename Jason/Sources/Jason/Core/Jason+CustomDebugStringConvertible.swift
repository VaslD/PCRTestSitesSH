extension Jason: CustomDebugStringConvertible {
    /// 序列化此 ``Jason`` 实例为文本形式的 JSON。
    ///
    /// 此方法仅用于调试输出，请使用 JSON 序列化框架将 ``Jason`` 转换为 JSON 数据。
    ///
    /// > Note: 在 DEBUG 编译配置下，此方法输出经过键排序和缩进格式化的 JSON。
    public var debugDescription: String {
        switch self {
        case .empty:
            return "null"
        case let .boolean(value):
            return String(value)
        case let .string(value):
            var escaped = value.replacingOccurrences(of: "\"", with: "\\\"")
            escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
            return "\"\(escaped)\""
        case let .integer(value):
            return String(value)
        case let .unsigned(value):
            return String(value)
        case let .float(value):
            return String(value)
        case let .array(value):
            if value.isEmpty {
                return "[]"
            }
#if DEBUG
            let children = value.map { String(describing: $0) }.joined(separator: ",\n")
                .split(separator: "\n").map { "  \($0)" }.joined(separator: "\n")
            return "[\n\(children)\n]"
#else
            return "[\(value.map { String(describing: $0) }.joined(separator: ","))]"
#endif
        case let .dictionary(value):
            if value.isEmpty {
                return "{}"
            }
#if DEBUG
            let dictionary = value.sorted { $0.key < $1.key }
            let children = dictionary.map { "\"\($0)\": \(String(describing: $1))" }.joined(separator: ",\n")
                .split(separator: "\n").map { "  \($0)" }.joined(separator: "\n")
            return "{\n\(children)\n}"
#else
            return "{\(value.map { "\"\($0)\":\(String(describing: $1))" }.joined(separator: ","))}"
#endif
        }
    }
}
