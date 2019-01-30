//
//  Network.swift
//  Bitcoin DB1
//
//  Created by Lucas Franco Bernardes on 29/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


class Dog: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
}
class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var picture: Data? = nil // optionals supported
    let dogs = List<Dog>()
}
class CotacaoRealm: Object{
     @objc dynamic var valor = 0.0
    @objc dynamic var dia = Date()
}
