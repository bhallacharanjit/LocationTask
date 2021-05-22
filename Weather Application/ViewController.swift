//
//  ViewController.swift
//  Weather Application
//
//  Created by charanjit singh on 22/05/21.
//

import UIKit
import CoreLocation
import Alamofire
import SDWebImage

extension CLLocation {
    
    
    func fetchCity(completion: @escaping (_ city: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $1) }
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, NetworkingDelegate {
    
    var locationManager:CLLocationManager!
    var networking:Networking?
    
    @IBOutlet var mCityName: UILabel!
    @IBOutlet var mTempInC: UILabel!
    @IBOutlet var mTempInF: UILabel!
    @IBOutlet var mCurrentCondition: UILabel!
    @IBOutlet var mCurrentConditionImage: UIImageView!
    @IBOutlet var mCurrentDirection: UILabel!
    @IBOutlet var mHumidity: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchUserLocation()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        let isLocation = isLocationAccessEnabled()
        if isLocation {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
            vc?.parentController = self
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        
    }
    
    //getting user location
    func fetchUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        isLocationAccessEnabled()
        
    }
    
    func isLocationAccessEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .restricted, .denied:
                print("No access")
                showLocationPopup()
                return false
            case .notDetermined: break
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            @unknown default:
                print("err")
            }
        } else {
            print("Location services not enabled")
        }
        
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        userLocation.fetchCity { city, error in
            if error == nil {
                self.mCityName.text = city!
                self.callForWeather(name: city!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        //            self.requestLocationAuthorizationCallback?(status)
        isLocationAccessEnabled()
    }
    
    func showLocationPopup() {
        let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //end getting user location
    
    //call API for Weather
    func callForWeather(name:String) {
        
        let cityForURL = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!;
        
        let url = "http://api.weatherapi.com/v1/current.json?key=8e66a5c677b547c39f313809213003&q=\(cityForURL)&aqi=no"
        
        self.networking = Networking()
        self.networking!.delegate = self
        self.networking!.callAPI(url: url, data: nil, method: .get)
        
    }
    
    func NetworkingFinished(response: AFDataResponse<Any>) {
        
        var _: NSError?
        
        let weatherObject = try? JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
        if weatherObject!["error"] == nil {
            //success
            
            //getting location information
            let location = weatherObject!["location"] as? NSDictionary
            let cityCountry = "\(location!["name"] ?? ""), \(location!["country"] ?? "")"
            self.mCityName.text = cityCountry
            
            self.title = location!["name"] as? String
            
            
            //getting current weather info
            let current = weatherObject!["current"] as? NSDictionary
            self.mTempInC.text = "\(current!["temp_c"] ?? "") C"
            self.mTempInF.text = "\(current!["temp_f"] ?? "") F"
            //accessing condition
            let condition = current!["condition"] as? NSDictionary
            self.mCurrentCondition.text = condition!["text"] as? String
            let currentCondition = "http:\(condition!["icon"] ?? "")"
            self.mCurrentConditionImage.sd_setImage(with: URL(string: currentCondition), completed: nil)
            //wind
            self.mCurrentDirection.text = "Wind Direction: \(current!["wind_dir"] as? String ?? "")"
            self.mHumidity.text = "Humidity: \(current!["humidity"] as? Int ?? 0)"
            
            
            
        } else {
            //failed
            self.mCityName.text = "City Not Found!"
        }
    }
    
    
}

