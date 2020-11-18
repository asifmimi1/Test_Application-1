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
    @IBOutlet weak var retrievedImg: UIImageView!
    let tableViewVC: ProductVC! = nil
    var imageUrl = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CreateButton.layer.cornerRadius = 20
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    // MARK:- Create Product Button
    @IBAction func createProductButton(_ sender: UIButton) {
        
        //http://192.168.80.21:3204/api/product/create
        alamofireRequest(requestURL: "http://192.168.80.21:3204/api/product/create")
        UPLOD()
        // MARK:- Connectivity Manager
        if CheckInternet.Connection(){
            //self.Alert(Message: "Connected")
            print("Network Connection Available")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            //retrievedImg.image = loadImageFromDiskWith(fileName: "newImg")
        }
        else{
            //self.Alert(Message: "Your Device is not connected with internet")
            save(name: nameField.text!, proDescription: descriptionField.text!, price: priceField.text!, imageName: "newImg")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectImageButton(_ sender: UIButton) {
        imagePick()
    }
    
    //MARK:- Image Picker
    func imagePick() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            myImageView.image = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            myImageView.image = originalImage
        }
    }
    // MARK:- Save image to File System
    func saveImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    // MARK:- Core Data- Create
    func save(name: String, proDescription: String, price: String, imageName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Profile",in: managedContext)!
        let profile = NSManagedObject(entity: entity,insertInto: managedContext)
        
        profile.setValue(name, forKeyPath: "name")
        profile.setValue(price, forKey: "price")
        profile.setValue(proDescription, forKey: "proDescription")
        profile.setValue(imageName, forKey: "imageName")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK:- Create product Alamofire Post, with image
    func UPLOD(){
        let image  = myImageView.image!
        let serviceName = "http://192.168.80.21:8800/api/v1/upload/uploadfile"
        var parameters = [String: AnyObject]()
        parameters["Folder"] = "uploadfile" as AnyObject?
        parameters["Filename"] = "AsifRabbi" as AnyObject?
        parameters["Ext"] = "jpg" as AnyObject?
        
        //save(name: nameField.text!, proDescription: descriptionField.text!, price: priceField.text!, imageName: "newImg")
        let profileImageData = image
        if let imageData = profileImageData.jpegData(compressionQuality: 0.5) {
            parameters["FileToUpload"] = imageData as AnyObject?
        } else {
            print("Image problem")
        }
        
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        print("Create button ACCESS KEY::::- \(token)")
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
        saveImage(imageName: "newImg", image: myImageView.image!)
        
        Alamofire.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
            for (key, value) in parameters {
                if key == "FileToUpload" {
                    multipartFormData.append(
                        value as! Data,
                        withName: key,
                        fileName: "swift_file.jpg",
                        mimeType: "image/jpg"
                    )
                } else {
                    //Data other than image
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
            }
        }, usingThreshold: 1, to: serviceName, method: .post, headers: headers) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { [self] response in
                    
                    if let Response = response.result.value as? [String : Any],
                       let myData = Response["data"] as? [String : Any],
                       let imgPath = myData["ImagePath"]  {
                        imageUrl = imgPath as! String
                        //print(imageUrl)
                        //print("ImagePath --> ", imgPath)
                        let defaults = UserDefaults.standard
                        defaults.setValue(imageUrl, forKey: "imageURL")
                        let key = defaults.object(forKey: "imageURL")
                        print(key as Any)
                    }
                    
                    if let data = response.result.value {
                        let _ = JSON(data)
                    }
                }
                break
                
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
    }
    
    // MARK:- Get product with Alamofire Get
    func alamofireRequest(requestURL: String) {
        guard let imageU = UserDefaults.standard.string(forKey: "imageURL") else {
            return
        }
        let parameters: [String: Any] = [
            "product_name" : nameField.text!,
            "price" : priceField.text!,
            "description" : descriptionField.text!,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "https://cdn-test.octopitech.com.bd/\(imageU)",
            "date_entered" : "2020-02-20"
        ]
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        let headers = [
            "x-access-token": token,
        ]
        Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseString { response in
                
                switch response.result {
                
                case .success(let data):
                    //print("isi: \(data)")
                    _ = JSON(data)
                    
                case .failure(let error):
                    print("need text")
                    print("Request failed with error: \(error)")
                    
                }
            }
    }
    
    func Alert (Message: String){
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
}
