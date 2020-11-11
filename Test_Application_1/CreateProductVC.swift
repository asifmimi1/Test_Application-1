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
    let reload = ProductVC()
    
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
        
    }
    
    
    @IBAction func selectImageButton(_ sender: UIButton) {
        imagePick()
    }
 
    func imagePick() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            myImageView.image = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            myImageView.image = originalImage
            //print("MyImageView:::::\(String(describing: myImageView))")
        }
    }
    func UPLOD(){
        let image = "Angela"
        let serviceName = "http://192.168.80.21:8800/api/v1/upload/uploadfile"
        var parameters = [String: AnyObject]()
        parameters["Folder"] = "uploadfile" as AnyObject?
        parameters["Filename"] = "myImageNew" as AnyObject?
        parameters["Ext"] = "jpeg" as AnyObject?
        
        if let profileImageData = UIImage(named: image) {
            if let imageData = profileImageData.jpegData(compressionQuality: 0.5) {
                parameters["FileToUpload"] = imageData as AnyObject?
//                APIManager.apiMultipart(serviceName: serviceName, parameters: parameters, completionHandler: { (response: JSON , error:NSError?) in
//                //Handle response
//                })
               
            } else {
               print("Image problem")
            }
        }

        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        print("Create button ACCESS KEY::::- \(token)")
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
          //        //let image = UIImage(named: "ring")
//        let image = myImageView.image
//        let imgData = image!.jpegData(compressionQuality: 0.7)!
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
                    for (key, value) in parameters {
                        if key == "FileToUpload" {
                            multipartFormData.append(
                                value as! Data,
                                withName: key,
                                fileName: "swift_file.jpeg",
                                mimeType: "image/jpeg"
                            )
                        } else {
                            //Data other than image
                            multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                        }
                    }
                }, usingThreshold: 1, to: serviceName, method: .post, headers: headers) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in

                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if response.result.error != nil {
//                                completionHandler(nil,response.result.error as NSError?)
//                                return
                            }
                            print(response.result.value!)
                            if let data = response.result.value {
                                let json = JSON(data)
//                                completionHandler(json,nil)
                                print(json)
                            }
                        }
                        break

                    case .failure(let encodingError):
                        print(encodingError)
//                        completionHandler(nil,encodingError as NSError?)
                        break
                    }
                }
            }
  

    func alamofireRequest(requestURL: String) {
        let parameters: [String: Any] = [
            "product_name" : nameField.text!,
            "price" : priceField.text!,
            "description" : descriptionField.text!,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "https://cdn-test.octopitech.com.bd/uploadfile/demo3.jpeg",
            "date_entered" : "2020-02-17"
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




//extension CreateProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    func imagePick() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        dismiss(animated: true, completion: nil)
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
//            myImageView.image = editedImage
//        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
//            myImageView.image = originalImage
//        }
//    }
//    let imageData = UIImagePNGRepresentation(self.sd_)
//}

//Alamofire.upload(multipartFormData: { (multipartFormData) in
//        multipartFormData.append(imgData, withName: "filedata", fileName: "filedata.jpg", mimeType: "image/jpeg")
//        print("mutlipart 1st \(multipartFormData)")
//        if (apiParams != nil)
//        {
//            for (key, value) in apiParams! {
//                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String )
//            }
//            print("mutlipart 2nd \(multipartFormData)")
//        }
//    }, to:uploadPath, method:.post, headers:headers)
//    { (result) in
//        switch result {
//        case .success(let upload, _, _):
//
//            upload.uploadProgress(closure: { (Progress) in
//                completionHandler(.uploading(progress: Float(Progress.fractionCompleted)))
//            })
//
//            upload.responseJSON { response in
//
//                if let JSON = response.result.value {
//                    completionHandler(.success(progress: 1.0, response: JSON as! NSDictionary))
//                }
//            }
//        case .failure(let encodingError):
//            print(encodingError)
//            completionHandler(.failure(error: encodingError as NSError))
//        }
//    }
