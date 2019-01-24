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
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    let navBar = SPFakeBarView(style: .stork)
    let webView = WKWebView()
    private var viewModel: TaskWebViewModel!
    var webLink = "https://taskweb.db1.com.br/#/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        viewModel = TaskWebViewModel()
        viewModel.delegate = self
        webView.navigationDelegate = self
        viewModel.loadView(link: self.webLink)
    }
    
    
   
    
    func prepareView(){
        self.view.backgroundColor = UIColor.white
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.addSubview(self.webView)
        self.navBar.titleLabel.text = "TaskWeb"
        self.navBar.rightButton.setTitle("Fechar", for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .normal)
        self.navBar.rightButton.setTitleColor(.red, for: .highlighted)
        self.navBar.rightButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.view.addSubview(self.navBar)
        self.updateLayout(with: self.view.frame.size)
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
    
}
extension TaskWebViewController: TaskWebViewModelProtocol{
    func loadViewProtocol(link: String?) {
        webView.loadHTMLString(link!, baseURL: nil)
    }
    
    
    
}


