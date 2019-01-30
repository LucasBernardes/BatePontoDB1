//
//  ViewController.swift
//  Bitcoin DB1
//
//  Created by Lucas Franco Bernardes on 29/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import AAInfographics
import CoreData

class BitcoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BitcoinViewModelProtocol {


    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var customTableView: UITableView!
    public var chartType: AAChartType?
    public var step: Bool?
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    var cotacao: Cotacao?
    var currentValue = 0.00000
    var coreDataStrings = [String]()
    var cotacoes: [NSManagedObject] = []
    private var viewModel: BitcoinViewModel!
    @IBOutlet weak var cotacaoAtual: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var umaSemana: UIButton!
    @IBOutlet weak var duasSemanas: UIButton!
    @IBOutlet weak var umMes: UIButton!
    @IBOutlet weak var tresMeses: UIButton!
    @IBOutlet weak var seisMeses: UIButton!
    @IBOutlet weak var umAno: UIButton!
    @IBOutlet weak var todos: UIButton!
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.umaSemana.layer.borderWidth = 0
        self.duasSemanas.layer.borderWidth = 0
        self.umMes.layer.borderWidth = 0
        self.tresMeses.layer.borderWidth = 0
        self.seisMeses.layer.borderWidth = 0
        self.umAno.layer.borderWidth = 0
        self.umaSemana.layer.borderWidth = 0
        self.todos.layer.borderWidth = 0
        
        switch (sender){
        case umaSemana:
            self.umaSemana.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "1week")
        case duasSemanas:
            self.duasSemanas.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "2weeks")
        case umMes:
            self.umMes.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "1months")
        case tresMeses:
            self.tresMeses.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "3months")
        case seisMeses:
            self.seisMeses.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "6months")
        case umAno:
            self.umAno.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "1years")
        default:
            self.todos.layer.borderWidth = 1
            self.viewModel.getUrlJson(dia: "2years")
        }
    }
    
    func buttonStyle(){
        self.umaSemana.layer.cornerRadius = 15
        self.duasSemanas.layer.cornerRadius = 15
        self.umMes.layer.cornerRadius = 15
        self.tresMeses.layer.cornerRadius = 15
        self.seisMeses.layer.cornerRadius = 15
        self.umAno.layer.cornerRadius = 15
        self.todos.layer.cornerRadius = 15
        self.umaSemana.layer.borderColor = UIColor.white.cgColor
        self.duasSemanas.layer.borderColor = UIColor.white.cgColor
        self.umMes.layer.borderColor = UIColor.white.cgColor
        self.tresMeses.layer.borderColor = UIColor.white.cgColor
        self.seisMeses.layer.borderColor = UIColor.white.cgColor
        self.umAno.layer.borderColor = UIColor.white.cgColor
        self.todos.layer.borderColor = UIColor.white.cgColor
        self.umaSemana.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = BitcoinViewModel()
        self.viewModel.delegate = self
        configureStatusBar()
        buttonStyle()
        self.viewModel.getUrlJson(dia: "1week")
        self.viewModel.getDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.loadCoreDate()
    }
    
    func configureStatusBar(){
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func configureGraph(cotacao:Cotacao){
        var totalPontos = [Double]()
        var totalDias = [String]()
        var date = NSDate()
        let formatter = DateFormatter()
        for total in cotacao.cordenadas{
            totalPontos.append(Double(round(1000*total.y)/1000))
            date = NSDate(timeIntervalSince1970: total.x)
            totalDias.append(String(describing: date))
        }
        aaChartView = AAChartView()
        let chartViewWidth = view.frame.size.width
        let chartViewHeight = view.frame.size.height - 420
        aaChartView?.frame = CGRect(x: 0, y: 178, width: chartViewWidth, height: chartViewHeight)
        aaChartView?.contentHeight = chartViewHeight - 20
        view.addSubview(aaChartView!)
        aaChartView?.scrollEnabled = false//禁止图表内容滚动
        aaChartView?.isClearBackgroundColor = true
        aaChartModel = AAChartModel()
            .chartType(.spline)
            .colorsTheme(["#1e90ff","#ef476f","#ffd066","#04d69f","#25547c",])
            .title("")
            .subtitle("")
            .dataLabelEnabled(false)
            .legendEnabled(false)
            .markerRadius(0)
            .xAxisVisible(false)
            .axisColor("#838383")
            .tooltipValueSuffix("US$")
            .backgroundColor("#9c9c9c")
            .animationType(AAChartAnimationType.bounce)
            .backgroundColor("#22324c")
            .series([AASeriesElement().name(" ").data(totalPontos).color(AAGradientColor.lemonDrizzle).toDic()!,])
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
}
extension BitcoinViewController{
    func onValidateCotacao(erro: Bool?, cotacao: Cotacao?, valorHoje: String?) {
        if(!erro!){
            self.configureGraph(cotacao: cotacao!)
            self.cotacaoAtual.text = valorHoje
            self.viewModel.loadCoreDate()
            
            return
        }
        print("Deu errado")
    }
    func onValidadeCoreData(erro: Bool?, valorEdata: [String?]) {
        if(!erro!){
            self.coreDataStrings = valorEdata as! [String]
            self.customTableView.reloadData()
        }
        return
    }
    func onValidateDate(dia: String?) {
        self.footerLabel.text = "Bitcoin Price as \(dia!)"
    }
    
}

extension BitcoinViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coreDataStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if( !(cell != nil)){
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = self.coreDataStrings[indexPath.row]
        cell!.textLabel?.textColor = .white
        cell!.backgroundColor? = .clear
        return cell!
    }
    
}
