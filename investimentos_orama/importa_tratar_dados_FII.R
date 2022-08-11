#importa e tratar dados FII
#Este programa visa criar uma tabela consolida com informaçoes sobre FII e seu pagamento de dividendos 
#zip_name <- "/home/matheus/Downloads/fii.zip"
#download.file("http://dados.cvm.gov.br/dados/FII/DOC/INF_MENSAL/DADOS/inf_mensal_fii_2021.zip", destfile = zip_name)
#test <- unzip(zip_name, list = F)
#test <-lapply(test[c(1:3)], read.csv2)
#test <- read.csv2(test[2], col.names = c("CNPJ_Fundo",
#"Data_Referencia","Versao",	"Data_Informacao_Numero_Cotistas",
#"Total_Numero_Cotistas","Numero_Cotistas_Pessoa_Fisica",
#"Numero_Cotistas_Pessoa_Juridica_Nao_Financeira",
#"Numero_Cotistas_Banco_Comercial",
#"Numero_Cotistas_Corretora_Distribuidora",
#"Numero_Cotistas_Outras_Pessoas_Juridicas_Financeira",
#"Numero_Cotistas_Investidores_Nao_Residentes",
#"Numero_Cotistas_Entidade_Aberta_Previdencia_Complementar",
#"Numero_Cotistas_Entidade_Fechada_Previd�ncia_Complementar",
#"Numero_Cotistas_Regime_Proprio_Previdencia_Servidores_Publicos",
#"Numero_Cotistas_Sociedade_Seguradora_Resseguradora",
#"Numero_Cotistas_Sociedade_Capitalizacao_Arrendamento_Mercantil",
#"Numero_Cotistas_FII",
#"Numero_Cotistas_Outros_Fundos",
#"Numero_Cotistas_Distribuidores_Fundo",
#"Numero_Cotistas_Outros_Tipos",
#"Valor_Ativo","Patrimonio_Liquido",
#"Cotas_Emitidas",
#"Valor_Patrimonial_Cotas",
#"Percentual_Despesas_Taxa_Administracao",
#"Percentual_Despesas_Agente_Custodiante",
#"Percentual_Rentabilidade_Efetiva_Mes",
#"Percentual_Rentabilidade_Patrimonial_Mes",
#"Percentual_Dividend_Yield_Mes",
#"Percentual_Amortizacao_Cotas_Mes"))
#test$Percentual_Dividend_Yield_Mes <- as.numeric(test$Percentual_Dividend_Yield_Mes)
#test$Percentual_Dividend_Yield_Mes[515]
