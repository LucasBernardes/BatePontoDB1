//
//  TaskWebViewController.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 18/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import WebKit
import SparrowKit
import SPStorkController

class TaskWebViewController: UIViewController, WKNavigationDelegate, taskWebDelegate{
    func reloadWebView() {
        webView.load(URLRequest(url: URL(string: "https://taskweb.db1.com.br/#/")!))
    }
    
    var login = ""
    var senha = ""
    let navBar = SPFakeBarView(style: .stork)
    let webView = WKWebView()
    var webLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        
    }
    override func viewDidAppear(_ animated: Bool) {
       openLink()
       print("kd")
        login = UserDefaults.standard.string(forKey: "loginTask") ?? ""
        senha = UserDefaults.standard.string(forKey: "senhaTask") ?? ""
        if(login.isEmpty || senha.isEmpty){
            let alert = UIAlertController(title: "Deseja automatizar o login?", message: "Nas configurações do TaskWeb você pode salvar seu login e senha!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Configurar", style: .default, handler: { action in
                self.doAction()
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    
    
    func openLink(){
        if(webLink != ""){
            webView.loadHTMLString(self.webLink, baseURL: nil)
        }else{
            webView.load(URLRequest(url: URL(string: "https://taskweb.db1.com.br/#/")!))
        }
    }
    
    func prepareView(){
        
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.addSubview(self.webView)
        webView.navigationDelegate = self
        self.navBar.titleLabel.text = "TaskWeb"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.leftButton.setTitleColor(.red, for: .normal)
        self.navBar.leftButton.setTitleColor(.red, for: .highlighted)
        self.navBar.leftButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        
        //self.navBar.rightButton.setTitle("Config", for: .normal)
        self.navBar.rightButton.setImage(UIImage(named: "config"), for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .highlighted)
        self.navBar.rightButton.addTarget(self, action: #selector(self.doAction), for: .touchUpInside)
        
        self.view.addSubview(self.navBar)
        self.updateLayout(with: self.view.frame.size)
    }
}


extension TaskWebViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (contex) in
            self.updateLayout(with: size)
        }, completion: nil)
    }
    
    @available(iOS 11.0, *)
    override public func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.updateLayout(with: self.view.frame.size)
    }
    
    func updateLayout(with size: CGSize) {
        self.webView.frame = CGRect.init(origin: CGPoint.zero, size: size)
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    @objc func doAction() {
        let modal = ConfigureViewController()
        modal.delegate = self
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        transitionDelegate.customHeight = 450
        
        self.present(modal, animated: true, completion: nil)
        //self.presentAsStork(modal)
        
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("KD")
        login = UserDefaults.standard.string(forKey: "loginTask") ?? ""
        senha = UserDefaults.standard.string(forKey: "senhaTask") ?? ""
        
        self.webView.evaluateJavaScript("document.getElementById('usuario').value = '\(login.uppercased())';", completionHandler: { (res, error) -> Void in
        })

        self.webView.evaluateJavaScript("document.getElementById('senha').value = '\(senha.uppercased())';", completionHandler: { (res, error) -> Void in
        })
        self.webView.evaluateJavaScript("var event = document.createEvent('HTMLEvents');event.initEvent('change',true,false);document.getElementById('usuario').dispatchEvent(event);", completionHandler: { (res, error) -> Void in
        })
        self.webView.evaluateJavaScript("var event = document.createEvent('HTMLEvents');event.initEvent('change',true,false);document.getElementById('senha').dispatchEvent(event);", completionHandler: { (res, error) -> Void in
        })
        self.webView.evaluateJavaScript("document.getElementsByClassName('ng-pristine ng-untouched ng-valid ng-empty')[0].click();", completionHandler: { (res, error) -> Void in
        })
        self.webView.evaluateJavaScript("var event = document.createEvent('HTMLEvents');event.initEvent('change',true,false);document.getElementsByClassName('ng-pristine ng-untouched ng-valid ng-empty')[0].dispatchEvent(event);", completionHandler: { (res, error) -> Void in
            //Here you can check for results if needed (res) or whether the execution was successful (error)
        })
        
    }
    
}
