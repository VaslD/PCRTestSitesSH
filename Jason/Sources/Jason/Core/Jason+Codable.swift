// MARK: - Jason + Encodable

extension Jason: Encodable {
    /// 将 ``Jason`` 放入 `Encoder`。
    ///
    /// 此方法工作原理如下：
    /// - 当前为 ``empty`` 则显性放入 `nil` (`null`)。
    /// - 对于 ``boolean(_:)``, ``string(_:)``, ``integer(_:)``, ``unsigned(_:)``, ``float(_:)``
    ///   使用对应类型默认编码方式。
    /// - 如果指定了 `CodingUserInfoKey.Jason.skipNullValues`，将 ``array(_:)`` 中的非 ``empty``
    ///   元素放入有序容器，否则放入所有元素。
    /// - 如果指定了 `CodingUserInfoKey.Jason.keepNullValues`，将 ``dictionary(_:)``
    ///   中所有键值对放入键值容器。否则只放入值非空的键值对。
    ///
    /// - Parameter encoder: 遵循 `Encoder` 的编码器
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .empty:
            var container = encoder.singleValueContainer()
            try container.encodeNil()

        case let .boolean(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .string(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .integer(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .unsigned(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .float(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .array(value):
            let nullNotAllowed = encoder.userInfo[CodingUserInfoKey.Jason.skipNullValues] as? Bool == true
            var container = encoder.unkeyedContainer()
            for element in value {
                if element == .empty, nullNotAllowed { continue }
                try container.encode(element)
            }

        case let .dictionary(value):
            let nullAllowed = encoder.userInfo[CodingUserInfoKey.Jason.keepNullValues] as? Bool == true
            var container = encoder.container(keyedBy: JasonIndex.self)
            for (key, element) in value {
                if element == .empty, !nullAllowed { continue }
                try container.encode(element, forKey: JasonIndex(stringValue: key))
            }
        }
    }
}

// MARK: - Jason + Decodable

extension Jason: Decodable {
    /// 从 `Decoder` 中取出 ``Jason``。
    ///
    /// 此方法根据 `Decoder` 中容器类型调度到其他解码方法。
    ///
    /// - Parameter decoder: 遵循 `Decoder` 的解码器。
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JasonIndex.self) {
            try self.init(from: container)
            return
        }

        if var container = try? decoder.unkeyedContainer() {
            try self.init(from: &container)
            return
        }

        let container = try decoder.singleValueContainer()
        try self.init(from: container)
    }
}

public extension Jason {
    /// 从键值容器中取出 ``dictionary(_:)``。
    ///
    /// - Parameter container: `Decoder` 中的键值容器
    init<C: KeyedDecodingContainerProtocol>(from container: C) throws {
        let keys = container.allKeys
        var dict = [String: Jason](minimumCapacity: keys.count)
        for key in keys {
            let value = try container.decode(Jason.self, forKey: key)
            dict[key.stringValue] = value
        }
        self = .dictionary(dict)
    }

    /// 从有序容器中取出 ``array(_:)``。
    ///
    /// - Parameter container: `Decoder` 中的有序容器
    init(from container: inout UnkeyedDecodingContainer) throws {
        var array = [Jason]()
        while !container.isAtEnd {
            let value = try container.decode(Jason.self)
            array.append(value)
        }
        self = .array(array)
    }

    /// 从单元容器中取出 ``empty``, ``boolean(_:)``, ``string(_:)``, ``integer(_:)``, ``float(_:)``。
    ///
    /// - Parameter container: `Decoder` 中的单元容器
    init(from container: SingleValueDecodingContainer) throws {
        if container.decodeNil() {
            self = .empty
            return
        }

        if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
            return
        }

        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }

        if let number = try? container.decode(Int.self) {
            self = .integer(number)
            return
        }

        if let number = try? container.decode(UInt.self) {
            self = .unsigned(number)
            return
        }

        if let float = try? container.decode(Double.self) {
            self = .float(float)
            return
        }

        throw DecodingError.typeMismatch(
            Jason.self,
            DecodingError.Context(codingPath: container.codingPath,
                                  debugDescription: "JSON does not support non-standard value types.",
                                  underlyingError: nil)
        )
    }
}
