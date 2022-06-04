// MARK: - Jason + ExpressibleByNilLiteral

extension Jason: ExpressibleByNilLiteral {
    /// 支持通过 `nil` 表达式创建 ``empty``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``empty`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter nilLiteral: `nil` 字面量
    public init(nilLiteral: ()) {
        self = .empty
    }
}

// MARK: - Jason + ExpressibleByStringLiteral, ExpressibleByStringInterpolation

extension Jason: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// 支持通过字符串表达式（例如 `"someString"`）创建 ``string(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``string(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter value: `String` 字面量
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

// MARK: - Jason + ExpressibleByIntegerLiteral

extension Jason: ExpressibleByIntegerLiteral {
    /// 支持通过整数表达式（例如 `0`）创建 ``integer(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``integer(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter value: `Int` 表达式
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

// MARK: - Jason + ExpressibleByFloatLiteral

extension Jason: ExpressibleByFloatLiteral {
    /// 支持通过浮点数表达式（例如 `0.0`）创建 ``float(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``float(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter value: `Double` 表达式
    public init(floatLiteral value: Double) {
        self = .float(value)
    }
}

// MARK: - Jason + ExpressibleByBooleanLiteral

extension Jason: ExpressibleByBooleanLiteral {
    /// 支持通过布尔表达式（例如 `true`）创建 ``boolean(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``boolean(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter value: `Bool` 表达式
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

// MARK: - Jason + ExpressibleByArrayLiteral

extension Jason: ExpressibleByArrayLiteral {
    /// 支持通过数组表达式（例如 `[some, element]`）创建 ``array(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``array(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter elements: `[Jason]` 表达式
    public init(arrayLiteral elements: Jason...) {
        self = .array(elements)
    }
}

// MARK: - Jason + ExpressibleByDictionaryLiteral

extension Jason: ExpressibleByDictionaryLiteral {
    /// 支持通过字典表达式（例如 `[some: element]`）创建 ``dictionary(_:)``。
    ///
    /// > Warning: 此方法只能被编译器调用，请勿手动调用此方法！如有需要，必须使用 ``dictionary(_:)`` 成员手动构造 ``Jason``。
    ///
    /// - Parameter elements: `[String: Jason]` 表达式
    public init(dictionaryLiteral elements: (String, Jason)...) {
        self = .dictionary([String: Jason](uniqueKeysWithValues: elements))
    }
}
