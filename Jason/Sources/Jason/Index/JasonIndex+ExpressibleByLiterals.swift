// MARK: - JasonIndex + ExpressibleByStringLiteral

extension JasonIndex: ExpressibleByStringLiteral {
    /// 支持通过字符串表达式（例如 `"someString"`）创建 ``property(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``property(_:)`` 成员手动构造 ``JasonIndex``。
    ///
    /// - Parameter value: `String` 字面量
    public init(stringLiteral value: String) {
        self = .property(value)
    }
}

public extension JasonIndex {
    /// 通过 `String` 创建 ``property(_:)`` 的快捷方法。
    init(_ property: String) {
        self = .property(property)
    }

    /// 通过 `String?` 创建 ``property(_:)`` 的快捷方法。
    init(_ property: String?) {
        guard let string = property else {
            self = .invalid
            return
        }
        self = .property(string)
    }
}

// MARK: - JasonIndex + ExpressibleByIntegerLiteral

extension JasonIndex: ExpressibleByIntegerLiteral {
    /// 支持通过整数表达式（例如 `0`）创建 ``element(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``element(_:)`` 成员手动构造 ``JasonIndex``。
    ///
    /// - Parameter value: `Int` 表达式
    public init(integerLiteral value: Int) {
        self = .element(value)
    }
}

public extension JasonIndex {
    /// 通过 `Int` 创建 ``element(_:)`` 的快捷方法。
    init(_ element: Int) {
        self = .element(element)
    }

    /// 通过 `UInt` 创建 ``element(_:)`` 的快捷方法。
    init(_ element: UInt) {
        self = .element(Int(element))
    }

    /// 通过 `Int?` 创建 ``element(_:)`` 的快捷方法。
    init(_ element: Int?) {
        guard let int = element else {
            self = .invalid
            return
        }
        self = .element(int)
    }

    /// 通过 `UInt?` 创建 ``element(_:)`` 的快捷方法。
    init(_ element: UInt?) {
        guard let int = element else {
            self = .invalid
            return
        }
        self = .element(Int(int))
    }
}
