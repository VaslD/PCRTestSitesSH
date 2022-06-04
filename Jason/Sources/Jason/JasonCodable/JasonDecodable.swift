/// 通过 ``Jason`` 实现 `Decodable` 协议。
///
/// 实现此协议的类型只需通过 ``Jason`` 构造出实例，即可实现 `Decodable` 协议要求，免去手动处理各种 Decoding Container 的繁琐操作。
public protocol JasonDecodable: Decodable {
    init(from object: Jason) throws
}

// MARK: Decodable

public extension JasonDecodable {
    init(from decoder: Decoder) throws {
        let object = try Jason(from: decoder)
        try self.init(from: object)
    }
}
