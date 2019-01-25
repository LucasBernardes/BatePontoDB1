//
//  ViewController.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 17/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import SPStorkController
import SparrowKit
import ViewAnimator
import CoreLocation
import KOAlertController

class MenuViewController: UIViewController, UICollectionViewDataSource,WKNavigationDelegate, UICollectionViewDelegate {

    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var horarioDoPonto: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var historicoButton: UIButton!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    var htmlString = ""
    var pontoHtmlString = ""
    var currentLongitude = 0.0
    var currentLatitude = 0.0
    var userSettings = UserSettings()
    private var viewModel: MenuViewModel!
    var historico = [Historico]()
    var historicoHoje = [Historico]()
    let navBar = SPFakeBarView(style: .stork)
    private let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegates()
        prepareView()
        timers()
    }
    
    override func viewDidLayoutSubviews() {
        prepareGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.preparaBatePonto()
    }
    
    func prepareGradient(){
        self.registrarButton.applyGradient(colors: [UIColor.vermelhoEscuro()!.cgColor,UIColor.vermelhoClaro()!.cgColor])

    }
    
    func prepareView(){
        self.registrarButton.layer.cornerRadius = 10
        self.historicoButton.layer.cornerRadius = 10
        self.horarioLabel.layer.masksToBounds = true
        self.logoutButton.layer.cornerRadius = 10
        self.horarioLabel.layer.cornerRadius = 10
        self.progressView.progressTintColor = UIColor.vermelhoEscuro()
        self.progressView.transform = self.progressView.transform.scaledBy(x: 1, y: 6)
        self.horarioDoPonto.text = "Atual 0:00"
        self.activityIndicator.isHidden = true
        self.reloadActivityIndicator.isHidden = true
        self.activityIndicator.startAnimating()
        self.reloadActivityIndicator.startAnimating()
        self.progressView.layer.cornerRadius = 3
        self.progressView.clipsToBounds = true
        self.progressView.layer.sublayers![1].cornerRadius = 3
        self.progressView.subviews[1].clipsToBounds = true
        self.progressView.clipsToBounds = true
    }
    
    func delegates(){
        viewModel = MenuViewModel()
        viewModel.delegate = self
        viewModel.extractHistoricoFromHtml(html: self.htmlString)
    }

    func timers(){
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(horarioAtual), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(totalDeHorasDoDia), userInfo: nil, repeats: true)
    }
    
    @objc func horarioAtual(){
        viewModel.extractHorarioAtual()
    }
    @objc func totalDeHorasDoDia(){
        viewModel.extractProgressAndTime(historicoHoje: self.historicoHoje)
        
    }
    func beginRegistrar(){
        self.registrarButton.setTitle("", for: .normal)
        self.activityIndicator.isHidden = false
    }
    func endRegistrar(){
        self.activityIndicator.isHidden = true
        self.registrarButton.setTitle("Registrar", for: .normal)
    }
    func beginReload(){
        self.refreshButton.isHidden = true
        self.reloadActivityIndicator.isHidden = false
    }
    func endReload(){
        self.refreshButton.isHidden = false
        self.reloadActivityIndicator.isHidden = true
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registrarPressed(_ sender: Any) {
        self.beginRegistrar()
        self.viewModel.batePonto(user: User(cpf: userSettings.cpf, senha: userSettings.senha))
        
    }
    
    
    func mostraMensagem(titulo: String, mensagem: String, botao: String){
        let alertController = KOAlertController("\(titulo)", "\(mensagem)", UIImage(named:"alert"))
        alertController.style.cornerRadius = 10
        let defButton = KOAlertButton(.default, title:"\(botao)")
        defButton.backgroundColor = UIColor.black
        defButton.titleColor = UIColor.white
        defButton.cornerRadius = 10
        alertController.addAction(defButton) {
            self.endRegistrar()
            self.endReload()
        }
        self.present(alertController, animated: true){}
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        self.beginReload()
        self.viewModel.reload(user: User(cpf: userSettings.cpf, senha: userSettings.senha))
        
    }
    @IBAction func taskWebPressed(_ sender: Any) {
        self.showOverView(html: "")
        
    }
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exemplo", for: indexPath) as! horarioCollectionCell
        cell.layer.cornerRadius = 10
        cell.layer.cornerRadius = 20.0
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.layer.shadowRadius = 12.0
        cell.layer.shadowOpacity = 0.7
        cell.layer.insertSublayer(gradient(frame: cell.bounds), at: 0)
        if(self.historicoHoje.count % 2 != 0 && indexPath.row % 2 != 0){
            cell.entradaSaidaLabel.text = "Saída"
        }else if(self.historicoHoje.count % 2 == 0 && indexPath.row % 2 == 0){
            cell.entradaSaidaLabel.text = "Saída"
        }else{
            cell.entradaSaidaLabel.text = "Entrada"
        }
        cell.numeroLabel.text = "#\(self.historico[indexPath.row].numero)"
        print("\(self.historico[indexPath.row].data)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let diaString = dateFormatter.string(from: self.historico[indexPath.row].data)
        dateFormatter.dateFormat = "HH:mm"
        let horaString = dateFormatter.string(from: self.historico[indexPath.row].data)
        
        cell.dataLabel.text = diaString
        cell.horarioLabel.text = horaString
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.historico.count - 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func gradient(frame:CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [UIColor.vermelhoEscuro()!.cgColor,UIColor.vermelhoClaro()!.cgColor]
        return layer
    }
    
}

extension MenuViewController: MenuViewModelProtocol{
    func onValidatePonto(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?) {
        self.endRegistrar()
        if(error!){
            self.mostraMensagem(titulo: erroTitulo!, mensagem: erroMensagem!, botao: Strings.erroBotao)
        }else{
            self.viewModel.reload(user: User(cpf: userSettings.cpf, senha: userSettings.senha))
            self.showOverView(html: htmlString!)
        }
    }

    func onValidateHistorico(error: Bool?, historico: [Historico], historicoHoje: [Historico]) {
        self.historico = historico
        self.historicoHoje = historicoHoje
        viewModel.extractProgressAndTime(historicoHoje: self.historicoHoje)
        self.collectionView.reloadData()
    }
    
    func onValidateAtuando(erro: Bool?, atuando: Bool?) {
        if(atuando!){
            self.status.textColor = .red
        }
        else{
            self.status.textColor = .groupTableViewBackground
        }
    }
    
    func onValidateTotalDia(error: Bool?, progress: Float, atual: String){
        self.progressView.setProgress(progress, animated: true)
        self.horarioDoPonto.text = atual
    }
    
    func onValidateHour(error: Bool?, hora: String) {
        self.horarioLabel.text = hora
    }
    
    func onValidateReload(error: Bool?, erroTitulo: String?, erroMensagem: String?, htmlString: String?) {
        self.endReload()
        if(error == true){
            self.mostraMensagem(titulo: erroTitulo!, mensagem: erroMensagem!, botao: Strings.erroBotao)
        }
        //else{
            //self.htmlString = htmlString!
            //viewModel.extractHistoricoFromHtml(html: self.htmlString)
            //self.collectionView.reloadData()
        //}
        
    }
    func showOverView(html: String) {
        self.presentView(html: html)
    }
    
    @objc func presentView(html: String){
        let modal = TaskWebViewController()
        modal.webLink = html
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        self.present(modal, animated: true, completion: nil)
    }
    
    func animateView() {
        UIView.animate(views: self.collectionView!.orderedVisibleCells,
                       animations: self.animations, completion: {
                        print("Animei")
            })
    }
}




class horarioCollectionCell: UICollectionViewCell{
    @IBOutlet weak var entradaSaidaLabel: UILabel!
    @IBOutlet weak var empresaLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var numeroLabel: UILabel!
    
}


extension String
{
    func stringByReplacingFirstOccurrenceOfString(
        target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
extension Date {
    
    func offsetFrom(date : Date) -> Int {
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: self)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        let difference = calendar.dateComponents([.minute], from: timeComponents, to: nowComponents).minute
        
        
        //let minutes = "\(difference.minute ?? 0)m"
        if let minute = difference, minute > 0 { return difference! }
        return 0
    }
    
}
