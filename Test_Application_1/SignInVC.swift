//
//  SignInVCViewController.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 10/29/20.
//

import UIKit
import Alamofire
import SwiftyJSON


class SignInVCViewController: UIViewController {
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let button = logInButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.layer.cornerRadius = 20
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard(){
        //Causes the view to resign from the status of first responder.
        view.endEditing(true)
    }
    // http://192.168.80.21:3204/api/auth/signin
    
    @IBAction func logInButton(_ sender: UIButton) {
        
        let parameters: [String: Any] = [
            "username" : userNameField.text!,
            "password" : passwordField.text!
        ]
        
        Alamofire.request("http://192.168.80.21:3204/api/auth/signin", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                
                case .success(let data):
                    //print("isi: \(data)")
                    let json = JSON(data)
                    print(json["accessToken"].stringValue)
                    //print(json["auth"].boolValue)
                    //print(json["role"].stringValue)
                    
                    if(self.userNameField.text == "zkrony" && self.passwordField.text == "123456"){
//                        let goToProductVC = self.storyboard?.instantiateViewController(identifier: "ProductVC")
//                        self.present(goToProductVC!, animated: true, completion: nil)
//                        goToProductVC?.modalPresentationStyle = .fullScreen
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let controller = storyboard.instantiateViewController(withIdentifier: "ProductVC") as! ProductVC
                                            
                                            controller.modalPresentationStyle = .fullScreen
                                            self.present(controller, animated: true, completion: nil)
                        
                        let defaults = UserDefaults.standard
                        defaults.setValue(json["accessToken"].stringValue, forKey: "accesstoken")
                        //JSON.init(parseJSON: "accesstoken")
                        defaults.object(forKey: "accesstoken")
                        //print("Key 1::::::-\(key!)")
                        
                        self.userNameField.text = ""
                        self.passwordField.text = ""
                        break
                        
                    }else if (self.userNameField.text != "zkrony" || self.passwordField.text != "123456") {
                        let alert = UIAlertController(title: "Error Signing In", message: json["reason"].stringValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    print("need text")
                    print("Request failed with error: \(error)")
                }
            }
    }
}
