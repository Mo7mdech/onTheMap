//
//  SendLocationVC.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit
import MapKit

class SendLocationVC: UIViewController {
    
    var newLat: Double?
    var newlong: Double?
    var mediaURL: String?
    var location: String?
    var mapString : String?
    var nickName = UserDefaults.standard.object(forKey: "nickname") as? String
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func postLocationButtonPressed(_ sender: UIButton) {
        setUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapAnnotation()
        print("Location : ",newlong!,"/",newLat!)
    }
    
    func setMapAnnotation() {
        let lat = CLLocationDegrees(newLat!)
        let long = CLLocationDegrees(newlong!)
        let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        annotation.title = "New Location Marker"
        self.mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000  )
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func setUserInfo(){
        let newLocation = NewLocation(uniqueKey: UserDefaults.standard.object(forKey: "accountKey") as! String ,firstName: nickName ?? " ", lastName: " ", mapString: self.mapString!, mediaURL:self.mediaURL!, latitude:self.newLat!, longitude:self.newlong!)
        print("NewLocation:",newLocation)
        Parse.requestPostStudentInfo(postData: newLocation, completionHandler: handlePostLocationReponse(postLocationResponse:error:))
    }
    
    func handlePostLocationReponse(postLocationResponse:PostLocationResponse?, error:Error?) {
        
        guard postLocationResponse != nil else {
            print(error!)
            let alertVC = UIAlertController(title: "Add Location", message: error?.localizedDescription, preferredStyle: .alert)
            
            alertVC.addAction(UIAlertAction(title:"OK" , style: UIAlertAction.Style.default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            )
            present(alertVC, animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}

