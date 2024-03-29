//
//  LoginCleanSwiftModels.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 13/02/19.
//  Copyright (c) 2019 Lucas Franco Bernardes. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum LoginCleanSwift
{
  // MARK: Use cases
  
  enum Fetch
  {
    struct Request
    {
        var url = Strings.pontofopagUrl
        var origem = "RE"
        var situacao = "I"
        var userName = "083.441.709-07"
        var password = "jsbvt9"
        var lembrarme = "false"
        var tipo = "1"
    }
    struct Response
    {
        var error: Bool?
        var htmlString: String?
    }
    struct ViewModel
    {
        var html: String?
    }
  }
}
