//
//  GetLocationVC.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit
import MapKit

class GetLocationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var mapItems: [MKMapItem]?
    
    @IBAction func findLocationButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        if (locationTextField.text?.isEmpty)! {
            activityIndicator.stopAnimating()
            showAlert(title: "No Location", message: "Please enter a location", titleResponse: "Ok")
        }else {
            activityIndicator.stopAnimating()
            getCoordinate(addressString: locationTextField.text!, completionHandler: handleGetCoordinate(response:error:))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("performSegue : backToMap")
    }
    
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    
    func handleGetCoordinate(response: CLLocationCoordinate2D, error: NSError? ){
        if response.latitude == -180 || response.longitude == -180{
            showAlert(title: "Invalid Address", message: "Please enter a valid address", titleResponse: "Ok")
        } else {
            long = response.longitude
            lat = response.latitude
            print("response : ",long,"/",lat)
            performSegue(withIdentifier: "locationToMap", sender: nil)
            print("performSegue : locationToMap")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as? SendLocationVC
        print("performSegue : goToSendLocation")
        destinationVC?.newlong = long
        destinationVC?.newLat = lat
        destinationVC?.mediaURL = mediaURLTextField.text ?? ""
        destinationVC?.mapString = locationTextField.text!
    }
    
    func showAlert(title: String, message: String, titleResponse: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: titleResponse, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        return true
    }
    
}

