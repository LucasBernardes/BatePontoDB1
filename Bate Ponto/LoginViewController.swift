//
//  LoginViewController.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 18/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import AKMaskField
import Alamofire

class LoginViewController: UIViewController {
    let vermelhoEscuro = UIColor(red: 252/255, green: 46/255, blue: 82/255, alpha: 1.0).cgColor
    let vermelhoClaro = UIColor(red: 254/255, green: 86/255, blue: 49/255, alpha: 1.0).cgColor
    let vermelhoClaroUIColor = UIColor(red: 252/255, green: 46/255, blue: 82/255, alpha: 1.0)
    var responseString = ""
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var cpfField: AKMaskField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        self.loginButton.layer.cornerRadius = 10
        self.loginButton.applyGradient(colors: [self.vermelhoEscuro,self.vermelhoClaro])
        self.cpfField.layer.cornerRadius = 10
        self.senhaField.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        self.cpfField.setLeftPaddingPoints(15.0)
        self.senhaField.setLeftPaddingPoints(15.0)
        self.senhaField.isSecureTextEntry = true
        self.cpfField.maskExpression = "{ddd} {ddd} {ddd} {dd}"
        self.cpfField.maskTemplate = "              "
        
    }
    
    func startAnimating(){
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = true
        self.loginButton.setTitle("", for: .normal)
    }
    func stopAnimating(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = false
        self.loginButton.setTitle("Login", for: .normal)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        
        self.startAnimating()
        
        var request = URLRequest(url: URL(string: "https://registra.pontofopag.com.br/")!)
        request.httpMethod = "POST"
        var string = [String : String]()
        string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "083.441.709-07","Password": "jsbvt9","Lembrarme": "false","tipo": "1"]
        let enconding = URLEncoding.queryString
        request.addValue("https://registra.pontofopag.com.br/", forHTTPHeaderField: "Referer")
        request.addValue("https://registra.pontofopag.com.br", forHTTPHeaderField: "Origin")
        request.addValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393", forHTTPHeaderField: "User-Agent")
        
        request = try! enconding.encode(request, with: string)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                    
                }
                print("Erro chamada")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                }
                print("Problema Conexão")
                return
                
            }
            self.responseString = String(data: data, encoding: .utf8)!
            if(self.responseString.range(of:"CPF inv&#225;lido") != nil){
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                }
                print("CPF ERRADo")
                return
            }
            else if(self.responseString.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                }
                print("Senha errad")
                return
            }
            else{
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                    self.performSegue(withIdentifier: "menuSegue", sender: nil)
                }
                
            }
            
            
            
            
            
            
        }
        task.resume()
 
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        if((self.cpfField.text?.isEmpty)!){
            let cpfArray = Array(self.cpfField.text!)
            for elements in cpfArray{
                //self.
            }
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "menuSegue"){
            let vc = segue.destination as! ViewController
            vc.htmlString = self.responseString
        }
    }
    
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
