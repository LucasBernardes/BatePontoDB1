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

class BitcoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cotacoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if( !(cell != nil))
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        var atual = cotacoes[indexPath.row]
        

        cell!.textLabel?.text = "\(atual.value(forKey: "valor") as! Double)"
        cell!.textLabel?.textColor = .white
        cell!.backgroundColor? = .clear
        return cell!
    }
    
    @IBOutlet weak var customTableView: UITableView!
    public var chartType: AAChartType?
    public var step: Bool?
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    var cotacao: Cotacao?
    var currentValue = 0.00000
    var cotacoes: [NSManagedObject] = []
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
            self.getUrlJson(dia: "1week")
        case duasSemanas:
            self.duasSemanas.layer.borderWidth = 1
            self.getUrlJson(dia: "2weeks")
        case umMes:
            self.umMes.layer.borderWidth = 1
            self.getUrlJson(dia: "1months")
        case tresMeses:
            self.tresMeses.layer.borderWidth = 1
            self.getUrlJson(dia: "3months")
        case seisMeses:
            self.seisMeses.layer.borderWidth = 1
            self.getUrlJson(dia: "6months")
        case umAno:
            self.umAno.layer.borderWidth = 1
            self.getUrlJson(dia: "1years")
        default:
            self.todos.layer.borderWidth = 1
            self.getUrlJson(dia: "2years")
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
        getUrlJson(dia: "1week")
        configureStatusBar()
        buttonStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCoreDate()

    }
    func loadCoreDate(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CotacaoCore")
        
        do {
            self.cotacoes = try managedContext.fetch(fetchRequest)
            for aux in cotacoes{
                print(aux.value(forKey: "valor") as! Double)
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.customTableView.reloadData()
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
            .series([
                AASeriesElement()
                    .name(" ")
                    .data(totalPontos)
                    .color(AAGradientColor.lemonDrizzle)
                    
                    .toDic()!,
                ])
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }

    func getUrlJson(dia: String){
        guard let gitUrl = URL(string: "https://api.blockchain.info/charts/market-price?timespan=\(dia)") else { return }
        print(gitUrl)
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(Cotacao.self, from: data)
                DispatchQueue.main.async {
                    self.configureGraph(cotacao: gitData)
                    self.cotacaoAtual.text = String(format: "USD %.2f", gitData.cordenadas[gitData.cordenadas.count - 1].y)
                    //self.save(valor: gitData.cordenadas[gitData.cordenadas.count - 1].y, data: gitData.cordenadas[gitData.cordenadas.count - 1].x)
                }
                
                
            } catch let err {
                print("Err", err)
            }
            }.resume()
    }
    
    func save(valor: Double, data: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CotacaoCore", in: managedContext)!
        let cotacao = NSManagedObject(entity: entity, insertInto: managedContext)
        cotacao.setValue(valor, forKeyPath: "valor")
        //cotacao.setValue(data, forKeyPath: "data")
        do {
            try managedContext.save()
            cotacoes.append(cotacao)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

