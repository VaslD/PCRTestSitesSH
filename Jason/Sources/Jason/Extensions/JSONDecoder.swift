#if canImport(Foundation)
import Foundation
#endif

#if canImport(Foundation)
public extension JSONDecoder {
    /// 将 JSON 数据模型化并交由调用者手动处理。
    ///
    /// - Parameter data: 原始 JSON 数据
    /// - Returns: JSON 对应的 ``Jason`` 模型
    func decodeJason(from data: Data) throws -> Jason {
        try self.decode(Jason.self, from: data)
    }

    /// 通过 ``JasonIndex`` 解析嵌套的 `Decodable`。
    ///
    /// - Parameters:
    ///   - type: 遵循 `Decodable` 的类型
    ///   - data: JSON 数据
    ///   - path: 嵌套的类型所在位置
    ///
    /// - Returns: 剥离嵌套的 `Decodable` 实例
    func decode<T: Decodable>(_ type: T.Type, from data: Data, path: [JasonIndex]) throws -> T {
        if path.isEmpty {
            return try self.decode(type, from: data)
        }

        // 当 X 是 Decodable 时，Optional<X> 也是 Decodable；因此 type 可能是 X 也可能是 Optional<X>。
        // 而对于 Optional<X>，系统默认行为在找不到解码路径时不会抛出错误，只有当找到此路径但构造 X 失败时才会，需要特殊处理 path。

        /// 标识 type 是否是 `Optional<X>`
        let isOptional: Bool = {
            // Swift 已经 ABI 稳定，因此类型记录和标识符不会在后续版本更改。

            // T.self 是两个连续的指针，前者指向 T 的 metadata record（类型定义），后者指向 T 的 witness table（协议遵循表）。
            // 因为 Any.Type (Any.self) 不遵循任何协议，因此 T.self as Any.Type 只指向 T 的类型定义。
            // https://github.com/wickwirew/Runtime/blob/2.2.2/Sources/Runtime/Metadata/Metadata.swift#L24
            let metaTypeFlags = unsafeBitCast(T.self as Any.Type, to: UnsafePointer<Int>.self).pointee

            // 任何类型定义的前 8 字节是类型标识符。
            // https://github.com/wickwirew/Runtime/blob/2.2.2/Sources/Runtime/Models/Kind.swift#L46
            // https://github.com/apple/swift/blob/swift-5.5.1-RELEASE/include/swift/ABI/MetadataKind.def#L51
            return metaTypeFlags == 3 || metaTypeFlags == (2 | 0x200)
        }()

        // 类似于 String?.none as Any 和 String?.none as Any? 都是合法转换，
        // 当 type (T) 是 Optional<X> 时 Optional<X>.none as T 也是合法转换。
        // 编译器无法保证范型类型，不允许此语法，此时使用强制解包是合理用法。

        /// 当 type 是 `Optional<X>` 时，通过强制解包此变量获得 T 类型的 `Optional<X>.none`
        let none: T? = {
            if isOptional {
                // Optional<X> 一定遵循 ExpressibleByNilLiteral
                return ((T.self as! ExpressibleByNilLiteral.Type).init(nilLiteral: ()) as! T)
            }
            return nil
        }()

        var currentKey = path.first!
        var container: Any = try {
            let decoder = try self.decode(DecodingProxy.self, from: data).decoder
            switch currentKey {
            case .property:
                // Path 不存在（JSON 类型不对应）时检查是否可以返回 X?.none
                do {
                    return try decoder.container(keyedBy: JasonIndex.self)
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [String: Any].self, isOptional {
                        return none!
                    }
                    throw error
                }

            case .element:
                do {
                    return try decoder.unkeyedContainer()
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [Any].self, isOptional {
                        return none!
                    }
                    throw error
                }
            }
        }()

        if let value = container as? T {
            return value
        }

        for nextKey in path.dropFirst() {
            switch (currentKey, nextKey) {
            case let (.property(string), .property):
                let keyed = container as! KeyedDecodingContainer<JasonIndex>
                let key = JasonIndex(stringValue: string)

                // Path 不存在（JSON Object 无此属性）时检查是否可以返回 X?.none
                if !keyed.contains(key), isOptional {
                    return none!
                }

                // Path 不存在（JSON 类型不对应）时检查是否可以返回 X?.none
                do {
                    container = try keyed.nestedContainer(keyedBy: JasonIndex.self, forKey: key)
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [String: Any].self, isOptional {
                        return none!
                    }
                    throw error
                }

            case let (.property(string), .element):
                let keyed = container as! KeyedDecodingContainer<JasonIndex>
                let key = JasonIndex(stringValue: string)
                if !keyed.contains(key), isOptional {
                    return none!
                }
                do {
                    container = try keyed.nestedUnkeyedContainer(forKey: key)
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [Any].self, isOptional {
                        return none!
                    }
                    throw error
                }

            case let (.element(int), .property):
                var unkeyed = container as! UnkeyedDecodingContainer
                if int > 0 {
                    do {
                        try (0..<int).forEach { _ in _ = try unkeyed.decode(Empty.self) }
                    } catch let error as DecodingError {
                        if case let .valueNotFound(expectedType, _) = error, expectedType == Empty.self, isOptional {
                            return none!
                        }
                        throw error
                    }
                }
                do {
                    container = try unkeyed.nestedContainer(keyedBy: JasonIndex.self)
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [String: Any].self, isOptional {
                        return none!
                    }
                    if case let .valueNotFound(expectedType, _) = error,
                       expectedType == KeyedDecodingContainer<JasonIndex>.self,
                       isOptional {
                        return none!
                    }
                    throw error
                }

            case let (.element(int), .element):
                var unkeyed = container as! UnkeyedDecodingContainer
                if int > 0 {
                    do {
                        try (0..<int).forEach { _ in _ = try unkeyed.decode(Empty.self) }
                    } catch let error as DecodingError {
                        if case let .valueNotFound(expectedType, _) = error, expectedType == Empty.self, isOptional {
                            return none!
                        }
                        throw error
                    }
                }
                do {
                    container = try unkeyed.nestedUnkeyedContainer()
                } catch let error as DecodingError {
                    if case let .typeMismatch(expectedType, _) = error, expectedType == [Any].self, isOptional {
                        return none!
                    }
                    if case let .valueNotFound(expectedType, _) = error,
                       expectedType is UnkeyedDecodingContainer.Protocol,
                       isOptional {
                        return none!
                    }
                    throw error
                }
            }
            currentKey = nextKey
        }

        switch currentKey {
        case let .property(string):
            let keyed = container as! KeyedDecodingContainer<JasonIndex>
            let key = JasonIndex(stringValue: string)
            if !keyed.contains(key), isOptional {
                return none!
            }
            return try keyed.decode(type, forKey: key)

        case let .element(int):
            var unkeyed = container as! UnkeyedDecodingContainer
            if int > 0 {
                do {
                    try (0..<int).forEach { _ in _ = try unkeyed.decode(Empty.self) }
                } catch let error as DecodingError {
                    if case let .valueNotFound(expectedType, _) = error, expectedType == Empty.self, isOptional {
                        return none!
                    }
                    throw error
                }
            }
            do {
                return try unkeyed.decode(type)
            } catch let error as DecodingError {
                if case let .valueNotFound(expectedType, _) = error, expectedType == T.self, isOptional {
                    return none!
                }
                throw error
            }
        }
    }
}
#endif
