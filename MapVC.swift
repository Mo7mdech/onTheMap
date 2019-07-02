//
//  MapVC.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 18/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    var sessionID:String = ""
    var mapAnnotations = [MKAnnotation]()
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        reloadMapView()
    }
    @IBAction func addPinButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addLocation", sender: nil)
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        print("log out pressed")
        Udacity.taskForDelete {
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    var studentInfos:[StudentInformation] = []
    var userInfo : StudentInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "On The Map"
        let _ = self.tabBarController?.tabBar.items
        reloadMapView()
        mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadMapView()
    }
    
    @objc func reloadMapView(){
        Udacity.requestSignedInUserInfo(completionHandler: handleGetSingleStudentInfo(userInfo:error:))
        
        Parse.requestOrderedLocations(completion: handleGetStudentInfo(studentInfos:error:))
        
        Parse.requestLimitedStudents(completion: handleGetStudentInfo(studentInfos:error:))
        
    }
    
    func handleGetStudentInfo(studentInfos:[StudentInformation]?, error:Error?) {
        guard let studentInfos = studentInfos else {
            showInfo(withMessage: "Unable to Download Student Locations")
            print(error!)
            return
        }
        createMapAnnotation(studentInfos:studentInfos)
    }
    
    func handleGetSingleStudentInfo(userInfo:StudentInfo?, error:Error?) {
        guard userInfo != nil else {
            showInfo(withMessage: "Unable to Download Your Student Infomation")
            print(error!)
            return
        }
        print("student info: ",userInfo!.nickname)
    }
    
    func createMapAnnotation(studentInfos:[StudentInformation]) {

        for info in studentInfos {
            guard let latitude = info.latitude, let longitude = info.longitude else { continue }
            let title = info.fullName
            let lat = CLLocationDegrees(latitude)
            let long = CLLocationDegrees(longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let mediaURL = info.userUrl
            print("student infos: ",info)
            
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = coordinate
            annotation.subtitle = mediaURL
            mapAnnotations.append(annotation)
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(mapAnnotations)
        
        //self.mapView.addAnnotations(mapAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView) {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                guard !url.isEmpty else {
                    showInfo(withMessage: "No Valid URl")
                    return
                }
                app.open(URL(string: url)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    
}

