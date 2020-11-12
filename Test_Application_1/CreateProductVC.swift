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

class CreateProductVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var CreateButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
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
    
    @IBAction func createProductButton(_ sender: UIButton) {
        
        //http://192.168.80.21:3204/api/product/create
        alamofireRequest(requestURL: "http://192.168.80.21:3204/api/product/create")
        UPLOD()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageButton(_ sender: UIButton) {
        imagePick()
    }
    
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
    func UPLOD(){
        let image  = myImageView.image!
        let serviceName = "http://192.168.80.21:8800/api/v1/upload/uploadfile"
        var parameters = [String: AnyObject]()
        parameters["Folder"] = "uploadfile" as AnyObject?
        parameters["Filename"] = "Asif" as AnyObject?
        parameters["Ext"] = "png" as AnyObject?
        
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
        
        Alamofire.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
            for (key, value) in parameters {
                if key == "FileToUpload" {
                    multipartFormData.append(
                        value as! Data,
                        withName: key,
                        fileName: "swift_file.png",
                        mimeType: "image/png"
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
                        
                        //print(json["ImagePath"].stringValue)
                        //                                completionHandler(json,nil)
                        //print(json)
                    }
                }
                break
                
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
    }
    
    
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
        print("Create button ACCESS KEY::::- \(token)")
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
}
