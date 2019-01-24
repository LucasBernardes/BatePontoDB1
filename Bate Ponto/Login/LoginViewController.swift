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

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    private var images = [UIImage.init(named: "location")!, UIImage.init(named: "notification")!]
    var locationManager: CLLocationManager = CLLocationManager()
    var allowSegue = false
    var responseString = ""
    private var viewModel: LoginViewModel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var cpfField: AKMaskField!
    @IBOutlet weak var poweredImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        viewModel.delegate = self
        configureElementes()
        configureDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        configureAlertLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        requestLocation()
    }
    
    private func configureElementes(){
        self.activityIndicator.isHidden = true
        self.senhaField.isSecureTextEntry = true
        self.loginButton.layer.cornerRadius = 10
        self.cpfField.layer.cornerRadius = 10
        self.senhaField.layer.cornerRadius = 10
        self.activityIndicator.startAnimating()
        self.cpfField.setLeftPaddingPoints(15.0)
        self.senhaField.setLeftPaddingPoints(15.0)
        self.cpfField.maskExpression = "{ddd}.{ddd}.{ddd}-{dd}"
        self.cpfField.maskTemplate = "              "
        self.poweredImage.image = self.poweredImage.image?.maskWithColor(color: .lightGray)
        self.loginButton.applyGradient(colors: [(UIColor.vermelhoEscuro()?.cgColor)!,(UIColor.vermelhoClaro()?.cgColor)!])
        
    }
    
    private func configureDelegate(){
        locationManager.delegate = self
    }
    
    private func configureAlertLocation(){
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
    
    private func requestLocation(){
        if(!SPPermission.isAllow(.locationAlways) || !SPPermission.isAllow(.locationWhenInUse)){
            SPPermission.Dialog.request(with: [.locationWhenInUse, .locationAlways, .notification], on: self, dataSource: self, colorSource: self)
        }
    }

    private func startAnimating(){
        self.activityIndicator.startAnimating()
        self.loginButton.setTitle("", for: .normal)
        self.activityIndicator.isHidden = false
        
    }
    
    private func stopAnimating(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.loginButton.setTitle("Login", for: .normal)
    }
    
    private func mostraMensagem(titulo: String, mensagem: String, botao: String){
        let alertController = KOAlertController("\(titulo)", "\(mensagem)", UIImage(named:"alert"))
        alertController.style.cornerRadius = 10
        let defButton = KOAlertButton(.default, title:"\(botao)")
        defButton.backgroundColor = UIColor.black
        defButton.titleColor = UIColor.white
        defButton.cornerRadius = 10
        alertController.addAction(defButton) {
            self.stopAnimating()
            if(titulo == Strings.erroLocationTitulo){
                SPPermission.Dialog.request(with: [.locationWhenInUse, .locationAlways, .notification], on: self, dataSource: self, colorSource: self)
            }
        }
        self.present(alertController, animated: true){}
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        startAnimating()
        let currentUser = User(cpf: self.cpfField.text!, senha: self.senhaField.text!)
        self.viewModel.loginUser(user: currentUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "menuSegue"){
            let vc = segue.destination as! MenuViewController
            vc.htmlString = self.responseString
        }
    }
    
}
extension LoginViewController: SPPermissionDialogDataSource, SPPermissionDialogColorSource{
    
    var baseColor: UIColor {return UIColor.red}
    var dialogSubtitle: String {return "A permissão da localização atual dentro do app é obrigatória para bater o ponto, já a localização no background só é necessária para o aviso automático de chegada na empresa!"}
    var dialogTitle: String {return "Lista de Permissão"}
    var dialogComment: String {return "Para bater o ponto é necessário estar a 300m da empresa, caso optando pela opção de localização no background o aplicativo irá avisar assim que for possível bater o ponto."}
    
    @objc func name(for permission: SPPermissionType) -> String?{
        if(permission.rawValue == 8){return "Local"}
        else if(permission.rawValue == 9){return "Chegada na DB1"}
        else{return "Notificação"}
    }
    @objc func description(for permission: SPPermissionType) -> String?{
        if(permission.rawValue == 8){return "Necessário para bater o ponto"}
        else if(permission.rawValue == 9){return "Opcional para aviso de chegada"}
        else{return "Notificação de chegada/saída da empresa"}
    }
    @objc public func image(for permission: SPPermissionType) -> UIImage?{
        if(permission.rawValue == 8){return UIImage.init(named: "local")}
        else if(permission.rawValue == 9){return UIImage.init(named: "location")}
        else{return UIImage.init(named: "notification")}
    }
}

extension LoginViewController: LoginViewModelProtocol{
    
    func onValidateLogin(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?){
        stopAnimating()
        if error == true{
            mostraMensagem(titulo: erroTitulo!, mensagem: erroMensagem!, botao: Strings.erroBotao)
        }else{
            self.responseString = htmlString!
            performSegue(withIdentifier: "menuSegue", sender: nil)
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
