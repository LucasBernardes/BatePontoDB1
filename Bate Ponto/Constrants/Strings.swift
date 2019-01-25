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
    public static let erroFuncionarioTitulo = "Funcionário Não Encontrado!"
    public static let erroFuncionarioMensagem = "O funcionário não está registrado no banco de dados."
    
    
    //server call
    public static let pontofopagUrl = "https://registra.pontofopag.com.br/"
    
    //request strings
    public static let dialogSubtitle = "A permissão da localização atual dentro do app é obrigatória para bater o ponto, já a localização no background só é necessária para o aviso automático de chegada na empresa!"
    public static let dialogTitle = "Lista de Permissão"
    public static let dialogComment = "Para bater o ponto é necessário estar a 300m da empresa, caso optando pela opção de localização no background o aplicativo irá avisar assim que for possível bater o ponto."
    public static let permissionLocal = "Local"
    public static let permissionChegada = "Chegada na DB1"
    public static let permissionNotificacao = "Notificação"
    public static let permissionLocalDescription = "Necessário para bater o ponto"
    public static let permissionChegadaDescription = "Opcional para aviso de chegada"
    public static let permissionNotificacaoDescription = "Notificação de chegada/saída da empresa"
}
