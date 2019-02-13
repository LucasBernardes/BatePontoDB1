//
//  ConfigureView.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 06/02/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController
protocol taskWebDelegate{
    func reloadWebView()
}
class ConfigureViewController: UIViewController, ConfigurationProtocol{
    
    var delegate: taskWebDelegate?
    let navBar = SPFakeBarView(style: .stork)
    var webView: RegisterPageView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = RegisterPageView.instanceFromNib() as!  RegisterPageView
        self.webView?.delegate = self
        webView!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView!)
        self.webView!.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.webView!.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.webView!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.modalPresentationCapturesStatusBarAppearance = true
        self.navBar.titleLabel.text = "Configuração"
        
        
        self.navBar.rightButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .highlighted)
        self.navBar.rightButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.view.addSubview(self.navBar)
        
        
        self.webView!.backgroundColor = .white
        //self.updateLayout(with: self.webView.frame.size)
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    @objc func dismissActionAndReload() {
        self.delegate?.reloadWebView()
        self.dismiss(animated: true)
        
    }
}
