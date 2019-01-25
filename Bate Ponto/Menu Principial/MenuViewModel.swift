//
//  MenuViewModel.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 24/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

protocol MenuViewModelProtocol{
    func onValidateHistorico(error: Bool?, historico: [Historico], historicoHoje: [Historico])
    func onValidateAtuando(erro: Bool?, atuando: Bool?)
    func onValidateTotalDia(error: Bool?, progress: Float, atual: String)
    func onValidateHour(error: Bool?, hora: String)
    func onValidateReload(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?)
    func onValidatePonto(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?)
    func showOverView(html: String)
    func animateView()
}
class MenuViewModel: NSObject{
    var delegate: MenuViewModelProtocol?
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    let locationManager = CLLocationManager()
    
    
    func extractHorarioAtual(){
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        self.delegate?.onValidateHour(error: false, hora: dateString)
    }
    
    func extractHistoricoFromHtml(html: String?){
        var htmlString = html
        var historico = [Historico]()
        var historicoHoje = [Historico]()
        let total = htmlString!.components(separatedBy:"Chave de Seguran&#231;a")
        var dia = ""
        var hora = ""
        var hoje = ""
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        hoje = dateString
        for numeroEntrada in (0...(total.count-2)).reversed(){
            if let startLink = htmlString!.range(of: "&nbsp; &nbsp; Hora: "),
                let endLink  = htmlString!.range(of: "</td>", range: startLink.upperBound..<(htmlString!.endIndex)) {
                hora = String(htmlString![startLink.upperBound..<endLink.lowerBound])    // "abc"
                htmlString = htmlString!.stringByReplacingFirstOccurrenceOfString(target: "&nbsp; Hora: ", withString: "")
                htmlString = htmlString!.stringByReplacingFirstOccurrenceOfString(target: "\(hora)</td>", withString: "")
            }
            if let startLink2 = htmlString!.range(of: "Data: </td>\r\n                    <td>"),
                let endLink  = htmlString!.range(of: " &nbsp;", range: startLink2.upperBound..<(htmlString!.endIndex)) {
                dia = String(htmlString![startLink2.upperBound..<endLink.lowerBound])    // "abc"
                htmlString = htmlString!.stringByReplacingFirstOccurrenceOfString(target: "Data: </td>\r\n                    <td>", withString: "")
                htmlString = htmlString!.stringByReplacingFirstOccurrenceOfString(target: " &nbsp;", withString: "")
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy'T'HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "America/Sao_Paulo") as! TimeZone
            let date = dateFormatter.date(from: "\(dia)T\(hora)")
            if(hoje == dia){
                historicoHoje.insert(Historico(numero: numeroEntrada, data: date!), at: 0)
            }
            historico.append(Historico(numero: numeroEntrada, data: date!))
        }
        OperationQueue.main.addOperation{
            self.delegate?.onValidateHistorico(error: false, historico: historico, historicoHoje: historicoHoje)
            if(historico.count > 0 && historico.count % 2 != 0){
                self.delegate?.onValidateAtuando(erro: false, atuando: true)
            }else{
                self.delegate?.onValidateAtuando(erro: false, atuando: false)
            }
        }
        OperationQueue.main.addOperation {
            self.delegate?.animateView()
            return
        }
    }
    
    func extractProgressAndTime(historicoHoje: [Historico]){
        var progress: Float!
        let total = historicoHoje.count
        var totalHoras = 0
        if(total - 1 >= 0){
            for aux in stride(from: 0, to: total, by: 2){
                if(aux + 1 < total){
                    totalHoras = totalHoras + historicoHoje[aux].data.offsetFrom(date: historicoHoje[aux+1].data)
                }else{
                    totalHoras = totalHoras + historicoHoje[aux].data.offsetFrom(date: Date())
                }
            }
        }
        progress = (Float(totalHoras)/Float(528.0))
        let totalDigitoHoras = totalHoras / 60
        let totalDigitoMinutos = totalHoras % 60
        let atual = String(format: "Atual %0d:%02d", totalDigitoHoras, totalDigitoMinutos)
        self.delegate?.onValidateTotalDia(error: false, progress: progress, atual: atual)
    }
    
