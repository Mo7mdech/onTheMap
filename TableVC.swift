//
//  TableVC.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 20/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit

class TableVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var pinTableView: UITableView!
    @IBAction func reloadTableViewButton(_ sender: UIBarButtonItem) {
        reload()
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        print("log out pressed")
        Udacity.taskForDelete {
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var studentInfos: [StudentInformation] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        pinTableView.delegate = self
        pinTableView.dataSource = self
        navigationItem.title = "On The Map"
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInfos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentlocation", for: indexPath)
        
        pinTableView.estimatedRowHeight = 80
        pinTableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = studentInfos[indexPath.row].fullName
        cell.detailTextLabel?.text = studentInfos[indexPath.row].userUrl
        //cell.imageView?.image = UIImage(named: "icon_pin")
        //cell.detailTextLabel?.text = studentInfos[indexPath.row].mapString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = studentInfos[indexPath.row].userUrl
        if verifyUrl(urlString: url){
            let temp = URL(string: url)
            UIApplication.shared.open(temp!, options: [:])
        }else {
            showAlert(title: "Invalid URL", message: "Appears to be an invalid URL", titleResponse: "Ok")
        }
    }
    
    func handleGetStudentInfos(infos:[StudentInformation]?, error:Error?) {
        guard let infos = infos else {
            showInfo(withMessage: "Unable to Download Student Locations")
            print(error!)
            return
        }
        studentInfos = infos
        DispatchQueue.main.async {
            self.pinTableView.reloadData()
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func showAlert(title: String, message: String, titleResponse: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: titleResponse, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func reload() {
        Parse.requestOrderedLocations(completion: handleGetStudentInfos(infos:error:))
    }
}

