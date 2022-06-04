#if canImport(Foundation)
import Foundation
#endif

#if canImport(Foundation)
public extension JSONEncoder {
    /// 使用当前已配置的 `JSONEncoder` 将 `Encodable` 转换为 ``Jason``。
    ///
    /// > Note:
    /// `Encodable` 不能直接转换为 ``Jason``，因为调用者可能希望更改属性命名规则、时间戳起始日期等编码设置。在配置 `JSONEncoder`
    /// 之后，使用此方法将 `Encodable` 转换为 ``Jason``。
    ///
    /// - Parameter value: 遵循 `Encodable` 的类型实例
    /// - Returns: 当前 `JSONEncoder` 编码后的 JSON 模型
    func encodeJason<T: Encodable>(_ value: T) throws -> Jason {
        try Jason.deserialize(self.encode(value))
    }
}
#endif
