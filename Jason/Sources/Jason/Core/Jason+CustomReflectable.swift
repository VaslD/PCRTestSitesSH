extension Jason: CustomReflectable {
    /// ``Jason`` 不支持 `Mirror`。
    ///
    /// ``Jason`` 已提供格式化的 JSON 作为 ``debugDescription`` 用于调试器输出。如果使用默认 `Mirror`
    /// 将重复输出每个元素，并且会显示混乱的换行和缩进。
    public var customMirror: Mirror {
        Mirror(reflecting: Any?.none as Any)
    }
}
