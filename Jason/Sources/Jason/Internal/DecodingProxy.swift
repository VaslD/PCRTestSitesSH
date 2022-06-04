struct DecodingProxy: Decodable {
    var decoder: Decoder

    init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}
