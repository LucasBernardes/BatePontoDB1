//
//  UserSettings.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 23/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation

class UserSettings{
    var cpf: String
    var senha: String
    
    init(){
        self.cpf = UserDefaults.standard.string(forKey: "cpf") ?? ""
        self.senha = UserDefaults.standard.string(forKey: "senha") ?? ""
    }
    
    
    
}
