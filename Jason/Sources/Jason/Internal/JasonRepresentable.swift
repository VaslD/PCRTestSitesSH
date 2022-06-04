#if canImport(ObjectiveC)
import ObjectiveC
#endif

#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(Foundation)
import Foundation
#endif

/// 此协议用于批量扩展方法，严禁实现自定义类型遵循此协议！
protocol JasonRepresentable {
    func toJason() -> Jason
}

// MARK: - Jason + JasonRepresentable

extension Jason: JasonRepresentable {
    public func toJason() -> Jason {
        self
    }
}

// MARK: - Optional + JasonRepresentable

extension Optional: JasonRepresentable where Wrapped: JasonRepresentable {
    func toJason() -> Jason {
        switch self {
        case .none:
            return .empty
        case let .some(value):
            return value.toJason()
        }
    }
}

// MARK: - NSNull + JasonRepresentable

#if canImport(Foundation)
extension NSNull: JasonRepresentable {
    func toJason() -> Jason {
        .empty
    }
}
#endif

// MARK: - Bool + JasonRepresentable

extension Bool: JasonRepresentable {
    func toJason() -> Jason {
        .boolean(self)
    }
}

// MARK: - ObjCBool + JasonRepresentable

#if canImport(ObjectiveC)
extension ObjCBool: JasonRepresentable {
    func toJason() -> Jason {
        .boolean(self.boolValue)
    }
}
#endif

// MARK: - StringProtocol + JasonRepresentable

public extension StringProtocol {
    func toJason() -> Jason {
        .string(String(self))
    }
}

// MARK: - String + JasonRepresentable

extension String: JasonRepresentable {}

// MARK: - Substring + JasonRepresentable

extension Substring: JasonRepresentable {}

// MARK: - NSString + JasonRepresentable

#if canImport(Foundation)
extension NSString: JasonRepresentable {
    func toJason() -> Jason {
        .string(self as String)
    }
}
#endif

// MARK: - SignedInteger + JasonRepresentable

extension SignedInteger {
    func toJason() -> Jason {
        .integer(Int(self))
    }
}

// MARK: - Int + JasonRepresentable

extension Int: JasonRepresentable {}

// MARK: - Int8 + JasonRepresentable

extension Int8: JasonRepresentable {}

// MARK: - Int16 + JasonRepresentable

extension Int16: JasonRepresentable {}

// MARK: - Int32 + JasonRepresentable

extension Int32: JasonRepresentable {}

// MARK: - Int64 + JasonRepresentable

extension Int64: JasonRepresentable {}

// MARK: - UnsignedInteger + JasonRepresentable

extension UnsignedInteger {
    func toJason() -> Jason {
        .unsigned(UInt(self))
    }
}

// MARK: - UInt + JasonRepresentable

extension UInt: JasonRepresentable {}

// MARK: - UInt8 + JasonRepresentable

extension UInt8: JasonRepresentable {}

// MARK: - UInt16 + JasonRepresentable

extension UInt16: JasonRepresentable {}

// MARK: - UInt32 + JasonRepresentable

extension UInt32: JasonRepresentable {}

// MARK: - UInt64 + JasonRepresentable

extension UInt64: JasonRepresentable {}

// MARK: - BinaryFloatingPoint + JasonRepresentable

extension BinaryFloatingPoint {
    func toJason() -> Jason {
        .float(Double(self))
    }
}

// MARK: - Float + JasonRepresentable

extension Float: JasonRepresentable {}

// MARK: - Double + JasonRepresentable

extension Double: JasonRepresentable {}

// MARK: - Float16 + JasonRepresentable

#if !arch(i386) && !arch(x86_64)
@available(iOS 14.0, macOS 11.0, macCatalyst 14.5, tvOS 14.0, watchOS 7.0, *)
extension Float16: JasonRepresentable {}
#endif

// MARK: - Float80 + JasonRepresentable

#if os(macOS) && !arch(arm64)
extension Float80: JasonRepresentable {}
#endif

// MARK: - CGFloat + JasonRepresentable

#if canImport(CoreGraphics)
extension CGFloat: JasonRepresentable {}
#endif

// MARK: - Dictionary + JasonRepresentable

extension Dictionary: JasonRepresentable where Key: CustomStringConvertible, Value: JasonRepresentable {
    func toJason() -> Jason {
        var dictionary = [String: Jason](minimumCapacity: self.count)
        for (key, value) in self {
            dictionary[String(describing: key)] = value.toJason()
        }
        return .dictionary(dictionary)
    }
}

// MARK: - Sequence + JasonRepresentable

extension Sequence where Element: JasonRepresentable {
    func toJason() -> Jason {
        .array(self.map { $0.toJason() })
    }
}

// MARK: - Array + JasonRepresentable

extension Array: JasonRepresentable where Element: JasonRepresentable {}

// MARK: - AnySequence + JasonRepresentable

extension AnySequence: JasonRepresentable where Element: JasonRepresentable {}

// MARK: - Set + JasonRepresentable

extension Set: JasonRepresentable where Element: JasonRepresentable {}
