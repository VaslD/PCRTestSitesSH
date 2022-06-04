import Combine
import Contacts
import Jason
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var locateButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var navigateButton: UIBarButtonItem!
    @IBOutlet var filterIsPublicButton: UIBarButtonItem!
    @IBOutlet var filterIsOpenButton: UIBarButtonItem!

    var annotations = [MKAnnotation]()
    var filteringIsPublic = false
    var filteringIsOpen = true

    let mapPublisher = PassthroughSubject<CLLocationCoordinate2D, Never>()
    var mapObserver: AnyCancellable?

    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
        self.buildMenu(for: self.filterIsPublicButton)
        self.buildMenu(for: self.filterIsOpenButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.locationManager.authorizationStatus != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }

        self.mapObserver = self.mapPublisher.removeDuplicates {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from:
                CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            ) <= 1000
        }.debounce(for: 1, scheduler: RunLoop.main).sink { _ in
            Task { await self.reloadTestSites() }
        }
    }

    @IBAction
    func locateMe(sender: UIBarButtonItem) {
        sender.image = UIImage(systemName: "location.fill")
        self.mapView.userTrackingMode = .follow
    }

    @IBAction
    func reloadTestSites(sender: UIBarButtonItem) {
        Task { await self.reloadTestSites() }
    }

    @IBAction
    func navigateToDestination(sender: UIBarButtonItem) {
        guard let annotation = self.mapView.selectedAnnotations.first as? TestSiteAnnotation else {
            return
        }
        var address = [
            CNPostalAddressCountryKey: "中国",
            CNPostalAddressISOCountryCodeKey: "CN",
            CNPostalAddressCityKey: "上海市",
            CNPostalAddressStreetKey: annotation.site.address,
        ]
        address[CNPostalAddressSubLocalityKey] = Int(annotation.site.district).flatMap { localityMapping[$0] }
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: address)
        let item = MKMapItem(placemark: placemark)
        item.name = annotation.title ?? nil
        item.pointOfInterestCategory = .pharmacy
        item.openInMaps()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation !== mapView.userLocation else {
            return nil
        }
        guard let annotation = annotation as? TestSiteAnnotation else {
            return nil
        }
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MarkerAnnotationView")
        if annotation.site.serviceType == "0" {
            view.glyphImage = UIImage(systemName: "staroflife")
        } else {
            view.glyphImage = UIImage(systemName: "person.text.rectangle")
        }
        switch annotation.site.traffic {
        case "0":
            view.markerTintColor = .systemGreen
            view.selectedGlyphImage = UIImage(systemName: "facemask.fill")
        case "1":
            view.markerTintColor = .systemOrange
            view.selectedGlyphImage = UIImage(systemName: "facemask.fill")
        case "2":
            view.markerTintColor = .systemRed
            view.selectedGlyphImage = UIImage(systemName: "facemask.fill")
        default:
            view.markerTintColor = .systemGray
            view.selectedGlyphImage = UIImage(systemName: "xmark.circle.fill")
        }
        view.clusteringIdentifier = "PCRTestSite"
        view.animatesWhenAdded = true
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view.annotation {
        case let annotation as MKClusterAnnotation:
            let camera = self.mapView.camera.copy() as! MKMapCamera
            camera.centerCoordinate = annotation.coordinate
            camera.centerCoordinateDistance /= 2
            self.mapView.setCamera(camera, animated: true)
        case let annotation as TestSiteAnnotation:
            let camera = self.mapView.camera.copy() as! MKMapCamera
            camera.centerCoordinate = annotation.coordinate
            self.mapView.setCamera(camera, animated: true)
            camera.centerCoordinateDistance = 1000
            self.navigateButton.isEnabled = true
        default:
            return
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard mapView.selectedAnnotations.isEmpty else {
            return
        }
        self.navigateButton.isEnabled = false
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.mapPublisher.send(mapView.centerCoordinate)
        if mapView.centerCoordinate != mapView.userLocation.coordinate {
            self.locateButton.image = UIImage(systemName: "location")
        }
    }

    // MARK: Utility

    func reloadTestSites() async {
        do {
            var request = URLRequest(url: URL(string: "https://apps.eshimin.com/natPoint/geoAgencyList")!)
            request.timeoutInterval = 15
            request.httpMethod = "POST"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            var body = TestSitesRequest(self.mapView.centerCoordinate)
            body.serviceType = self.filteringIsPublic ? "0" : ""
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            var items: [TestSiteAnnotation] = try JSONDecoder().decode(
                [TestSite].self, from: data, path: ["data", "list"]
            ).map(TestSiteAnnotation.init(site:))
            if self.filteringIsOpen {
                items = items.filter { $0.site.traffic != "3" }
            }
            await MainActor.run {
                self.mapView.removeAnnotations(self.annotations)
                self.annotations = items
                self.mapView.addAnnotations(self.annotations)
            }
        } catch {
            await MainActor.run {
                let alert = UIAlertController(title: "与服务器通讯遇到问题", message: error.localizedDescription,
                                              preferredStyle: .alert)
                let ok = UIAlertAction(title: "好", style: .default)
                alert.addAction(ok)
                alert.preferredAction = ok
                self.present(alert, animated: true)
            }
        }
    }

    func buildMenu(for button: UIBarButtonItem) {
        switch button {
        case self.filterIsPublicButton:
            let filterPublicSites = UIAction(title: "面向公众",
                                             image: UIImage(systemName: "staroflife"),
                                             identifier: nil,
                                             discoverabilityTitle: "仅显示面向社会公众的采样点",
                                             attributes: [], state: self.filteringIsPublic ? .on : .off) {
                self.filteringIsPublic = true
                Task { await self.reloadTestSites() }
                button.image = $0.image
                self.buildMenu(for: button)
            }
            let filterAllSites = UIAction(title: "全部采样点",
                                          image: UIImage(systemName: "list.bullet"),
                                          identifier: nil,
                                          discoverabilityTitle: "显示全部采样点",
                                          attributes: [], state: self.filteringIsPublic ? .off : .on) { _ in
                self.filteringIsPublic = false
                Task { await self.reloadTestSites() }
                self.buildMenu(for: button)
            }
            let menu = UIMenu(children: [filterPublicSites, filterAllSites])
            button.menu = menu
            button.image = self.filteringIsPublic
                ? UIImage(systemName: "staroflife")
                : UIImage(systemName: "list.bullet")

        case self.filterIsOpenButton:
            let filterOpenSites = UIAction(title: "营业中",
                                           image: UIImage(systemName: "facemask"),
                                           identifier: nil,
                                           discoverabilityTitle: "仅显示面向社会公众的采样点",
                                           attributes: [], state: self.filteringIsOpen ? .on : .off) { _ in
                self.filteringIsOpen = true
                Task { await self.reloadTestSites() }
                self.buildMenu(for: button)
            }
            let filterAllSites = UIAction(title: "全部采样点",
                                          image: UIImage(systemName: "clock"),
                                          identifier: nil,
                                          discoverabilityTitle: "显示全部采样点",
                                          attributes: [], state: self.filteringIsOpen ? .off : .on) {
                self.filteringIsOpen = false
                Task { await self.reloadTestSites() }
                button.image = $0.image
                self.buildMenu(for: button)
            }
            let menu = UIMenu(children: [filterOpenSites, filterAllSites])
            button.menu = menu
            button.image = self.filteringIsOpen ? UIImage(systemName: "facemask") : UIImage(systemName: "clock")

        default:
            return
        }
    }
}

// MARK: - CLLocationCoordinate2D + Equatable

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
