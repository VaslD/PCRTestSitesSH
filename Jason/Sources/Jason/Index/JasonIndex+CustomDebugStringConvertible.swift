extension JasonIndex: CustomDebugStringConvertible {
    /// 调试输出数组下标表达式（例如 `[0]`）或字典下标表达式（例如 `["key"]`）。
    public var debugDescription: String {
        switch self {
        case let .element(int):
            return "[\(int)]"

        case let .property(string):
            return "[\"\(string)\"]"
        }
    }
}
