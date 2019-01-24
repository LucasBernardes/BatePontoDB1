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

class TaskWebViewController: UIViewController, WKNavigationDelegate {
    
    let navBar = SPFakeBarView(style: .stork)
    let webView = WKWebView()
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    var webLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.modalPresentationCapturesStatusBarAppearance = true
        
        
        //self.tableView.contentInset.bottom = self.safeArea.bottom
        //self.tableView.scrollIndicatorInsets.bottom = self.safeArea.bottom
        self.view.addSubview(self.webView)
        
        webView.navigationDelegate = self
        self.navBar.titleLabel.text = "TaskWeb"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.leftButton.setTitleColor(.red, for: .normal)
        self.navBar.leftButton.setTitleColor(.red, for: .highlighted)
        self.navBar.leftButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.view.addSubview(self.navBar)
        if(webLink != ""){
            webView.loadHTMLString(self.webLink, baseURL: nil)
        }else{
            print("to carregando a task")
            webView.load(URLRequest(url: URL(string: "https://taskweb.db1.com.br/#/")!))
        }
        self.updateLayout(with: self.view.frame.size)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        print("olha eu aqui vo da refresh")
    }
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("terminai kd")
        /*
         let screenSize = UIScreen.main.bounds
         let screenWidth = screenSize.width
         
         var scriptContent = "var meta = document.createElement('meta');"
         scriptContent += "meta.name='viewport';"
         scriptContent += "meta.content='\(screenWidth)';"
         scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
         
         webView.evaluateJavaScript(scriptContent, completionHandler: nil)
         */
        
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("kddd ta indo")
    }
    
}


