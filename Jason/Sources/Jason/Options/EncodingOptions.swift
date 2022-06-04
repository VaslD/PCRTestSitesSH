public extension CodingUserInfoKey {
    /// Jason 编解码偏好设置。
    enum Jason {
        /// 编码字典时保留空键值。此键在设置字典中需对应 `Bool` 类型的值，默认为 `false`。
        public static let keepNullValues = CodingUserInfoKey(rawValue: "VaslD.Jason.EncodingOptions.KeepNullValues")!

        /// 编码数组时跳过空值。此键在设置字典中需对应 `Bool` 类型的值，默认为 `false`。
        public static let skipNullValues = CodingUserInfoKey(rawValue: "VaslD.Jason.EncodingOptions.SkipNullValues")!
    }
}
