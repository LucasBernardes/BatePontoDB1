//
//  RegisterView.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 06/02/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation
import UIKit
import KOAlertController
protocol ConfigurationProtocol {
    func dismissActionAndReload()
}

class RegisterPageView: UIView {
    var delegate: ConfigurationProtocol?
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "View", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
       
    }
    override func awakeFromNib() {
        self.passwordField.isSecureTextEntry = true
        self.buttonSave.layer.cornerRadius = 10
        self.loginField.layer.cornerRadius = 10
        self.loginField.borderStyle = .none
        self.passwordField.borderStyle = .none
        self.passwordField.layer.cornerRadius = 10
        
        self.loginField.setLeftPaddingPoints(15.0)
        self.passwordField.setLeftPaddingPoints(15.0)
        let login = UserDefaults.standard.string(forKey: "loginTask") ?? ""
        let senha = UserDefaults.standard.string(forKey: "senhaTask") ?? ""
        self.loginField.text = login
        self.passwordField.text = senha
        
    }
    override func layoutSubviews() {
        self.buttonSave.applyGradient(colors: [(UIColor.vermelhoEscuro()?.cgColor)!,(UIColor.vermelhoClaro()?.cgColor)!])
    }
    //common func to init our view
    private func setupView() {
        
        backgroundColor = .red
        
    }
    @IBAction func savePressed(_ sender: Any) {
        print("paertei")
        self.buttonSave.setTitle("Salvo!", for: .normal)
        UserDefaults.standard.set(self.loginField.text!, forKey: "loginTask")
        UserDefaults.standard.set(self.passwordField.text!, forKey: "senhaTask")
        self.delegate?.dismissActionAndReload()
       
        
    }
    
   
}
