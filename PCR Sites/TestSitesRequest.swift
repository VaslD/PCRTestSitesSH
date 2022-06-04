import CoreLocation
import Foundation

struct TestSitesRequest: Encodable {
    var page = "1"
    var itemsPerPage = "50"

    var scope = "100000"
    var district: String
    var town: String

    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees

    var serviceType: String
    var openStatus: String

    init(_ coordinate: CLLocationCoordinate2D) {
        self.district = ""
        self.town = ""
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.serviceType = ""
        self.openStatus = "1"
    }

    enum CodingKeys: String, CodingKey {
        case page = "pageNo"
        case itemsPerPage = "pageSize"
        case scope
        case district
        case town
        case latitude = "lat"
        case longitude = "lng"
        case serviceType = "service_object"
        case openStatus = "open_status"
    }
}
