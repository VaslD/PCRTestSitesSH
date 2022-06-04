public extension Jason {
    /// ``Jason`` 相等性比较。
    ///
    /// 此方法实现工作原理如下：
    /// - ``empty`` 只与 ``empty`` 相等。
    /// - ``boolean(_:)``, ``string(_:)``, ``array(_:)``, ``dictionary(_:)`` 只可能与相同类型相等，相等性遵循类型默认实现。
    /// - ``integer(_:)`` 与 ``float(_:)`` 将进行忽略类型的数学相等性比较。
    ///
    /// - Parameters:
    ///   - lhs: 等号左侧的 ``Jason``
    ///   - rhs: 等号右侧的 ``Jason``
    /// - Returns: 是否相等
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .empty:
            guard case .empty = rhs else { return false }
            return true

        case let .boolean(value):
            guard case let .boolean(bool) = rhs else { return false }
            return value == bool

        case let .string(value):
            guard case let .string(string) = rhs else { return false }
            return value == string

        case let .integer(value):
            switch rhs {
            case let .integer(int):
                return value == int
            case let .unsigned(int):
                return value == int
            case let .float(double):
                return Double(value) == double
            default:
                return false
            }

        case let .unsigned(value):
            switch rhs {
            case let .integer(int):
                return value == int
            case let .unsigned(int):
                return value == int
            case let .float(double):
                return Double(value) == double
            default:
                return false
            }

        case let .float(value):
            switch rhs {
            case let .integer(int):
                return value == Double(int)
            case let .unsigned(int):
                return value == Double(int)
            case let .float(double):
                return value == double
            default:
                return false
            }

        case let .array(value):
            guard case let .array(array) = rhs else { return false }
            return value == array

        case let .dictionary(value):
            guard case let .dictionary(dict) = rhs else { return false }
            return value == dict
        }
    }

    /// 与任意类型进行相等性比较。类型实例将先被尝试转换为 ``Jason``。
    ///
    /// 有关任意实例如何被转换为 ``Jason``，请阅读 ``rawValue`` 的文档。
    ///
    /// - Parameters:
    ///   - lhs: 等号左侧的 ``Jason``
    ///   - rhs: 等号右侧的任意类型实例
    /// - Returns: 是否相等
    static func == <T>(lhs: Self, rhs: T?) -> Bool {
        if case .empty = lhs, case .none = rhs {
            return true
        }
        if case let .some(value) = rhs, let wrapper = Jason(rawValue: value) {
            return lhs == wrapper
        }
        return false
    }
}

// MARK: - Jason + Equatable

extension Jason: Equatable {}
