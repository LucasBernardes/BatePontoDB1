//
//  TaskWebViewModel.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 24/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation


protocol TaskWebViewModelProtocol{
    func loadViewProtocol(link: String?)
}

class TaskWebViewModel: NSObject{
    
    var delegate: TaskWebViewModelProtocol?
    
    func loadView(link: String){
        self.delegate?.loadViewProtocol(link: link)
    }
}
