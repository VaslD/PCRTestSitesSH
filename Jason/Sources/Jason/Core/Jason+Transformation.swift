public extension Jason {
    /// 将 ``Jason`` 映射为任意类型 `T` 的数组。
    ///
    /// > Note: 此方法将保留空值。如果只希望获取映射后非空的元素，使用 ``compactMap(_:)``。
    ///
    /// 此方法工作原理如下：
    /// - 对于 ``array(_:)`` 中的每一个元素执行映射，索引为 ``JasonIndex/element(_:)``，返回新元素数值。
    /// - 对于 ``dictionary(_:)`` 中**以键递增排序**后的每一个键值对执行映射，索引为 ``JasonIndex/property(_:)``，返回新值数组。
    /// - 对于其他成员执行映射闭包，索引为 ``JasonIndex/invalid``，返回包含结果的单元素数组。
    ///
    /// > Note: 由于字典无序，此方法对字典进行键递增排序以保证多次调用输出稳定。
    ///
    /// - Parameters:
    ///   - transform: 映射方式闭包
    ///   - index: 正在执行映射的元素索引，请阅读 ``JasonIndex`` 文档
    ///   - value: 正在执行映射的 ``Jason`` 元素
    /// - Returns: 映射后的数组
    func map<T>(_ transform: (_ index: JasonIndex, _ value: Jason) throws -> T) rethrows -> [T] {
        switch self {
        case let .array(array):
            return try array.enumerated().map { try transform(.element($0.offset), $0.element) }
        case let .dictionary(dict):
            return try dict.sorted { $0.key < $1.key }.map { try transform(.property($0.key), $0.value) }
        default:
            return try [transform(.invalid, self)]
        }
    }

    /// 将 ``Jason`` 映射为任意类型 `T` 的数组，并在映射过程中丢弃空值。
    ///
    /// 此方法工作原理如下：
    /// - 对于 ``array(_:)`` 中的每一个元素执行映射，索引为 ``JasonIndex/element(_:)``，返回非空元素数值。
    /// - 对于 ``dictionary(_:)`` 中**以键递增排序**后的每一个键值对执行映射，索引为 ``JasonIndex/property(_:)``，返回非空值数组。
    /// - 对于其他成员执行映射闭包，索引为 ``JasonIndex/invalid``，返回包含非空结果的单元素数组、或空数组。
    ///
    /// > Note: 由于字典无序，此方法对字典进行键递增排序以保证多次调用输出稳定。
    ///
    /// - Parameters:
    ///   - transform: 映射方式闭包
    ///   - index: 正在执行映射的元素索引，请阅读 ``JasonIndex`` 文档
    ///   - value: 正在执行映射的 ``Jason`` 元素
    /// - Returns: 映射后的数组
    func compactMap<T>(_ transform: (_ index: JasonIndex, _ value: Jason) throws -> T?) rethrows -> [T] {
        switch self {
        case let .array(array):
            return try array.enumerated().compactMap { try transform(.element($0.offset), $0.element) }
        case let .dictionary(dict):
            return try dict.compactMap { try transform(.property($0.key), $0.value) }
        default:
            return try transform(.invalid, self).flatMap { [$0] } ?? []
        }
    }
}
