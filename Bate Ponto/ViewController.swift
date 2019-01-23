//
//  ViewController.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 17/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import SPStorkController
import SparrowKit
import ViewAnimator
import CoreLocation
import KOAlertController

class ViewController: UIViewController, UICollectionViewDataSource,WKNavigationDelegate, UICollectionViewDelegate {
    
    
    
    let vermelhoEscuro = UIColor(red: 252/255, green: 46/255, blue: 82/255, alpha: 1.0).cgColor
    let vermelhoClaro = UIColor(red: 254/255, green: 86/255, blue: 49/255, alpha: 1.0).cgColor
    let vermelhoClaroUIColor = UIColor(red: 252/255, green: 46/255, blue: 82/255, alpha: 1.0)
    var historico = [Historico]()
    var historicoHoje = [Historico]()
    let navBar = SPFakeBarView(style: .stork)
    private let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]
    let locationManager = CLLocationManager()
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var horarioDoPonto: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var historicoButton: UIButton!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    var htmlString = ""
    var pontoHtmlString = ""
    var erroTitulo = "Problema na conexão!"
    var erroMensagem = "Houve um problema com os servidores e não foi possível executar esta ação"
    var erroBotao = "Compreendi"
    var cpfString = ""
    var senhaString = ""
    var currentLongitude = 0.0
    var currentLatitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registrarButton.layer.cornerRadius = 10
        self.historicoButton.layer.cornerRadius = 10
        self.horarioLabel.layer.masksToBounds = true
        self.logoutButton.layer.cornerRadius = 10
        self.horarioLabel.layer.cornerRadius = 10
        self.progressView.progressTintColor = self.vermelhoClaroUIColor
        self.progressView.transform = self.progressView.transform.scaledBy(x: 1, y: 6)
        self.registrarButton.applyGradient(colors: [self.vermelhoEscuro,self.vermelhoClaro])
        self.horarioDoPonto.text = "Atual 0:00"
        self.activityIndicator.isHidden = true
        self.reloadActivityIndicator.isHidden = true
        self.activityIndicator.startAnimating()
        self.reloadActivityIndicator.startAnimating()
        self.progressView.layer.cornerRadius = 3
        self.progressView.clipsToBounds = true
        self.progressView.layer.sublayers![1].cornerRadius = 3
        self.progressView.subviews[1].clipsToBounds = true
        self.progressView.clipsToBounds = true
        self.cpfString = UserDefaults.standard.string(forKey: "cpf") ?? ""
        self.senhaString = UserDefaults.standard.string(forKey: "senha") ?? ""
        print(self.cpfString)
        print(self.senhaString)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //locationManager.startUpdatingLocation()
        let url = URL(string: "https://registra.pontofopag.com.br/")
        let request = URLRequest(url: url!)
        
        
        requestWebsteLogin()
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(horarioAtual), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(totalDeHorasDoDia), userInfo: nil, repeats: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //UIView.animate(views: self.collectionView!.orderedVisibleCells,
        //              animations: animations, completion: {
        //                print("mostrei")
        //})
    }
    @objc func horarioAtual(){
        let dateFormatter : DateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        self.horarioLabel.text = dateString
        //let interval = date.timeIntervalSince1970
    }
    @objc func totalDeHorasDoDia(){
        var total = self.historicoHoje.count
        var totalHoras = 0
        print("total \(total)")
        if(total - 1 >= 0){
            for aux in stride(from: 0, to: total, by: 2){
                if(aux + 1 < total){
                    //nao eh o ultimo
                    //print("Olha ai \(self.historicoHoje[aux].data.offsetFrom(date: self.historicoHoje[aux+1].data))")
                    totalHoras = totalHoras + self.historicoHoje[aux].data.offsetFrom(date: self.historicoHoje[aux+1].data)
                }else{
                    //print("Olha ai \(Date().offsetFrom(date: self.historicoHoje[aux].data))")
                    totalHoras = totalHoras + self.historicoHoje[aux].data.offsetFrom(date: Date())
                    print(totalHoras)
                }
                
            }
        }
        print("progress \((Float(totalHoras)/528.0))")
        self.progressView.setProgress((Float(totalHoras)/528.0), animated: true)
        let totalDigitoHoras = totalHoras / 60
        let totalDigitoMinutos = totalHoras % 60
        
        
        
        self.horarioDoPonto.text = String(format: "Atual %0d:%02d", totalDigitoHoras, totalDigitoMinutos)
        
    }
    func beginRegistrar(){
        self.registrarButton.setTitle("", for: .normal)
        self.activityIndicator.isHidden = false
    }
    func endRegistrar(){
        self.activityIndicator.isHidden = true
        self.registrarButton.setTitle("Registrar", for: .normal)
    }
    func beginReload(){
        self.refreshButton.isHidden = true
        self.reloadActivityIndicator.isHidden = false
    }
    func endReload(){
        self.refreshButton.isHidden = false
        self.reloadActivityIndicator.isHidden = true
    }
    
    func requestWebsteLogin(){
        self.historico.removeAll()
        self.historicoHoje.removeAll()
        let total = htmlString.components(separatedBy:"Chave de Seguran&#231;a")
        print(total.count-1)
        var dia = ""
        var hora = ""
        var hoje = ""
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        hoje = dateString
        for numeroEntrada in (0...(total.count-2)).reversed(){
            if let startLink = htmlString.range(of: "&nbsp; &nbsp; Hora: "),
                let endLink  = htmlString.range(of: "</td>", range: startLink.upperBound..<(htmlString.endIndex)) {
                hora = String(htmlString[startLink.upperBound..<endLink.lowerBound])    // "abc"
                print(hora)
                htmlString = htmlString.stringByReplacingFirstOccurrenceOfString(target: "&nbsp; Hora: ", withString: "")
                htmlString = htmlString.stringByReplacingFirstOccurrenceOfString(target: "\(hora)</td>", withString: "")
            }
            if let startLink2 = htmlString.range(of: "Data: </td>\r\n                    <td>"),
                let endLink  = htmlString.range(of: " &nbsp;", range: startLink2.upperBound..<(htmlString.endIndex)) {
                dia = String(htmlString[startLink2.upperBound..<endLink.lowerBound])    // "abc"
                print(dia)
                htmlString = htmlString.stringByReplacingFirstOccurrenceOfString(target: "Data: </td>\r\n                    <td>", withString: "")
                htmlString = htmlString.stringByReplacingFirstOccurrenceOfString(target: " &nbsp;", withString: "")
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy'T'HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "America/Sao_Paulo") as! TimeZone
            let date = dateFormatter.date(from: "\(dia)T\(hora)")
            print("hje e dia\(hoje)\(dia)")
            if(hoje == dia){
                self.historicoHoje.insert(Historico(numero: numeroEntrada, data: date!), at: 0)
            }
            self.historico.append(Historico(numero: numeroEntrada, data: date!))
            
            
        }
        
        OperationQueue.main.addOperation{
            self.collectionView.reloadData()
            if(self.historico.count > 0 && self.historico.count % 2 != 0){
                self.status.textColor = .red
            }
            self.totalDeHorasDoDia()
        }
        
        OperationQueue.main.addOperation{
            UIView.animate(views: self.collectionView!.orderedVisibleCells,
                           animations: self.animations, completion: {
                            print("mostrei")
            })
        }
        
        
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gradient(frame:CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [
            self.vermelhoEscuro,self.vermelhoClaro]
        return layer
    }
    
    
    @IBAction func registrarPressed(_ sender: Any) {
        self.beginRegistrar()
        if(podeBaterPonto()){
            var request = URLRequest(url: URL(string: "https://registra.pontofopag.com.br/")!)
            request.httpMethod = "POST"
            var string = [String : String]()
            string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "083.441.709-07","Password": "jsbvt9","Lembrarme": "false","tipo": "0"]
            var enconding = URLEncoding.queryString
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
                        self.mostraMensagem(titulo: self.erroTitulo, mensagem: self.erroMensagem, botao: self.erroBotao)
                    }
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    self.mostraMensagem(titulo: self.erroTitulo, mensagem: self.erroMensagem, botao: self.erroBotao)
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                if((responseString?.contains("Chave de Seguran&#231;a"))!){
                    print("deu bom")
                    var dia = ""
                    var hora = ""
                    var hoje = ""
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let date = Date()
                    let dateString = dateFormatter.string(from: date)
                    hoje = dateString
                    if let startLink = self.htmlString.range(of: "&nbsp; &nbsp; Hora: "),
                        let endLink  = self.htmlString.range(of: "</td>", range: startLink.upperBound..<(self.htmlString.endIndex)) {
                        hora = String(self.htmlString[startLink.upperBound..<endLink.lowerBound])    // "abc"
                        print(hora)
                        self.htmlString = self.htmlString.stringByReplacingFirstOccurrenceOfString(target: "&nbsp; Hora: ", withString: "")
                        self.htmlString = self.htmlString.stringByReplacingFirstOccurrenceOfString(target: "\(hora)</td>", withString: "")
                    }
                    if let startLink2 = self.htmlString.range(of: "Data: </td>\r\n                    <td>"),
                        let endLink  = self.htmlString.range(of: " &nbsp;", range: startLink2.upperBound..<(self.htmlString.endIndex)) {
                        dia = String(self.htmlString[startLink2.upperBound..<endLink.lowerBound])    // "abc"
                        print(dia)
                        self.htmlString = self.htmlString.stringByReplacingFirstOccurrenceOfString(target: "Data: </td>\r\n                    <td>", withString: "")
                        self.htmlString = self.htmlString.stringByReplacingFirstOccurrenceOfString(target: " &nbsp;", withString: "")
                    }
                    OperationQueue.main.addOperation{
                        self.endRegistrar()
                        self.collectionView.reloadData()
                        if(self.historico.count > 0 && self.historico.count % 2 != 0){
                            self.status.textColor = .red
                        }else{
                            self.status.textColor = UIColor.groupTableViewBackground
                        }
                        self.totalDeHorasDoDia()
                        let modal = TaskWebViewController()
                        modal.webLink = responseString!
                        let transitionDelegate = SPStorkTransitioningDelegate()
                        modal.transitioningDelegate = transitionDelegate
                        modal.modalPresentationStyle = .custom
                        self.present(modal, animated: true, completion: nil)
                    }
                    OperationQueue.main.addOperation{
                        UIView.animate(views: self.collectionView!.orderedVisibleCells,
                                       animations: self.animations, completion: {
                                        print("mostrei")
                        })
                    }
                }
                else{
                    print("Nao deu nada!")///colocar errod e conexao
                }
            }
            task.resume()
        }
        
        
    }
    
    func podeBaterPonto()->Bool{
        self.locationManager.requestLocation()
        print("Estou no \(self.currentLatitude) \(self.currentLongitude) \n db1 eh -23.4192021 e long -51.9356276 \n distancia ")
        print(CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude).distance(from: CLLocation(latitude:-23.4192021, longitude: -51.9356276)))
        if(CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude).distance(from: CLLocation(latitude:-23.4192021, longitude: -51.9356276)) > 300.0){
            print("Ta muito longe pra fazer o registro")
            let alertController = KOAlertController("Você está muito longe!", "Sua atual localização aparenta muito distante da sede da DB1, por favor fique no mínimo uma distância de 1 quadra das instalações", UIImage(named:"alert"))
            alertController.style.cornerRadius = 10
            let defButton                   = KOAlertButton(.default, title:"Compreendi")
            defButton.backgroundColor       = UIColor.black
            defButton.titleColor            = UIColor.white
            defButton.cornerRadius = 10
            alertController.addAction(defButton) {
                self.endRegistrar()
            }
            self.present(alertController, animated: true){}
            return false
        }else{
            print("Esta na DB1 para fazer o registro")
            return true
        }
    }
    
    func mostraMensagem(titulo: String, mensagem: String, botao: String){
        let alertController = KOAlertController("\(titulo)", "\(mensagem)", UIImage(named:"alert"))
        alertController.style.cornerRadius = 10
        let defButton                   = KOAlertButton(.default, title:"\(botao)")
        defButton.backgroundColor       = UIColor.black
        defButton.titleColor            = UIColor.white
        defButton.cornerRadius = 10
        alertController.addAction(defButton) {
            self.endRegistrar()
            self.endReload()
        }
        self.present(alertController, animated: true){}
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        //self.requestWebsteLogin()
        self.cpfString = UserDefaults.standard.string(forKey: "cpf") ?? ""
        self.senhaString = UserDefaults.standard.string(forKey: "senha") ?? ""
        print(self.cpfString)
        print(self.senhaString)
        self.beginReload()
        var request = URLRequest(url: URL(string: "https://registra.pontofopag.com.br/")!)
        request.httpMethod = "POST"
        var string = [String : String]()
        string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "\(self.cpfString)","Password": "\(self.senhaString)","Lembrarme": "false","tipo": "1"]
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
                    self.mostraMensagem(titulo: self.erroTitulo, mensagem: self.erroMensagem, botao: self.erroBotao)
                }
                print("Erro chamada")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: self.erroTitulo, mensagem: self.erroMensagem, botao: self.erroBotao)
                }
                print("Problema Conexão")
                return
            }
            self.htmlString = String(data: data, encoding: .utf8)!
            
            if(self.htmlString.range(of:"CPF inv&#225;lido") != nil){
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: LoginViewController.erroCpfTitulo, mensagem: LoginViewController.erroCpfMensagem, botao: self.erroBotao)
                }
                print("CPF ERRADo")
                return
            }
            else if(self.htmlString.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                OperationQueue.main.addOperation{
                    self.mostraMensagem(titulo: LoginViewController.erroSenhaTitulo, mensagem: LoginViewController.erroSenhaMensagem, botao: self.erroBotao)
                }
                print("Senha errad")
                return
            }
            else{
                OperationQueue.main.addOperation{
                    self.endReload()
                }
                self.requestWebsteLogin()
            }
        }
        task.resume()
    }
    @IBAction func taskWebPressed(_ sender: Any) {
        super.viewDidLoad()
        let modal = TaskWebViewController()
        //modal.webLink = "https://taskweb.db1.com.br/#/"
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        present(modal, animated: true, completion: nil)
        
    }
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exemplo", for: indexPath) as! horarioCollectionCell
        cell.layer.cornerRadius = 10
        //cell.applyGradient(colors: [self.vermelhoEscuro,self.vermelhoClaro])
        cell.layer.cornerRadius = 20.0
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.layer.shadowRadius = 12.0
        cell.layer.shadowOpacity = 0.7
        cell.layer.insertSublayer(gradient(frame: cell.bounds), at: 0)
        if(self.historicoHoje.count % 2 != 0 && indexPath.row % 2 != 0){
            cell.entradaSaidaLabel.text = "Saída"
        }else if(self.historicoHoje.count % 2 == 0 && indexPath.row % 2 == 0){
            cell.entradaSaidaLabel.text = "Saída"
        }else{
            cell.entradaSaidaLabel.text = "Entrada"
        }
        cell.numeroLabel.text = "#\(self.historico[indexPath.row].numero)"
        print("\(self.historico[indexPath.row].data)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let diaString = dateFormatter.string(from: self.historico[indexPath.row].data)
        
        //let calendar = Calendar.current
        //let horaString = "\(calendar.component(.hour, from: self.historico[indexPath.row].data)):\(calendar.component(.minute, from: self.historico[indexPath.row].data))"
        
        
        dateFormatter.dateFormat = "HH:mm"
        let horaString = dateFormatter.string(from: self.historico[indexPath.row].data)
        
        cell.dataLabel.text = diaString
        cell.horarioLabel.text = horaString
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.historico.count - 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            self.currentLatitude = lat
            self.currentLongitude = long
            
        } else {
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

class horarioCollectionCell: UICollectionViewCell{
    @IBOutlet weak var entradaSaidaLabel: UILabel!
    @IBOutlet weak var empresaLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var numeroLabel: UILabel!
    
}

extension UIView
{
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 10
        self.layer.addSublayer(gradientLayer)
        
    }
    
}
extension String
{
    func stringByReplacingFirstOccurrenceOfString(
        target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
extension Date {
    
    func offsetFrom(date : Date) -> Int {
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: self)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let difference = calendar.dateComponents([.minute], from: timeComponents, to: nowComponents).minute
        
        
        //let minutes = "\(difference.minute ?? 0)m"
        if let minute = difference, minute > 0 { return difference! }
        return 0
    }
    
}
