//
//  LoginCleanSwiftPresenter.swift
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

protocol LoginCleanSwiftPresentationLogic
{
  func presentSomething(response: LoginCleanSwift.Something.Response)
}

class LoginCleanSwiftPresenter: LoginCleanSwiftPresentationLogic
{
  weak var viewController: LoginCleanSwiftDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: LoginCleanSwift.Something.Response)
  {
    let viewModel = LoginCleanSwift.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
