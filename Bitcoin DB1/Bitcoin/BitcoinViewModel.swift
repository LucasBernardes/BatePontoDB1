//
//  BitcoinModelView.swift
//  Bitcoin DB1
//
//  Created by Lucas Franco Bernardes on 29/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol BitcoinViewModelProtocol{
    func onValidateCotacao(erro: Bool?, cotacao: Cotacao?, valorHoje: String?)
    func onValidadeCoreData(erro: Bool?, valorEdata: [String?])
    func onValidateDate(dia: String?)
}


class BitcoinViewModel{
    var delegate: BitcoinViewModelProtocol?
    var cotacoes: [NSManagedObject] = []
    let dateFormatterGet = DateFormatter()
    
    
    func getDate(){
        dateFormatterGet.dateFormat = "MM-dd"
        self.delegate?.onValidateDate(dia: dateFormatterGet.string(from: Date()))
    }
    
    func loadCoreDate(){
        dateFormatterGet.dateFormat = "MM-dd HH:mm:ss"
        
        var valores = [String]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CotacaoCore")
        
        do {
            self.cotacoes = try managedContext.fetch(fetchRequest)
            for aux in cotacoes{
                let date = aux.value(forKey: "dia") as! Date
                valores.append("Valor: \(aux.value(forKey: "valor") as! Double) Dia: \(dateFormatterGet.string(from: date))")
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.delegate?.onValidadeCoreData(erro: false, valorEdata: valores)
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
                    self.delegate?.onValidateCotacao(erro: false, cotacao: gitData, valorHoje: String(format: "USD %.2f", gitData.cordenadas[gitData.cordenadas.count - 1].y))
                    self.save(valor: gitData.cordenadas[gitData.cordenadas.count - 1].y)
                }
                
                
            } catch let err {
                print("Err", err)
            }
            }.resume()
    }
    func save(valor: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CotacaoCore", in: managedContext)!
        let cotacao = NSManagedObject(entity: entity, insertInto: managedContext)
        cotacao.setValue(valor, forKeyPath: "valor")
        cotacao.setValue(Date(), forKeyPath: "dia")
        do {
            try managedContext.save()
            cotacoes.append(cotacao)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
