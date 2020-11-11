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

class ProductVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var array_product_name = [String]()
    var array_product_price = [String]()
    var array_product_image = [String]()
    var array_product_description = [String]()
    var array_product_compamnyName = [String]()
    var image_array = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate  = self
        tableView.dataSource = self
        
        getTheData()
    }
    
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
                //print(myresponse as Any)
                
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
        let goToCreateProductVc = storyboard?.instantiateViewController(identifier: "CreateProductVC")
        present(goToCreateProductVc!, animated: true, completion: nil)
    }
    
    
}
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
        cell?.productImageLbl.sd_setImage(with: URL(string: image_array), completed: nil)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goToProductDetailVC = storyboard?.instantiateViewController(identifier: "ProductDetailVC") as? ProductDetailVC
        present(goToProductDetailVC!, animated: true, completion: nil)
        goToProductDetailVC?.proName = array_product_name[indexPath.row]
        goToProductDetailVC?.proPrice = array_product_price[indexPath.row]
        goToProductDetailVC?.proDes = array_product_description[indexPath.row]
        goToProductDetailVC?.comName = array_product_compamnyName[indexPath.row]
        
    }
    
}
