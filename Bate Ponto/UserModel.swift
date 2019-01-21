//
//  UserModel.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 17/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation

struct User{
    var cpf: String
    var senha: String
    
    init(user: User) {
        cpf = user.cpf ?? ""
        senha = user.senha ?? ""
    }
}
class Historico{
    var numero: Int
    var data: Date

    
    init(numero: Int,data: Date) { // Constructor
        self.numero = numero
        self.data = data

    }
}
