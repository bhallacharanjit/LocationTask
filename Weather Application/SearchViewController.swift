//
//  SearchViewController.swift
//  Weather Application
//
//  Created by charanjit singh on 22/05/21.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController, NetworkingDelegate,UITableViewDataSource, UITableViewDelegate {
    var networking:Networking?
    var parentController:ViewController!
    var searchedCitiesArray:NSArray!
    
    @IBOutlet var mSearchTextField: UITextField!
    @IBOutlet var mSearchResultsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mSearchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)

        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let searchText = self.mSearchTextField.text
        if searchText!.count > 2 {
            searchForCity(serchText: searchText!)
        }
    }

    
    func searchForCity(serchText:String) {
        let cityForURL = self.mSearchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!;
        let url  = "http://api.weatherapi.com/v1/search.json?key=8e66a5c677b547c39f313809213003&q=\(cityForURL)"
        self.networking = Networking()
        self.networking!.delegate = self
        self.networking!.callAPI(url: url, data: nil, method: .get)
    }
    
    
    func NetworkingFinished(response: AFDataResponse<Any>) {
        
        var _: NSError?
        
        self.searchedCitiesArray = try? JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray
        NSLog("\(searchedCitiesArray?.count ?? 0)")
        self.mSearchResultsTableView.reloadData()
    }
    
    
    @IBAction func currentLocationAction(_ sender: Any) {
        self.parentController.fetchUserLocation()
//        self.parentController.callForWeather(name: "Jalandhar")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedCitiesArray == nil {
            return 0
        }
        return self.searchedCitiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell")
        
        cell?.textLabel?.numberOfLines = 0
        cell?.detailTextLabel?.numberOfLines = 0
        
        let searchedCity = self.searchedCitiesArray[indexPath.row] as? NSDictionary
        cell?.textLabel?.text =  searchedCity!["name"] as? String
        cell?.detailTextLabel?.text = searchedCity!["country"] as? String
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchedCity = self.searchedCitiesArray[indexPath.row] as? NSDictionary
        let searchCityName = searchedCity!["name"] as? String
        self.parentController.callForWeather(name: searchCityName!)
        self.navigationController?.popToRootViewController(animated: true)
    }
}
