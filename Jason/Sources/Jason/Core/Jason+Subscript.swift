public extension Jason {
    /// 输入 `[Jason]` 和索引，向数组中插入空值直到索引可用。
    ///
    /// 如果索引在数组中已经可用、或索引无效（例如：`-1`），此方法不执行任何操作。
    ///
    /// - Parameters:
    ///   - array: 可写入数组引用
    ///   - index: 任意索引
    private func offset(array: inout [Jason], to index: Int) {
        if array.indices.contains(index) {
            return
        }
        guard index >= 0 else {
            return
        }
        let distance = index - (array.indices.last ?? -1)
        for _ in 0..<distance {
            array.append(nil)
        }
    }

    /// 将 ``Jason`` 作为字典或数组使用。
    ///
    /// ```swift
    /// let dict: Jason = [:]
    /// assert(dict["someKey"]["otherKey"] == nil)
    ///
    /// let array: Jason = [5]
    /// assert(array[0] == 5)
    /// assert(array[0][1] == nil)
    /// ```
    ///
    /// 此方法不返回可选值。如果当前并非 ``dictionary(_:)``，使用此方法以 ``JasonIndex/property(_:)`` (`String`) 取值将会得到
    /// ``empty``。如果当前并非 ``array(_:)``，使用此方法以 ``JasonIndex/element(_:)`` (`Int`) 取值将会得到
    /// ``empty``。除此之外，无效的索引也会得到 ``empty``。``empty`` 可以与 `nil` 作相等性比较但不能用于 `if let` 和
    /// `guard let` 等语法。
    ///
    /// > Note:
    /// 当不需要立即获取 ``Jason`` 内部的值时，建议直接传递 ``Jason`` 而非检查每一步是否为 ``empty``。由于 ``empty``
    /// 具有 ``Jason`` 的所有功能，函数和模块之间可以交换 ``Jason`` 并最终统一处理结果或错误。
    ///
    /// 赋值时，请注意 ``Jason`` 是关联值枚举而不是类；每次修改都会产生新的 ``Jason``，因此赋值不会影响其他地方持有的副本。
    ///
    /// > Warning:
    /// 如果当前并非 ``dictionary(_:)``，使用此方法为 ``JasonIndex/property(_:)`` (`String`) 索引赋值将会**操作无效**，且
    /// Swift 不允许抛出错误。如果当前并非 ``array(_:)``，使用此方法为 ``JasonIndex/element(_:)`` (`Int`)
    /// 索引赋值也会**操作无效**。调用此方法保存计算后和获取到的值时请注意 ``Jason`` 此时的类型，不当操作可能引起非预期的数据丢失。
    ///
    /// > Important:
    /// 此方法**允许**跨层级赋值。如果赋值过程中某层级尚不存在，将会根据索引自动创建对应类型的
    /// ``Jason``，以继续前往下一层级。``JasonIndex/property(_:)`` (`String`) 索引会导致不存在的层级创建为
    /// ``dictionary(_:)``，而 ``JasonIndex/element(_:)`` (`Int`) 索引会导致不存在的层级创建为 ``array(_:)``。
    ///
    /// ```swift
    /// var x: Jason = []
    /// x[42]["key"][2021]["keyA"]["keyB"] = 12
    /// assert(x[42]["key"].rawValue is [Any])
    /// assert(x[42]["key"][2021]["keyA"]["keyB"] = 12)
    /// ```
    ///
    /// > Important:
    /// 不同于 Swift 数组，使用此方法为 ``array(_:)`` 中越界的 ``JasonIndex/element(_:)`` (`Int`) 索引赋值将会填充 `nil`
    /// 以使数组可以访问指定索引。
    ///
    /// ```swift
    /// var root: Jason = [:]
    /// root[2] = "Some"
    /// assert(root[0] == nil)
    /// assert(root[1] == nil)
    /// assert(root[2] == "Some")
    /// ```
    /// - Parameter index: 用于确定层级的 ``JasonIndex``
    subscript(_ index: JasonIndex) -> Jason {
        get {
            switch index {
            case let .property(string):
                guard case let .dictionary(dict) = self else {
                    return .empty
                }
                return dict[string, default: .empty]
            case let .element(int):
                guard case let .array(array) = self, array.indices.contains(int) else {
                    return .empty
                }
                return array[int]
            }
        }
        set {
            switch index {
            case let .property(string):
                guard !string.isEmpty else {
                    return
                }
                switch self {
                case .empty:
                    self = .dictionary([string: newValue])
                case var .dictionary(dict):
                    dict[string] = newValue
                    self = .dictionary(dict)
                default:
                    return
                }
            case let .element(int):
                guard int >= 0 else {
                    return
                }
                switch self {
                case .empty:
                    var array: [Jason] = []
                    self.offset(array: &array, to: int)
                    array[int] = newValue
                    self = .array(array)
                case var .array(array):
                    self.offset(array: &array, to: int)
                    array[int] = newValue
                    self = .array(array)
                default:
                    return
                }
            }
        }
    }

    /// 支持传入层级数组变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl`` 但仅支持取值。
    subscript(_ path: [JasonIndex]) -> Jason {
        path.reduce(self) { $0[$1] }
    }

    /// 支持多层级字面量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl`` 但仅支持取值。
    subscript(_ path: JasonIndex...) -> Jason {
        self[path]
    }

    /// 支持传入字符串变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl``。
    subscript(_ property: String) -> Jason {
        get {
            self[JasonIndex(property)]
        }
        set {
            self[JasonIndex(property)] = newValue
        }
    }

    /// 支持传入可空字符串变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl``。
    subscript(_ property: String?) -> Jason {
        get {
            self[JasonIndex(property)]
        }
        set {
            self[JasonIndex(property)] = newValue
        }
    }

    /// 支持传入字符串数组变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl`` 但仅支持取值。
    subscript(_ path: [String]) -> Jason {
        self[path.map { JasonIndex($0) }]
    }

    /// 支持传入整数变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl``。
    subscript(_ element: Int) -> Jason {
        get {
            self[JasonIndex(element)]
        }
        set {
            self[JasonIndex(element)] = newValue
        }
    }

    /// 支持传入可空整数变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl``。
    subscript(_ element: Int?) -> Jason {
        get {
            self[JasonIndex(element)]
        }
        set {
            self[JasonIndex(element)] = newValue
        }
    }

    /// 支持传入整数数组变量调用的快捷方法。此方法重定向至 ``subscript(_:)-7vljl`` 但仅支持取值。
    subscript(_ path: [Int]) -> Jason {
        self[path.map { JasonIndex($0) }]
    }
}
