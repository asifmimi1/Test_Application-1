//
//  CreateProductVC.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 11/5/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreData

class CreateProductVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var CreateButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    var nameProduct = [String]()
    var currentTimeStamp = String(Int(NSDate().timeIntervalSince1970))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CreateButton.layer.cornerRadius = 20
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        let defaults = UserDefaults.standard
        defaults.setValue(currentTimeStamp, forKey: "timeStamp")
    }

    // MARK:- Create Product Button
    @IBAction func createProductButton(_ sender: UIButton) {
        // MARK:- Connectivity Manager
        if CheckInternet.Connection(){
            if nameProduct.count != 0{
                for _ in 0..<nameProduct.count{
                    ImageUploadForCPVC()
//                    alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count])
                }
                DispatchQueue.main.async { [self] in
                    deleteData()
                }
//                UPLOD()
            }else{
                ImageUploadForCPVC()
            }

            //self.Alert(Message: "Connected")
            print("Network Connection Available")
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }

        else{
//            self.Alert(Message: "Your Device is not connected with internet")
            save(name: nameField.text!, proDescription: descriptionField.text!, price: priceField.text!, imageName: "\(currentTimeStamp)")
            saveImage(imageName: "\(currentTimeStamp).png", image: myImageView.image!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    //MARK:- View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)

        if let firstVC = presentingViewController as? ProductVC {
               DispatchQueue.main.async {firstVC.refreshTableView()}
           }
       }
       @IBAction func selectImageButton(_ sender: UIButton) {
           imagePick()
       }
}
