/// ``Jason`` 下标、解析、映射等方法需要的索引。此枚举用于提供 `String` 和 `Int` 混合索引支持。
///
/// ``JasonIndex`` 也可作为通用的 `CodingKey`。
public enum JasonIndex: Equatable, Hashable {
    /// 无效索引常量。
    public static let invalid = Self.element(-1)

    /// 属性索引。例如，对象属性或字典的键。
    ///
    /// 作为 `CodingKey` 时，表示在当前层级中，通过 `String` 键查询到一个对应的层级并前往该层级。 通常用于从 JSON Object
    /// 中取出嵌套的 JSON。
    case property(String)

    /// 元素索引。例如，元组或数组在某个位置的元素。
    ///
    /// 作为 `CodingKey` 时，表示在当前集合中，找到第 N (`Int`) 个实体，前往该层级。通常用于从 JSON Array 中取出嵌套的 JSON。
    case element(Int)

    // MARK: Deprecations

    /// `KodingKey.key(_:)` 已被移除，请使用 ``property(_:)``。
    @available(*, unavailable, renamed: "property(_:)")
    case key(String)

    /// `KodingKey.index(_:)` 已被移除，请使用 ``element(_:)``。
    @available(*, unavailable, renamed: "element(_:)")
    case index(Int)
}
