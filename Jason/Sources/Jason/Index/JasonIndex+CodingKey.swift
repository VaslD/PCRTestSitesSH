extension JasonIndex: CodingKey {
    /// 将 ``JasonIndex`` 转换为字符串 `CodingKey`。通常用于键值容器。
    ///
    /// 此属性将取出 ``property(_:)`` 中的字符串，或将 ``element(_:)`` 中的数值转换为字符串表示形式。
    public var stringValue: String {
        switch self {
        case let .property(string):
            return string
        case let .element(int):
            return String(int)
        }
    }

    /// 将 ``JasonIndex`` 转换为整数 `CodingKey`。通常用于有序容器。
    ///
    /// 此属性将取出 ``element(_:)`` 中的整数，或将 ``property(_:)`` 中的字符串解析为整数，失败将返回空值。
    public var intValue: Int? {
        switch self {
        case let .property(string):
            return Int(string)
        case let .element(int):
            return int
        }
    }

    /// 通过整数构造 ``element(_:)``。
    ///
    /// - Parameter intValue: 整数索引
    public init(intValue: Int) {
        self = .element(intValue)
    }

    /// 通过字符串构造 ``property(_:)``。
    ///
    /// - Parameter stringValue: 文本索引
    public init(stringValue: String) {
        self = .property(stringValue)
    }
}
