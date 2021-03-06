//
//  Test-Class.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 12/3/20.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

extension CreateProductVC{
    // MARK:- Create product Alamofire Post, with image
        func ImageUploadForCPVC(){
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
                    multipartFormData.append(value as! Data,withName: "\(key)",fileName: "demo3\(self.currentTimeStamp)",mimeType: "image/png")
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
                            self.ImageUploadForCPVC()
                        }else{
                            self.productCreateRequest(requestURL: "http://192.168.80.21:3204/api/product/create")
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
    
    //MARK:- Alamofire Post request to create product
    func productCreateRequest(requestURL: String) {
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
    // MARK:- Core Data- Delete
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
    
    func Alert (Message: String){
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
}
