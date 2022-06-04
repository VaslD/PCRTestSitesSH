/// ``Jason`` 新增的错误。
///
/// 注意 ``Jason`` 提供的方法仍然可能抛出系统标准错误。
public enum JasonError: Error {
    /// 编码或解码的输入无法处理。
    case inconvertible
}
