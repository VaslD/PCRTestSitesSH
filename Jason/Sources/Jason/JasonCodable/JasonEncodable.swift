/// 通过 ``Jason`` 实现 `Encodable` 协议。
///
/// 实现此协议的类型只需在编码时构造出 ``Jason``，即可实现 `Encodable` 协议要求，免去手动处理各种 Encoding Container 的繁琐操作。
public protocol JasonEncodable: Encodable {
    func encode() throws -> Jason
}

// MARK: Encodable

public extension JasonEncodable {
    func encode(to encoder: Encoder) throws {
        try self.encode().encode(to: encoder)
    }
}
