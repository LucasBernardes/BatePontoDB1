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
import CoreLocation
import KOAlertController
import SPPermission

class LoginViewController: UIViewController, CLLocationManagerDelegate, SPPermissionDialogDataSource, SPPermissionDialogColorSource{

    private var images = [UIImage.init(named: "location")!, UIImage.init(named: "notification")!]
    var responseString = ""
    var allowSegue = false
    public static let erroTitulo = "Problema na conexão!"
    public static let erroCpfTitulo = "Problema com o CPF"
    public static let erroCpfMensagem = "O CPF informado não foi encontrado na base de dados, por favor verifique o valor inserido"
    public static let erroSemTitulo = "Campo de CPF/Senha branco"
    public static let erroSemMensagem = "Por favor preencha ambos os campos antes de fazer a requisição de login"
    public static let erroSenhaTitulo = "Problema com a senha ou CPF"
    public static let erroSenhaMensagem = "A Senha não confere ou o CPF informado não foi encontrado na base de dados, por favor verifique os valores inseridos"
    public static let erroMensagem = "Houve um problema com os servidores e não foi possível executar esta ação"
    public static let erroLocationMensagem = "Para bater o ponto é necessário saber se você se encontra dentro da empresa, para isso o aplicativo necessita utlizar o localizador, por favor atorize sua utilização"
    public static let erroLocationTitulo = "O aplicativo precisa da sua localização"
    public static let erroBotao = "Compreendi"
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var cpfField: AKMaskField!
    @IBOutlet weak var poweredImage: UIImageView!
    
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        self.loginButton.layer.cornerRadius = 10
        self.loginButton.applyGradient(colors: [(UIColor.vermelhoEscuro()?.cgColor)!,(UIColor.vermelhoClaro()?.cgColor)!])
        self.cpfField.layer.cornerRadius = 10
        self.senhaField.layer.cornerRadius = 10
        self.activityIndicator.startAnimating()
        self.cpfField.setLeftPaddingPoints(15.0)
        self.senhaField.setLeftPaddingPoints(15.0)
        self.senhaField.isSecureTextEntry = true
        self.cpfField.maskExpression = "{ddd}.{ddd}.{ddd}-{dd}"
        self.cpfField.maskTemplate = "              "
        locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        self.poweredImage.image = self.poweredImage.image?.maskWithColor(color: .lightGray)
        
        
    }
    
    @objc func name(for permission: SPPermissionType) -> String?{
        if(permission.rawValue == 8){
            return "Local"
        }
        else if(permission.rawValue == 9){
            return "Chegada na DB1"
        }else{
            return "Notificação"
        }
    }
    
    @objc func description(for permission: SPPermissionType) -> String?{
        if(permission.rawValue == 8){
            return "Necessário para bater o ponto"
        }
        else if(permission.rawValue == 9){
            return "Opcional para aviso de chegada"
        }else{
            return "Notificação de chegada/saída da empresa"
        }
    }
    
    @objc public func image(for permission: SPPermissionType) -> UIImage?{
        if(permission.rawValue == 8){
            return UIImage.init(named: "local")
        }
        else if(permission.rawValue == 9){
            return UIImage.init(named: "location")
        }else{
            return UIImage.init(named: "notification")
        }
    }
    
    var baseColor: UIColor {
        return UIColor.red
    }
    
    var dialogSubtitle: String {
        return "A permissão da localização atual dentro do app é obrigatória para bater o ponto, já a localização no background só é necessária para o aviso automático de chegada na empresa!"
    }
    
    var dialogTitle: String {
        return "Lista de Permissão"
    }
    var dialogComment: String {
        return "Para bater o ponto é necessário estar a 300m da empresa, caso optando pela opção de localização no background o aplicativo irá avisar assim que for possível bater o ponto."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(SPPermission.isAllow(.locationAlways)){
            self.allowSegue = true
            UIApplication.shared.cancelAllLocalNotifications()
            let locattionnotification = UILocalNotification()
            locattionnotification.alertBody = "Voce chegou na DB1"
            locattionnotification.regionTriggersOnce = false
            locattionnotification.region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:
                -23.4192021, longitude: -51.9356276), radius: 300.0, identifier: "DB1")
            UIApplication.shared.scheduleLocalNotification(locattionnotification)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if(!SPPermission.isAllow(.locationAlways) || !SPPermission.isAllow(.locationWhenInUse)){
            SPPermission.Dialog.request(with: [.locationWhenInUse, .locationAlways, .notification], on: self, dataSource: self, colorSource: self)
        }
    }
    
    func startAnimating(){
        self.activityIndicator.startAnimating()
        self.loginButton.setTitle("", for: .normal)
        self.activityIndicator.isHidden = false
        
    }
    
    func stopAnimating(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.loginButton.setTitle("Login", for: .normal)
    }
    
    func mostraMensagem(titulo: String, mensagem: String, botao: String){
        let alertController = KOAlertController("\(titulo)", "\(mensagem)", UIImage(named:"alert"))
        alertController.style.cornerRadius = 10
        let defButton                   = KOAlertButton(.default, title:"\(botao)")
        defButton.backgroundColor       = UIColor.black
        defButton.titleColor            = UIColor.white
        defButton.cornerRadius = 10
        alertController.addAction(defButton) {
            self.stopAnimating()
            if(titulo == LoginViewController.erroLocationTitulo){
                SPPermission.Dialog.request(with: [.locationWhenInUse, .locationAlways, .notification], on: self, dataSource: self, colorSource: self)
            }
        }
        self.present(alertController, animated: true){}
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if(!SPPermission.isAllow(.locationAlways) || !SPPermission.isAllow(.locationWhenInUse)){
            self.mostraMensagem(titulo: LoginViewController.erroLocationTitulo, mensagem: LoginViewController.erroLocationMensagem, botao: LoginViewController.erroBotao)
            return
        }
        
        self.startAnimating()
        if(self.cpfField.text! == "" || self.senhaField.text! == ""){
            self.mostraMensagem(titulo: LoginViewController.erroSemTitulo, mensagem: LoginViewController.erroSemMensagem, botao: LoginViewController.erroBotao)
            return
        }
        var request = URLRequest(url: URL(string: "https://registra.pontofopag.com.br/")!)
        request.httpMethod = "POST"
        var string = [String : String]()
        string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "\(self.cpfField.text!)","Password": "\(self.senhaField.text!)","Lembrarme": "false","tipo": "1"]
        print(string)
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
                    self.mostraMensagem(titulo: LoginViewController.erroTitulo, mensagem: LoginViewController.erroMensagem, botao: LoginViewController.erroBotao)
                }
                print("Erro chamada")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: LoginViewController.erroTitulo, mensagem: LoginViewController.erroMensagem, botao: LoginViewController.erroBotao)
                }
                print("Problema Conexão")
                return
            }
            self.responseString = String(data: data, encoding: .utf8)!
            print(self.responseString)
            if(self.responseString.range(of:"CPF inv&#225;lido") != nil){
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: LoginViewController.erroCpfTitulo, mensagem: LoginViewController.erroCpfMensagem, botao: LoginViewController.erroBotao)
                }
                print("CPF ERRADo")
                return
            }
            else if(self.responseString.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: LoginViewController.erroSenhaTitulo, mensagem: LoginViewController.erroSenhaMensagem, botao: LoginViewController.erroBotao)
                }
                print("Senha errad")
                return
            }
            else{
                OperationQueue.main.addOperation{
                    self.stopAnimating()
                    UserDefaults.standard.set(self.cpfField.text!.trimmingCharacters(in: CharacterSet.whitespaces), forKey: "cpf")
                    UserDefaults.standard.set(self.senhaField.text!, forKey: "senha")
                    self.performSegue(withIdentifier: "menuSegue", sender: nil)
                }
            }
        }
        task.resume()
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
extension UIImage {
    
    public func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
}
