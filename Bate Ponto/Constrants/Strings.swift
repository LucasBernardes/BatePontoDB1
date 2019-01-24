//
//  Strings.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 24/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation

struct Strings{
    public static let erroTitulo = "Problema na conexão!"
    public static let erroCpfTitulo = "Problema com o CPF"
    public static let erroCpfMensagem = "O CPF informado não foi encontrado na base de dados, por favor verifique o valor inserido"
    public static let erroSemTitulo = "Campo de CPF/Senha branco"
    public static let erroSemMensagem = "Por favor preencha ambos os campos antes de fazer a requisição de login"
    public static let erroSenhaTitulo = "Problema com a senha ou CPF"
    public static let erroSenhaMensagem = "A Senha não confere ou o CPF informado não foi encontrado na base de dados, por favor verifique os valores inseridos"
    public static let erroMensagem = "Houve um problema com os servidores e não foi possível executar esta ação"
    public static let erroLocationMensagem = "Para bater o ponto é necessário saber se você se encontra dentro da empresa, para isso o aplicativo necessita utlizar o localizador, por favor atorize sua utilização"
    public static let erroLocationTitulo = "O aplicativo precisa da sua localização"
    public static let erroBotao = "Compreendi"
    
    public static let erroDistanciaTitulo = "Você está muito longe!"
    public static let erroDistanciaMensagem = "Sua atual localização aparenta muito distante da sede da DB1, por favor fique no mínimo uma distância de 1 quadra das instalações"
    
}
