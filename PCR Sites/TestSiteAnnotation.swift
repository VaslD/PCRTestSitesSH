import MapKit

class TestSiteAnnotation: MKPointAnnotation {
    var site: TestSite

    init(site: TestSite) {
        self.site = site
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: site.latitude, longitude: site.longitude)
        if site.name.contains("【常态化】") {
            self.title = site.name.replacingOccurrences(of: "【常态化】", with: "")
            self.subtitle = "（常态化）"
        } else {
            self.title = site.name
        }
    }
}
