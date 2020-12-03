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
    @IBOutlet weak var documentsImage: UIImageView!
    let tableViewVC: ProductVC! = nil
    var imageUrl = ""
    var nameProduct = [String]()
    var priceProduct = [String]()
    var descriptionProduct = [String]()
    var count = 0
    var currentTimeStamp = String(Int(NSDate().timeIntervalSince1970))
    var timeFromCPVC = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CreateButton.layer.cornerRadius = 20
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
        fetchData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        print("TimeStamp:- \(currentTimeStamp)")
        let defaults = UserDefaults.standard
        defaults.setValue(currentTimeStamp, forKey: "timeStamp")
    }
    
//    func format(f: String) -> String {
//        return NSString(format: "%\(f)f" as NSString, self) as String
//        }
//        func toString() -> String {
//            return String(format: "%.1f",self)
//        }

    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    // MARK:- Create Product Button
    @IBAction func createProductButton(_ sender: UIButton) {
        // MARK:- Connectivity Manager
        if CheckInternet.Connection(){
            if nameProduct.count != 0{
                for _ in 0..<nameProduct.count{
                    UPLOD()
//                    alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count])
                    count += 1
                    print(count)
                }

                DispatchQueue.main.async { [self] in
                    deleteData()
                }
//                UPLOD()
//                alamofireRequest(requestURL: "http://192.168.80.21:3204/api/product/create")

            }else{
                UPLOD()
            }

            //self.Alert(Message: "Connected")
            print("Network Connection Available")
//            proVC.tableViewReloadFromCreateProductVC()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            //retrievedImg.image = loadImageFromDiskWith(fileName: "newImg")
        }

        else{
            //self.Alert(Message: "Your Device is not connected with internet")
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
               DispatchQueue.main.async {
                firstVC.refreshTableView()
               }
           }
       }

    // MARK:- Create product Alamofire Post, with image
    func UPLOD(){
        let image  = myImageView.image
        
        var parameters = [String: Any]()
        parameters["Folder"] = "uploadfile"
        parameters["Filename"] = "demo3\(currentTimeStamp)"
        parameters["Ext"] = "png"
        parameters["FileToUpload"] = image?.jpegData(compressionQuality: 0.002)
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        print("Create button ACCESS KEY::::- \(token)")
        let headers = ["x-access-token": token]
                
        Alamofire.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
            for (key, value) in parameters {
                if key == "FileToUpload" {
                    multipartFormData.append(
                        value as! Data,
                        withName: "\(key)",
                        fileName: "demo3\(self.currentTimeStamp)",
                        mimeType: "image/png"
                    )
                }
                else {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        },usingThreshold: 1, to: "http://192.168.80.21:8800/api/v1/upload/uploadfile", method: .post, headers: headers) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
            switch encodingResult {
            
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let json = response.result.value as? [String: Any]
                    if let status = json?["status"] as? Int{
                        print(status)
                        if status != 200{
                            self.UPLOD()
                        }else{
                            self.alamofireRequest(requestURL: "http://192.168.80.21:3204/api/product/create")
                        }
                    }
                    print(response.result.value!)
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
        print("alamofireRequest:- \(imageUrl)")
        let parameters: [String: Any] = [
            "product_name" : nameField.text!,
            "price" : priceField.text!,
            "description" : descriptionField.text!,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "http://cdn-test.octopitech.com.bd/uploadfile/demo3\(currentTimeStamp).png",
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
        guard let data = image.jpegData(compressionQuality: 0.005) else { return }
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
    
    func alamoFireRequest(requestURL: String, name: String, price: String, descrip: String) {
        
        let parameters: [String: Any] = [
            "product_name" : name,
            "price" : price,
            "description" : descrip,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "http://cdn-test.octopitech.com.bd/uploadfile/rabbii.png",
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
                    _ = JSON(data)
                case .failure(let error):
                    print("need text")
                    print("Request failed with error: \(error)")
                }
            }
    }
  
    func fetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let manageContent = appDelegate.persistentContainer.viewContext
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        do {
            let result = try manageContent.fetch(fetchData)
            for data in result as! [NSManagedObject]{
                nameProduct.append(data.value(forKey: "name") as Any as! String)
                priceProduct.append(data.value(forKey: "price") as Any as! String)
                descriptionProduct.append(data.value(forKey: "proDescription") as Any as! String)
            }
            print(nameProduct)
            print(priceProduct)
        }catch {
            print("err")
        }
    }
    func deleteData() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results {
                if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                    context.delete(managedObjectData)
                }
            }
        } catch let error as NSError {
            print("Deleted all my data in myEntity error : \(error) \(error.userInfo)")
        }
    }
    
       @IBAction func selectImageButton(_ sender: UIButton) {
           imagePick()
       }
    
    
}
