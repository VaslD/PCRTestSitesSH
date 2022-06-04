/// Jason 是包含所有 [JSON](https://www.json.org/json-zh.html) 标准类型的枚举。
///
/// Jason 的设计目的侧重于表达 (modeling) 而非转码 (serialization)，因此 Jason 仅提供基本的 JSON
/// 编码能力，但其实现了大量 Swift 标准库协议以便编程时存取和交换 JSON 结构的数据。
public enum Jason: Hashable {
    /// 表示 JSON 标准中的 `null` 值。
    ///
    /// 得益于 `ExpressibleByNilLiteral`，Swift 允许使用 `nil` 语法表示此枚举成员。注意这样使用时，`nil` 的类型仍然是
    /// `Jason`（而非 `Jason?`），也不能与其他类型的 `nil`（例如 `String?.none`）作比较。
    ///
    /// ```swift
    /// let x: Jason = nil
    /// XCTAssertNotNil(x)
    /// XCTAssert(x == nil)
    /// XCTAssert(x == .empty)
    /// ```
    case empty

    /// 表示 JSON 标准中的 `true` 和 `false` 值。
    ///
    /// > Note: JSON 标准没有定义**布尔**类型，而是将 `true` 和 `false` 语法定义为独立的值。
    ///
    /// 得益于 `ExpressibleByBooleanLiteral`，Swift 允许使用 `true` 和 `false` 语法表示此枚举成员。
    ///
    /// ```swift
    /// let x: Jason = true
    /// let y: Jason = false
    /// XCTAssert(x == true)
    /// XCTAssert(y == false)
    /// XCTAssertNotEqual(x, y)
    /// ```
    case boolean(Bool)

    /// 表示 JSON 标准中的 `String` 类型，即一连串一个或多个 Unicode 字符。
    ///
    /// 得益于 `ExpressibleByStringLiteral` 和 `ExpressibleByStringInterpolation`，Swift 允许使用 `""` 和 `"\()"`
    /// 语法表示此枚举成员。
    ///
    /// ```swift
    /// let a: Jason = "A string!"
    /// let b: Jason = "🤣"
    /// let c: Jason = ""
    /// let d: Jason = "\(Int.zero)"
    /// XCTAssert(a == "A string!")
    /// XCTAssert(b == "🤣")
    /// XCTAssert(c == "")
    /// XCTAssert(d == "0")
    /// ```
    case string(String)

    /// 表示 JSON 标准中的带符号整数。
    ///
    /// > Important:
    /// JSON 标准没有定义**整数**类型。JSON 仅有一种数值类型，用于表示任意十进制数字、同时支持整数和小数且没有上下限规定。当 JSON
    /// 中的数字符合 Swift 中 `Int` 的范围时，将被优先转换为 ``integer(_:)`` 枚举成员。此枚举成员与 ``unsigned(_:)``.
    /// ``float(_:)`` 的等价性基于数学比较和 IEEE 754 浮点数定义；序列化时三者可能输出相同的 JSON，这种做法符合 JSON 标准。
    ///
    /// 得益于 `ExpressibleByIntegerLiteral`，Swift 允许使用整数表示此枚举成员。
    ///
    /// ```swift
    /// let a: Jason = 0
    /// let b: Jason = 2147483647
    /// XCTAssert(a == 0)
    /// XCTAssert(b == 2147483647)
    /// ```
    case integer(Int)

    /// 表示 JSON 标准中的无符号整数。
    ///
    /// > Important:
    /// JSON 标准没有定义**整数**类型。JSON 仅有一种数字类型，用于表示任意十进制数字，同时支持整数和小数且没有上下限规定。仅当 JSON
    /// 中的数字符合 Swift 中 `UInt` 的范围且无法用 `Int` 表示时，将被转换为此枚举成员。此枚举成员与 ``integer(_:)``,
    /// ``float(_:)`` 的等价性基于数学比较和 IEEE 754 浮点数定义；序列化时三者可能输出相同的 JSON。
    ///
    /// 此枚举成员无法直接使用字面量 (literal) 表示，必须声明 ``unsigned(_:)`` 或传递 `UInt` 给 `init(rawValue:)` 构造。
    ///
    /// ```swift
    /// let e: Jason = .unsigned(18446744073709551615)
    /// XCTAssert(e == .unsigned(UInt.max))
    /// ```
    case unsigned(UInt)

    /// 表示 JSON 标准中的小数（IEEE 754 浮点数）。
    ///
    /// > Important:
    /// JSON 标准没有定义**浮点数**类型。JSON 仅有一种数字类型，用于表示任意十进制数字，同时支持整数和小数且没有上下限规定。仅当 JSON
    /// 中的数字符合 Swift 中 `Double` 的范围且无法用 `Int`, `UInt` 表示时，将被转换为此枚举成员。此枚举成员与 ``integer(_:)``,
    /// ``unsigned(_:)`` 的等价性基于数学比较和 IEEE 754 浮点数定义；序列化时三者可能输出相同的 JSON。
    ///
    /// 得益于 `ExpressibleByFloatLiteral`，Swift 允许使用小数表示此枚举成员。
    ///
    /// ```swift
    /// let c: Jason = 0.0
    /// let d: Jason = 0.30000000000000004
    /// XCTAssert(c == 0)
    /// XCTAssert(d == 0.30000000000000003)
    /// ```
    case float(Double)

    /// 表示 JSON 标准中的 `Array`，即按照顺序排列的零个或多个值。
    ///
    /// 得益于 `ExpressibleByArrayLiteral`，Swift 允许使用 `[]` 语法表示此枚举成员。
    ///
    /// ```swift
    /// let x: Jason = []
    /// let y: Jason = [false, "1", 2.0, true, 4, nil]
    /// XCTAssert(x == [])
    /// XCTAssert(y == [false, "1", 2, true, 4.0, nil])
    /// ```
    case array([Jason])

    /// 表示 JSON 标准中的 `Object`，即无序的零个或多个键值组合。
    ///
    /// 得益于 `ExpressibleByDictionaryLiteral`，Swift 允许使用 `[:]` 语法表示此枚举成员。
    ///
    /// ```swift
    /// let x: Jason = [:]
    /// let y: Jason = [
    ///     "A": "a",
    ///     "B": 2,
    ///     "Cc": false,
    ///     "d": ["D"],
    ///     "é": nil
    /// ]
    /// XCTAssert(x == [:])
    /// XCTAssert(y == [
    ///     "A": "a",
    ///     "B": 2.0,
    ///     "Cc": false,
    ///     "d": ["D"],
    ///     "é": .empty
    /// ])
    /// ```
    case dictionary([String: Jason])
}