    func reload(user: User){
        var responseString = ""
        var request = URLRequest(url: URL(string: "https://registra.pontofopag.com.br/")!)
        request.httpMethod = "POST"
        var string = [String : String]()
        string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "\(user.cpf)","Password": "\(user.senha)","Lembrarme": "false","tipo": "1"]
        print(string)
        let enconding = URLEncoding.queryString
        request.addValue("https://registra.pontofopag.com.br/", forHTTPHeaderField: "Referer")
        request.addValue("https://registra.pontofopag.com.br", forHTTPHeaderField: "Origin")
        request.addValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393", forHTTPHeaderField: "User-Agent")
        request = try! enconding.encode(request, with: string)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateReload(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateReload(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                }
                return
            }
            responseString = String(data: data, encoding: .utf8)!
            if(responseString.range(of:"CPF inv&#225;lido") != nil){
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateReload(error: true, erroTitulo: Strings.erroCpfTitulo, erroMensagem: Strings.erroCpfMensagem, htmlString: "")
                }
                return
            }
            else if(responseString.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateReload(error: true, erroTitulo: Strings.erroSenhaTitulo, erroMensagem: Strings.erroSenhaMensagem, htmlString: "")
                }
                return
            }
            else{
                OperationQueue.main.addOperation {
                    self.delegate?.onValidateReload(error: false, erroTitulo: "", erroMensagem: "", htmlString: responseString)
                    self.extractHistoricoFromHtml(html: responseString)
                }
                OperationQueue.main.addOperation {
                    self.delegate?.animateView()
                    return
                }
            }
        }
        task.resume()
    }
    func preparaBatePonto(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        self.locationManager.requestLocation()
    }
    func batePonto(user: User){
        if(podeBaterPonto()){
            var request = URLRequest(url: URL(string: Strings.pontofopagUrl)!)
            request.httpMethod = "POST"
            var string = [String : String]()
            string = ["OrigemRegistro": "RE","Situacao": "I","UserName": user.cpf,"Password": user.senha,"Lembrarme": "false","tipo": "0"]
            let enconding = URLEncoding.queryString
            request = try! enconding.encode(request, with: string)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    OperationQueue.main.addOperation{
                        self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                    }
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    OperationQueue.main.addOperation{
                        self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                    }
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                if(responseString!.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                    OperationQueue.main.addOperation{
                        self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroCpfTitulo, erroMensagem: Strings.erroCpfMensagem, htmlString: "")
                    }
                    return
                }
                OperationQueue.main.addOperation{
                    self.delegate?.onValidatePonto(error: false, erroTitulo: "", erroMensagem: "", htmlString: responseString)
                    self.delegate?.showOverView(html: responseString!)
                }
                OperationQueue.main.addOperation{
                    self.delegate?.animateView()
                }
                
            }
            task.resume()
        }
        return
        
    }
    
    
    func podeBaterPonto()->Bool{
        self.locationManager.requestLocation()
        if(CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude).distance(from: CLLocation(latitude:-23.4192021, longitude: -51.9356276)) > 300.0){
            self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroDistanciaTitulo, erroMensagem: Strings.erroDistanciaMensagem, htmlString: "")
            return false
        }else{
            return true
        }
    }
    
    
}
extension MenuViewModel: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            self.currentLatitude = lat
            self.currentLongitude = long
            //self.delegate?.onValidatePonto(error: false, erroTitulo: "", erroMensagem: "",htmlString: "")
        } else {
            self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroDistanciaTitulo, erroMensagem: Strings.erroDistanciaMensagem, htmlString: "")
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.onValidatePonto(error: true, erroTitulo: Strings.erroDistanciaTitulo, erroMensagem: Strings.erroDistanciaMensagem, htmlString: "")
        print(error)
    }
}
