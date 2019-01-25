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
    var webLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        openLink()
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
}
