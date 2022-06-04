import CoreLocation
import Foundation

struct TestSite: Identifiable, Decodable {
    let id: String
    let name: String
    let district: String
    let town: String
    let address: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let traffic: String
    let serviceType: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id = "collection_code"
        case name = "collection_point"
        case district
        case town
        case address = "collection_address"
        case latitude = "gdlat"
        case longitude = "gdlng"
        case traffic = "state"
        case serviceType = "service_object"
    }
}

let localityMapping = [
    310116: "金山区",
    310117: "松江区",
    310118: "青浦区",
    310120: "奉贤区",
    310101: "黄浦区",
    310104: "徐汇区",
    310105: "长宁区",
    310106: "静安区",
    310107: "普陀区",
    310108: "静安区",
    310109: "虹口区",
    310110: "杨浦区",
    310112: "闵行区",
    310114: "嘉定区",
    310115: "浦东新区",
]
