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
    @IBOutlet weak var RefreshButton: UIButton!
    var array_product_name = [String]()
    var array_product_price = [String]()
    var array_product_image = [String]()
    var array_product_description = [String]()
    var array_product_compamnyName = [String]()
    var array_product_id = [Int]()
    var image_array = ""
    var array = ""
    var count = 0
    var nameProduct = [String]()
    var priceProduct = [String]()
    var descriptionProduct = [String]()
    var imageProduct = [String]()
    let CPVC = CreateProductVC()
    var coreDataImage = ""
    var timeStamp = "0"
    var documentsFetchImage = UIImage()
    var imageUrl = ""
    var imageX = UIImage()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewReloadGetDataFetchdata()
        present(CreateProductVC(), animated: true, completion: nil)
//        removeCoreData()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        print(nameProduct)
        if CheckInternet.Connection(){
            if nameProduct.count == 0{
                tableViewReloadGetDataFetchdata()
            }
            else{
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count], image: imageProduct[count])
//                DispatchQueue.main.async { [self] in
                    removeCoreData()
//                }
                tableViewReloadGetDataFetchdata()
            }
        }
        else{
            print("Network Connection is not Available")
        }
        refreshControl.endRefreshing()
    }
    
    @IBAction func refreshButton(_ sender: UIButton) {
        print(nameProduct)
        if CheckInternet.Connection(){
            if nameProduct.count == 0{
                tableViewReloadGetDataFetchdata()
            }
            else{
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count], image: imageProduct[count])
//                DispatchQueue.main.async { [self] in
                    removeCoreData()
//                }
                tableViewReloadGetDataFetchdata()
            }
        }
        else{
            print("Network Connection is not Available")
        }
    }
    
    func refreshTableView()  {
        print(nameProduct)
        if CheckInternet.Connection(){
            if nameProduct.count == 0{
                tableViewReloadGetDataFetchdata()
            }
            else{
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count], image: imageProduct[count])
//                DispatchQueue.main.async { [self] in
                    removeCoreData()
//                }
                tableViewReloadGetDataFetchdata()
            }
        }
        else{
            print("Network Connection is not Available")
        }
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(nameProduct)
        if CheckInternet.Connection(){
            if nameProduct.count == 0{
                tableViewReloadGetDataFetchdata()
            }
            else{
                UPLOAD()
                alamoFireRequest(requestURL: "http://192.168.80.21:3204/api/product/create", name: nameProduct[count], price: priceProduct[count], descrip: descriptionProduct[count], image: imageProduct[count])
//                DispatchQueue.main.async { [self] in
                    removeCoreData()
//                }
                tableViewReloadGetDataFetchdata()
            }
        }
        else{
            print("Network Connection is not Available")
        }
        refreshControl.endRefreshing()
    }
    
    
    
    func getTheData() {
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
                
                let resultArray = myresponse
                self.array_product_name.removeAll()
                self.array_product_id.removeAll()
                self.array_product_price.removeAll()
                self.array_product_description.removeAll()
                self.array_product_compamnyName.removeAll()
                self.array_product_image.removeAll()
                
                for i in resultArray!.arrayValue{
                    let product_id = i["product_id"].intValue
                    self.array_product_id.append(product_id)
                    
                    let product_name = i["product_name"].stringValue
                    self.array_product_name.append(product_name)
                    
                    let product_price = i["price"].stringValue
                    self.array_product_price.append(product_price)
                    
                    let product_des = i["description"].stringValue
                    self.array_product_description.append(product_des)
                    
                    let product_comName = i["company_name"].stringValue
                    self.array_product_compamnyName.append(product_comName)
                    
                    let product_image  = i["image_url"].stringValue
                    self.array_product_image.append(product_image)
                    
                    self.image_array = product_image
                    UserDefaults.standard.setValue(image_array, forKey: "url")
                }
            case .failure(_):
                print(Error.self)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func createProductButton(_ sender: UIButton) {
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
                nameProduct.append(data.value(forKey: "name") as Any as! String)
                priceProduct.append(data.value(forKey: "price") as Any as! String)
                descriptionProduct.append(data.value(forKey: "proDescription") as Any as! String)
                imageProduct.append(data.value(forKey: "imageName") as Any as! String)
            }
        }catch {
            print("err")
        }
    }
    
    // MARK:- Core Data- Delete
    func removeCoreData() {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Profile") // Find this name in your .xcdatamodeld file
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error.localizedDescription)
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
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func UPLOAD(){
        guard let time = UserDefaults.standard.string(forKey: "timeStamp") else {
            return
        }
        imageUrl = time
//        print(time)
//        print(imageProduct)
        
        imageX = loadImageFromDocumentDirectory(nameOfImage: "\(time)")
        
        var parameters = [String: Any]()
        parameters["Folder"] = "uploadfile"
        parameters["Filename"] = "demo3\(time)"
        parameters["Ext"] = "png"
        parameters["FileToUpload"] = imageX.jpegData(compressionQuality: 0.002)
        guard let token = UserDefaults.standard.string(forKey: "accesstoken") else {
            return
        }
        print("Create button ACCESS KEY::::- \(token)")
        let headers = ["x-access-token": token]
        
        Alamofire.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
            for (key, value) in parameters {
                if key == "FileToUpload" {
                    multipartFormData.append(value as! Data,withName: "\(key)",fileName: "demo3\(time)",mimeType: "image/png")
                }
                else {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        },usingThreshold: 1, to: "http://192.168.80.21:8800/api/v1/upload/uploadfile", method: .post, headers: headers) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
            switch encodingResult {
            
            case .success(let upload, _, _):
                upload.responseJSON { [self] response in
                    let json = response.result.value as? [String: Any]
                    if let status = json?["status"] as? Int{
                        print(status)
                        if status != 200{
                            self.UPLOAD()
                        }else{
                            tableViewReloadGetDataFetchdata()
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
    func alamoFireRequest(requestURL: String, name: String, price: String, descrip: String, image : String) {
        let parameters: [String: Any] = [
            "product_name" : name,
            "price" : price,
            "description" : descrip,
            "company_id" : "27",
            "category_id" : "1",
            "sub_category_id" : "1",
            "image_url" : "http://cdn-test.octopitech.com.bd/uploadfile/demo3\(imageUrl).png",
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
}
//MARK:- LoadImageFromDocumentDirectory
extension ProductVC{
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        return UIImage.init(named: "default.png")!
    }
}

extension ProductVC{
    func tableViewReloadGetDataFetchdata() {
        getTheData()
        fetchData()
    }
}

