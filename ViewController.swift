//
//  ViewController.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 04/04/23.
//

import UIKit
import MapKit




class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let utilityFunctions = Utilities()
    let weatherApi = WeatherAPIModal()
    private var screenDetailSegue : String = "goToDetailsScreen"
    private var addLocationSegue : String = "goToAddLocation"
    let locationManager = CLLocationManager()
    var items: [WeatherItem] = []
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.dataSource = self
        tableView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func getUserLocation() -> CLLocation {
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        guard let location = locationManager.location else {
            return CLLocation(latitude: 43.0130, longitude: -81.1994)
        }
        return location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapConfiguration(for: locations.last!)
        addWeatherAnnotation(for: locations.last!)
    }
    
    func mapConfiguration(for location: CLLocation) {
        
        mapView.delegate = self
        
        mapView.mapType = .mutedStandard
        
        let location: CLLocation = location
        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeters,
                                        longitudinalMeters: radiusInMeters)
        
        
        mapView.setRegion(region, animated: true)
        
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
    }
    
    
    private func addWeatherAnnotation(for location: CLLocation) {
        
        let coordinate = location.coordinate
        let latLong = "\(coordinate.latitude),\(coordinate.longitude)"
        
            weatherApi.fetchWeatherDetails(for: latLong) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let weatherResponse):
                let temperature = weatherResponse.current.temp_c
                let color: UIColor
                
                switch temperature {
                        case ...0:
                            color = UIColor(red: 0.51, green: 0.22, blue: 0.72, alpha: 1.0)
                        case 0..<12:
                    color = UIColor(red: 0.19, green: 0.39, blue: 0.67, alpha: 1.0)
                        case 12..<17:
                    color = UIColor(red: 0.33, green: 0.58, blue: 0.82, alpha: 1.0)
                        case 17..<25:
                    color = UIColor(red: 1.0, green: 0.92, blue: 0.23, alpha: 1.0)
                        case 25..<30:
                    color = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
                        case 30...:
                    color = UIColor(red: 0.71, green: 0.0, blue: 0.0, alpha: 1.0)
                        default:
                    color = UIColor.black // fallback color
                        }
                
                let annotation = AnnotationModal(location.coordinate,
                                              "\(weatherResponse.current.condition.text)",
                                              "Temperature : \(Int(weatherResponse.current.temp_c))\u{00B0}  Feels Like : \(Int(weatherResponse.current.feelslike_c))\u{00B0}",
                                              "\(Int(weatherResponse.current.temp_c))\u{00B0}",
                                              color ,
                                                 utilityFunctions.getWeatherImage(code: weatherResponse.current.condition.code))
                
                self.mapView.addAnnotation(annotation)
            case .failure(let error):
                print("Weather API Error: ", error.localizedDescription)
            }
        }
    }
    
    
    
    @IBAction func addNewLocationButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddLocation", sender: nil)
    }
    
    
}


extension ViewController: MKMapViewDelegate {
    
    @objc func buttonTapped(sender: UIButton) {
        performSegue(withIdentifier: "goToDetailsScreen", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == screenDetailSegue{
            let viewController = segue.destination as! DetailsViewController
            
            weatherApi.fetchWeatherDetails(for: "\(getUserLocation().coordinate.latitude) + \(getUserLocation().coordinate.longitude)") { result in
                switch result {
                case .success(let weatherResponse):
                    viewController.weatherResponse = weatherResponse; viewController.loadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    
                }
            }
        }
        else if segue.identifier == addLocationSegue {
            let viewController = segue.destination as! AddLocationViewController
            viewController.delegate = self
            weatherApi.fetchWeatherDetails(for: "\(getUserLocation().coordinate.latitude) + \(getUserLocation().coordinate.longitude)") { result in
                switch result {
                case .success(let weatherResponse):
                    viewController.weatherResponseDefault = weatherResponse; viewController.loadData(weatherResponse)
                case .failure(let error):
                    print(error.localizedDescription)
                    
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = ""
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: 0, y: 10)
        
        
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        
        view.rightCalloutAccessoryView = button
        view.tintColor = UIColor.systemGray2
        view.glyphImage = UIImage(systemName: "mappin.circle.fill")
        
        if let myAnnotation = annotation as? AnnotationModal {
            view.glyphText = myAnnotation.glyphText
            view.markerTintColor = myAnnotation.markerTintColor
            view.leftCalloutAccessoryView = UIImageView(image: myAnnotation.image)
        }
        
        return view
    }
}

extension ViewController: AddLocationViewControllerDelegate, UITableViewDataSource {
    func addLocationViewControllerDelegateDidFinish(with data: WeatherItem) {
        items.append(data)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.count)
            return items.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weatherDetailsCell", for: indexPath)
            let item = items[indexPath.row]
    
            var content = cell.defaultContentConfiguration()
            content.text = item.location
            let maxTempWidth = items.map { $0.maxTemperature.count }.max() ?? 0
            let minTempWidth = items.map { $0.minTemperature.count }.max() ?? 0
    
            var formattedString = ""
                let maxTempStr = item.maxTemperature.padding(toLength: maxTempWidth, withPad: " ", startingAt: 0)
                let minTempStr = item.minTemperature.padding(toLength: minTempWidth, withPad: " ", startingAt: 0)
                formattedString += "H: \(maxTempStr)\t\tL: \(minTempStr)"
    
            content.secondaryText = formattedString
    
    
            content.image = item.weatherImage
    
            cell.contentConfiguration = content
            return cell
        }
    
}


extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let geocoder = CLGeocoder()
        print("location \(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "")")
        geocoder.geocodeAddressString(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "") { (placemarks, error) in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("nolocartion")
                return
            }
            print("location ")
            self.mapConfiguration(for: location)
            self.addWeatherAnnotation(for: location)
        }
    }
}
