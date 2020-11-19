//
//  ProductVC.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 10/29/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreData

class ProductVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var array_product_name = [String]()
    var array_product_price = [String]()
    var array_product_image = [String]()
    var array_product_description = [String]()
    var array_product_compamnyName = [String]()
    var image_array = ""
    var array = ""
    var count = 0
    var nameProduct = [String]()
    var priceProduct = [String]()
    var descriptionProduct = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate  = self
        tableView.dataSource = self
        getTheData()
        fetchData()
        
        if CheckInternet.Connection(){
            for _ in 0..<nameProduct.count{
                print(count)
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count])
                count += 1
                print(count)
            }
            DispatchQueue.main.async { [self] in
                deleteData()
            }
        }
        else{
            print("Network Connection is not Available")
        }
        present(CreateProductVC(), animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            
        tableView.reloadData()
        getTheData()
        fetchData()
        if nameProduct.count != 0{
            UPLOAD()
            alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count])
        }else{
            for _ in 0..<nameProduct.count{
                print(count)
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count])
                count += 1
                print(count)
            }
            
            DispatchQueue.main.async { [self] in
                deleteData()
            }
            
        }
        }
//    @IBAction func CallSecondViewButton(_ sender: Any) {
//            
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let controller = storyboard.instantiateViewController(withIdentifier: "CreateProductVC") as! CreateProductVC
//                        controller.modalPresentationStyle = .fullScreen
//                        self.present(controller, animated: true, completion: nil)
//        }

    func getTheData() {
        //print("Hello dear ::::::::::-\(accesstoken as Any)")
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        let headers = [
            "x-access-token": token,
        ]
        Alamofire.request("http://192.168.80.21:3204/api/product/get_all_products", headers: headers).responseJSON { [self]
            response in
            //debugPrint(response)
            
            switch response.result {
            case .success:
                
                let myresponse = try? JSON(data: response.data!)
                //print("hello\(myresponse as Any)")
                
                let resultArray = myresponse
                self.array_product_name.removeAll()
                
                for i in resultArray!.arrayValue{
                    let product_name = i["product_name"].stringValue
                    self.array_product_name.append(product_name)
                    //print("xoxoxoxox: - \(array_product_name)")
                    
                    let product_price = i["price"].stringValue
                    self.array_product_price.append(product_price)
                    
                    let product_des = i["description"].stringValue
                    self.array_product_description.append(product_des)
                    
                    let product_comName = i["company_name"].stringValue
                    self.array_product_compamnyName.append(product_comName)
                    //print("Company name ::::::::::::::-\(product_comName)")
                    
                    let product_image  = i["image_url"].stringValue
                    self.array_product_image.append(product_image)
                    //print("test ::::::::::::::-\(product_image)")
                    
                    self.image_array = product_image
                    //print("Test1:- \(self.image_array)")
                    UserDefaults.standard.setValue(image_array, forKey: "url")
                }
            case .failure(_):
                print(Error.self)
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func createProductButton(_ sender: UIButton) {
//        let goToCreateProductVc = storyboard?.instantiateViewController(identifier: "CreateProductVC")
//        present(goToCreateProductVc!, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateProductVC") as! CreateProductVC
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
 
    // MARK:- Core Data- Retrieve
    func fetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let manageContent = appDelegate.persistentContainer.viewContext
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        do {
            let result = try manageContent.fetch(fetchData)
            for data in result as! [NSManagedObject]{
                //                nameProduct = data.value(forKeyPath: "name") as Any as! String
                //                priceProduct = data.value(forKeyPath: "price") as Any as! String
                //                descriptionProduct = data.value(forKeyPath: "proDescription") as Any as! String
                //
                nameProduct.append(data.value(forKey: "name") as Any as! String)
                priceProduct.append(data.value(forKey: "price") as Any as! String)
                descriptionProduct.append(data.value(forKey: "proDescription") as Any as! String)
                
                
            }
            //            print("Name:- \(nameProduct[0])")
            //            print("Name:- \(nameProduct[1])")
            print(nameProduct)
            print(priceProduct)
        }catch {
            print("err")
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
}
// MARK:- TableView
extension ProductVC {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_product_name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CellTableViewCell
        
        cell?.productName.text = array_product_name[indexPath.row]
        cell?.productPrice.text = array_product_price[indexPath.row]
        cell?.productImageLbl.sd_setImage(with: URL(string: array_product_image[indexPath.row]))
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goToProductDetailVC = storyboard?.instantiateViewController(identifier: "ProductDetailVC") as? ProductDetailVC
        present(goToProductDetailVC!, animated: true, completion: nil)
        goToProductDetailVC?.proName = array_product_name[indexPath.row]
        goToProductDetailVC?.proPrice = array_product_price[indexPath.row]
        goToProductDetailVC?.proDes = array_product_description[indexPath.row]
        goToProductDetailVC?.comName = array_product_compamnyName[indexPath.row]
        goToProductDetailVC?.proImg = array_product_image[indexPath.row]
    }
}
// MARK:- Network Requests
extension ProductVC{
    func UPLOAD(){
        //let image  = myImageView.image!
        let serviceName = "http://192.168.80.21:8800/api/v1/upload/uploadfile"
        var parameters = [String: AnyObject]()
        parameters["Folder"] = "uploadfile" as AnyObject?
        parameters["Filename"] = "rabbii" as AnyObject?
        parameters["Ext"] = "png" as AnyObject?
        
        //        let profileImageData = image
        //        if let imageData = profileImageData.jpegData(compressionQuality: 0.5) {
        //            parameters["FileToUpload"] = imageData as AnyObject?
        //        } else {
        //            print("Image problem")
        //        }
        
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
        //        saveImage(imageName: "newImg", image: myImageView.image!)
        
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
                upload.responseJSON { [] response in
                    
                    if let Response = response.result.value as? [String : Any],
                       let myData = Response["data"] as? [String : Any],
                       let imgPath = myData["ImagePath"]  {
                        //                        imageUrl = imgPath as! String
                        //print(imageUrl)
                        //print("ImagePath --> ", imgPath)
                        let defaults = UserDefaults.standard
                        //                        defaults.setValue(imageUrl, forKey: "imageURL")
                        //                        let key = defaults.object(forKey: "imageURL")
                        //                        print(key as Any)
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
    func alamoFireRequest(requestURL: String, name: String, price: String, descrip: String) {
        //        guard let imageU = UserDefaults.standard.string(forKey: "imageURL") else {
        //            return
        //        //        }
        //        for i in nameProduct{
        //            print(i)
        //        }
        
        let parameters: [String: Any] = [
            "product_name" : name,
            "price" : price,
            "description" : descrip,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "https://cdn-test.octopitech.com.bd/uploadfile/rabbii.png",
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
}
