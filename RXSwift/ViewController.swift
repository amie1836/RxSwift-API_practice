//
//  ViewController.swift
//  RXSwift
//
//  Created by jamie on 2024/1/11.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let disposebag = DisposeBag()
    
    @IBOutlet weak var repoLabel: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    let basicURL =  "https://api.github.com/search/repositories"
    var FirstURLString = "https://cdn2.thecatapi.com/images/wFQIf01uy.jpg"
    var FirstImgURL: URL {
        get {
            return URL(string: FirstURLString)!
        }
    }
    
    let urlSession = URLSession(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let textFieldObservable = textField.rx.text.orEmpty.asObservable()
        
        
        
        textFieldObservable.subscribe (onNext:{ string in
            //字有改變就丟出request
            let searchString = self.basicURL + "?q=\(string)"
            guard let searchURL = URL(string: searchString) else {
                print("Fail to transform SearchText to URL")
                return
            }
            
            let task = self.urlSession.dataTask(with: searchURL) { data, response, error in
                guard error == nil else {
                    print("************")
                    print(error?.localizedDescription)
                    return
                }
                
                if let data = data {
                    do {
                        var repoName:String
                        
                        let jsonDic1 = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                        
                        if let jsonDic1 = jsonDic1 {
                            if let item = jsonDic1["items"] as? [[String: Any]]{
                                if item.count != 0 {
                                   let name = item[0]["name"] as! String

                                    repoName = name
                                    DispatchQueue.main.async {
                                        self.repoLabel.text = repoName
                                    }
                                  
                                    if let owner = item[0]["owner"] as? [String:Any] {
                                       let ownerName = owner["login"] as! String
                                       let ownerImageURL = owner["avatar_url"] as! String
                                        self.FirstURLString = ownerImageURL
                                        
                                    }
                                } else {
                                    print("No corresponded results for searching keyowrd")
                                }
                                
                                for i in 0...item.count - 1 {
                                    let name = item[i]["name"] as! String
                                    let owner = self.transDictValueToDict(dict: item[i], key: "owner")
                                    if let ownerName = owner?["login"] as? String {
                                        print("RepoName:" + name)
                                        print("OwnerName:" + ownerName + "\n")
                                    }
                                }
                            }
                        }
                    } catch {
                        print("JsonSerialization Fail")
                    }
                }
            }
        task.resume()
        }).disposed(by: disposebag)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        let task = self.urlSession.dataTask(with : FirstImgURL) { data, response, error in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                if let data = data {
                    
                    if let image =  UIImage(data: data){
                        self.avatar.image = image
                        
                    } else {
                        print("Fail to convert image")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func transDictValueToDict(dict:[String:Any],key:String) -> [String:Any]?{
        
        guard let valueDict = dict[key] as? [String:Any] else {
            print("func transDict Fail: no corresponded value for key ")
            return nil
        }
        return valueDict
        //
    }
}
