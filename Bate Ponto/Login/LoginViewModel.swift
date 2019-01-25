//
//  LoginViewModel.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 23/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//
//
import Foundation
import SPPermission
import Alamofire

protocol LoginViewModelProtocol{
    func onValidateLogin(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?)

}

class LoginViewModel{
    var delegate: LoginViewModelProtocol?
    var htmlResponse: String?
    
    func loginUser(user: User)->Bool{
        var responseString = ""
        if(!SPPermission.isAllow(.locationAlways) && !SPPermission.isAllow(.locationWhenInUse)){
            delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroLocationTitulo, erroMensagem: Strings.erroLocationMensagem, htmlString: "")
            return false
        }
        if(user.cpf == "" || user.senha == ""){
            delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroSemTitulo, erroMensagem: Strings.erroSemMensagem, htmlString: "")
            return false
        }
        var request = URLRequest(url: URL(string: Strings.pontofopagUrl)!)
        request.httpMethod = "POST"
        var string = [String : String]()
        string = ["OrigemRegistro": "RE","Situacao": "I","UserName": "\(user.cpf)","Password": "\(user.senha)","Lembrarme": "false","tipo": "1"]
        print(string)
        let enconding = URLEncoding.queryString
        request = try! enconding.encode(request, with: string)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroTitulo, erroMensagem: Strings.erroMensagem, htmlString: "")
                }
                return
            }
            responseString = String(data: data, encoding: .utf8)!
            if(responseString.range(of:"CPF inv&#225;lido") != nil){
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroCpfTitulo, erroMensagem: Strings.erroCpfMensagem, htmlString: "")
                }
                return
            }
               
            if(responseString.range(of:"Funcion&#225;rio N&#227;o Encontrado") != nil){
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroFuncionarioTitulo, erroMensagem: Strings.erroFuncionarioMensagem, htmlString: "")
                }
                return
            }
            else if(responseString.range(of:"CPF n&#227;o encontrado ou senha incorreta.") != nil){
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: true, erroTitulo: Strings.erroSenhaTitulo, erroMensagem: Strings.erroSenhaMensagem, htmlString: "")
                }
                return
            }
            else{
                OperationQueue.main.addOperation{
                    self.delegate?.onValidateLogin(error: false, erroTitulo: Strings.erroSenhaTitulo, erroMensagem: Strings.erroSenhaMensagem, htmlString: responseString)
                    UserDefaults.standard.set(user.cpf.trimmingCharacters(in: CharacterSet.whitespaces), forKey: "cpf")
                    UserDefaults.standard.set(user.senha, forKey: "senha")
                }
            }
        }
        task.resume()
        return true
    }
}
