//
//  ViewController.swift
//  Bitcoin DB1
//
//  Created by Lucas Franco Bernardes on 29/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit
import AAInfographics

class BitcoinViewController: UIViewController {
    public var chartType: AAChartType?
    public var step: Bool?
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    var cotacao: Cotacao?
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureGraph()
        configureStatusBar()
        getUrlJson()
    }
    
    func configureStatusBar(){
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func configureGraph(cotacao:Cotacao){
        var totalPontos = [Double]()
        for total in cotacao.cordenadas{
            totalPontos.append("%.02",total.y)
        }
        aaChartView = AAChartView()
        let chartViewWidth = view.frame.size.width
        let chartViewHeight = view.frame.size.height - 420
        aaChartView?.frame = CGRect(x: 0, y: 138, width: chartViewWidth, height: chartViewHeight)
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

    func getUrlJson(){
        guard let gitUrl = URL(string: "https://api.blockchain.info/charts/market-price?timespan=31days") else { return }
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(Cotacao.self, from: data)
                DispatchQueue.main.async {
                    self.configureGraph(cotacao: gitData)
                }
                print(gitData.cordenadas[0].y ?? "Empty Name")
                
            } catch let err {
                print("Err", err)
            }
            }.resume()
        
        
        
    }
}

