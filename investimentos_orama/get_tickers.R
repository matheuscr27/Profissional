setwd('C:\\Users\\mths2\\Documents\\Programas\\investimentos_orama')
get_tickets <- function(){
  
  
  stocks_year_2000 <- c("RPAD3.SA","ABEV3.SA","CBEE3.SA","BRSR3.SA","BBAS3.SA",
                      "BIOM3.SA","BDLL4.SA","BAZA3.SA",
                      "BRFS3.SA","ELET3.SA","CMIG4.SA", #"CLSC3.SA",
                      "FESA4.SA","SBSP3.SA","CTNM4.SA",
                      "CPFE3.SA","CYRE3.SA","CCPR3.SA","PNVL4.SA","DOHL4.SA",
                      "ENBR3.SA","EKTR4.SA","LIPR3.SA","EMAE4.SA","EMBR3.SA","ENMT4.SA",
                      "ETER3.SA","EUCA4.SA","CGRA4.SA","IGBR3.SA","JBDU4.SA",
                      "ROMI3.SA","INEP4.SA","MYPK3.SA","ITSA4.SA",
                      "JFEN3.SA","CTKA4.SA","LIGT3.SA","LAME4.SA","POMO4.SA",
                      "MNPR3.SA","PMAM3.SA","PTBL3.SA","PETR4.SA",
                      "RADL3.SA","RAPT4.SA","RCSL4.SA","REDE3.SA","GEPA4.SA",
                      "RSID3.SA","SCAR3.SA","TCNO4.SA",#"TASA4.SA",
                      "TEKA4.SA","VIVT4.SA","TUPY3.SA","USIM5.SA","VALE3.SA","VVAR3.SA",
                      "WEGE3.SA","MWET4.SA","WLMM4.SA")#PNVL4.SA em 11 jan
  advfn_name_2000 = c("alfa-on-RPAD3","ambev-s-a-on-ABEV3",NA,NA,"banco-do-brasil-on-BBAS3",
                      "biomm-on-BIOM3","bardella-pn-BDLL4",NA,
                      "brf-s-a-on-BRFS3","eletrobras-on-ELET3","cemig-pn-CMIG4",
                      "ferbasa-pn-FESA4",'sabesp-on-SBSP3','coteminas-pn-CTNM4',
                      'cpfl-energia-on-CPFE3','cyrela-realt-on-CYRE3','cyrela-commercial-prop-on-CCPR3','dimed-pn-PNVL4','dohler-pn-DOHL4',
                      'energias-br-on-ENBR3',NA,NA,"emae-pn-EMAE4",'embraer-on-EMBR3',NA,
                      'eternit-on-ETER3','eucatex-pn-EUCA4','grazziotin-pn-CGRA4','igb-s-a-on-IGBR3','j-b-duarte-pn-JBDU4',
                      'inds-romi-on-ROMI3',"inepar-pn-INEP4",'iochp-maxion-on-MYPK3','itausa-pn-ITSA4',
                      'joao-fortes-on-JFEN3','karsten-pn-CTKA4','light-on-LIGT3','lojas-americanas-pn-LAME4','marcopolo-pn-POMO4',
                      "minupar-on-MNPR3",NA,'portobello-on-PTBL3','petrobras-pn-PETR4',
                      'raia-drogasil-on-RADL3','randon-part-pn-RAPT4','recrusul-pn-RCSL4','rede-energia-on-REDE3','ger-paranap-pn-GEPA4',
                      'rossi-resid-on-RSID3',"sao-carlos-on-SCAR3",'tecnosolo-pn-TCNO4',
                      'teka-pn-TEKA4','telef-brasil-pn-VIVT4','tupy-on-TUPY3','usiminas-pna-USIM5','vale-on-VALE3','via-varejo-on-VVAR3',
                      'weg-on-WEGE3','wetzel-pn-MWET4','wlm-pn-WLMM4')
  
  
  stocks_year_2001 <- c("ATOM3.SA","BNBR3.SA","SANB4.SA","BMKS3.SA",
                      "BRAP4.SA","PCAR3.SA",
                      "CGAS5.SA","CSNA3.SA","CTSA4.SA","TRPL4.SA","EALT4.SA",
                      "GGBR4.SA","KEPL3.SA","GOAU4.SA",
                      "RPMG3.SA","VULC3.SA")
  
  advfn_name_2001 <- c('atompar-on-ATOM3',NA,'santander-br-pn-SANB4','bic-monark-on-BMKS3',
                       'bradespar-pn-BRAP4','p-acucar-cbd-pn-PCAR3',
                       NA,'sid-nacional-on-CSNA3','santanense-pn-CTSA4','isa-cteep-pn-TRPL4','aco-altona-pn-EALT4',
                       'gerdau-pn-GGBR4','kepler-weber-on-KEPL3','gerdau-met-pn-GOAU4',
                       'pet-manguinh-on-RPMG3','vulcabras-on-VULC3')
  
  stocks_year_2002 <- c("ITUB4.SA","JPSA3.SA","MNDL3.SA","CRPG5.SA")
  advfn_name_2002 <- c('itau-unibanco-pn-ITUB4','jereissati-on-JPSA3','mundial-on-MNDL3','cristal-pna-CRPG5')
  
  
  stocks_year_2003 <- c("BAHI3.SA","BRKM3.SA","CCRO3.SA","DTCY3.SA","EGIE3.SA",
                      "OIBR4.SA")
  advfn_name_2003 <- c('bahema-educacao-on-BAHI3','braskem-on-BRKM3','ccr-on-CCRO3', NA,'engie-brasil-on-EGIE3',
                       'oi-pn-OIBR4')
  
  stocks_year_2004 <- c("CESP5.SA","GFSA3.SA")
  advfn_name_2004 <- c("cesp-pna-CESP5",'gafisa-on-GFSA3')
  
  stocks_year_2005 <- c("ALPA4.SA","DASA3.SA","GOLL4.SA","GRND3.SA","PSSA3.SA")
  advfn_name_2005 <- c("alpargatas-pn-ALPA4",'dasa-on-DASA3','gol-pn-GOLL4','grendene-on-GRND3','porto-seguro-on-PSSA3')
  
  stocks_year_2006 <- c("BTOW3.SA","CSAN3.SA","RENT3.SA","FRTA3.SA","TIMP3.SA")
  advfn_name_2006 <- c('b2w-digital-on-BTOW3','cosan-on-CSAN3','localiza-on-RENT3','pomifrutas-on-FRTA3','tim-on-TIMP3')
  
  
  stocks_year_2007 <- c("AFLT3.SA","AGRO3.SA","CSMG3.SA",
                      "CARD3.SA","CRIV4.SA","GPIV33.SA","LPSB3.SA","LUPA3.SA",
                      "MMXM3.SA","ODPV3.SA","POSI3.SA","PFRM3.SA","TESA3.SA",
                      "TOTS3.SA","VLID3.SA")
  advfn_name_2007 <- c(NA,'brasil-agro-on-AGRO3','copasa-on-CSMG3',
                       NA, NA,NA,'lopes-brasil-on-LPSB3','lupatech-on-LUPA3',
                       'mmx-miner-on-MMXM3','odontoprev-on-ODPV3','positivo-tec-on-POSI3','profarma-on-PFRM3','terra-santa-on-TESA3',
                       'totvs-on-TOTS3','valid-on-VLID3')
  
  stocks_year_2008 <- c("UGPA3.SA","BPAN4.SA","IDVL4.SA","BBDC4.SA","ABCB4.SA",
                      "BRIV4.SA","BGIP4.SA","BMIN4.SA","BMEB4.SA","BOBR4.SA",
                      "BRML3.SA","BBRK3.SA","SAPR4.SA",
                      "CRDE3.SA","DTEX3.SA","ENGI4.SA","ENEV3.SA","EVEN3.SA",
                      "EZTC3.SA","FHER3.SA","FRAS3.SA","GSHP3.SA","HBOR3.SA",
                      "IGTA3.SA","JBSS3.SA","JHSF3.SA","KLBN4.SA","LOGN3.SA",
                      "MRFG3.SA","AMAR3.SA","FRIO3.SA",
                      "BEEF3.SA","MRVE3.SA","MULT3.SA","PDGR3.SA",
                      "PTNT4.SA","RDNI3.SA","SMTO3.SA","SLCE3.SA","SGPS3.SA",
                      "SUZB3.SA","TCSA3.SA","TGMA3.SA","TELB4.SA",
                      "TPIS3.SA","TRIS3.SA","VIVR3.SA","WSON33.SA")
  
  advfn_name_2008 <- c('ultrapar-on-UGPA3','banco-pan-pn-BPAN4','indusval-pn-IDVL4',"bradesco-pn-BBDC4",NA,#'abc-brasil-pn-ABCB4',
                       NA,"banese-pn-BGIP4",NA,'banco-mercantil-pn-BMEB4','bombril-pn-BOBR4', #"alfa-invest-pn-BRIV4"
                       'br-malls-par-on-BRML3','br-brokers-on-BBRK3',NA,
                       'cr2-on-CRDE3','duratex-on-DTEX3','energisa-pn-ENGI4','eneva-on-ENEV3',
                       'even-on-EVEN3','eztec-on-EZTC3',NA,'fras-le-on-FRAS3','general-shop-on-GSHP3',
                       'helbor-on-HBOR3','iguatemi-on-IGTA3','jbs-on-JBSS3','jhsf-part-on-JHSF3','klabin-pn-KLBN4',
                       'log-in-on-LOGN3','marfrig-on-MRFG3','lojas-marisa-on-AMAR3',
                       'metalfrio-on-FRIO3','minerva-on-BEEF3','mrv-on-MRVE3','multiplan-on-MULT3',
                       'pdg-realt-on-PDGR3','pettenati-pn-PTNT4','rni-on-RDNI3','sao-martinho-on-SMTO3',
                       'slc-agricola-on-SLCE3','springs-on-SGPS3','suzyear-papel-on-SUZB3','tecnisa-on-TCSA3','tegma-on-TGMA3',
                       'telebras-pn-TELB4','triunfo-part-on-TPIS3','trisul-on-TRIS3',
                       'viver-on-VIVR3',NA)
  
  stocks_year_2009 <- c("CEBR5.SA","BEES4.SA","GPAR3.SA",
                      "EQTL3.SA","HYPE3.SA","RANI4.SA")
  advfn_name_2009 <- c("ceb-pna-CEBR5","banestes-pn-BEES4",'celgpar-on-GPAR3',
                       'equatorial-on-EQTL3','hypera-on-HYPE3','celulose-irani-pn-RANI4')
  
  stocks_year_2010 <- c("PATI4.SA","MERC4.SA","CEDO4.SA","UNIP5.SA","AHEB5.SA","CIEL3.SA","DIRR3.SA","STBP3.SA")
  advfn_name_2010 <- c('panatlantica-pn-PATI4',NA,'cedro-pn-CEDO4','unipar-pna-UNIP5','sp-turismo-pna-AHEB5','cielo-on-CIEL3','direcional-on-DIRR3','santos-brasil-on-STBP3')
  
  stocks_year_2011 <- c("FLRY3.SA","YDUQ3.SA","CSAB4.SA","PEAB4.SA","CASN4.SA","MTIG4.SA","TKNO4.SA","BSLI4.SA","BALM4.SA","MSPA4.SA","JOPA4.SA","SLED4.SA","EQPA3.SA","SPRI3.SA","NORD3.SA","HAGA4.SA","COCE3.SA","MAPT4.SA","WHRL4.SA","PLAS3.SA","MOAR3.SA","LEVE3.SA","LREN3.SA","GUAR3.SA","BRGE5.SA","CPLE5.SA","HGTX3.SA","CSRN5.SA","CEEB5.SA","ADHM3.SA","APER3.SA","EEEL4.SA","ECOR3.SA",
                      "JSLG3.SA","MILS3.SA","OSXB3.SA","PRIO3.SA")
  advfn_name_2011 <- c('fleury-on-FLRY3',NA,'seg-al-bahia-pn-CSAB4','par-al-bahia-pn-PEAB4',NA,NA,'tekno-pn-TKNO4','brb-banco-pn-BSLI4','baumer-pn-BALM4',"melhor-sp-pn-MSPA4",'josapar-pn-JOPA4','saraiva-livr-pn-SLED4',NA,'springer-on-SPRI3',NA,'haga-pn-HAGA4',NA,NA,"whirlpool-pn-WHRL4",'plascar-part-on-PLAS3','mont-aranha-on-MOAR3','metal-leve-on-LEVE3','lojas-renner-on-LREN3','guararapes-on-GUAR3','alfa-consorcio-pna-BRGE5','copel-pna-CPLE5',"cia-hering-on-HGTX3",NA,NA,'advanced-dh-on-ADHM3',NA,'ceee-gt-pn-EEEL4','ecorodovias-on-ECOR3',
                       'jsl-on-JSLG3','mills-on-MILS3','osx-brasil-on-OSXB3','petrorio-on-PRIO3')
  
  stocks_year_2012 <- c("TIET4.SA","ALSO3.SA","ARZZ3.SA","AZEV4.SA","CEED4.SA","ENAT3.SA",
                      "MEAL3.SA","MGLU3.SA","QUAL3.SA","SHOW3.SA","TECN3.SA")
  advfn_name_2012 <- c("aes-tiete-on-TIET4",NA,'arezzo-on-ARZZ3','azevedo-pn-AZEV4',NA,NA,
                       'imc-s-a-on-MEAL3','magazine-luiza-on-MGLU3','qualicorp-on-QUAL3','time-for-fun-on-SHOW3','technos-on-TECN3')
  
  stocks_year_2013 <- c("B3SA3.SA","CLSC4.SA","LCAM3.SA","COGN3.SA","TEND3.SA","UCAS3.SA")
  advfn_name_2013 <- c(NA,'celesc-pn-CLSC4','locamerica-on-LCAM3',NA,'tenda-on-TEND3','unicasa-on-UCAS3')
  
  stocks_year_2014 <- c("ANIM3.SA","BBSE3.SA","BSEV3.SA","CVCB3.SA","LINX3.SA",
                      "MRSA3B.SA","SEER3.SA","SQIA3.SA","SMLS3.SA")
  advfn_name_2014 <- c('anima-on-ANIM3','bb-seguridade-on-BBSE3','biosev-on-BSEV3','cvc-brasil-on-CVCB3','linx-on-LINX3',
                       NA,'ser-educacional-on-SEER3',NA,'smiles-on-SMLS3')
  
  stocks_year_2015 <- c("RLOG3.SA","OFSA3.SA")
  advfn_name_2015 <- c('cosan-log-on-RLOG3','ourofino-s-a-on-OFSA3')
  
  stocks_year_2016 <- c("DMMO3.SA","RAIL3.SA","WIZS3.SA")
  advfn_name_2016 <- c('dommo-on-DMMO3','rumo-s-a-on-RAIL3','wiz-s-a-on-WIZS3')
  
  stocks_year_2017 <- c("EQMA3B.SA","ALUP4.SA","BPAC3.SA","AALR3.SA")
  advfn_name_2017 <- c(NA,'alupar-pn-ALUP4','btg-pactual-on-BPAC3','alliar-on-AALR3')
  
  stocks_year_2018 <- c("CRFB3.SA","BKBR3.SA","GBIO33.SA"
                      ,"OMGE3.SA","RNEW4.SA")
  advfn_name_2018 <- c('carrefour-on-CRFB3','burguer-king-brasil-on-BKBR3',NA,
                       'omega-ger-on-OMGE3','renova-pn-RNEW4')
  
  stocks_year_2019 <- c("TAEE4.SA","CAMB4.SA","HAPV3.SA","LOGG3.SA","GNDI3.SA")
  advfn_name_2019 <- c('taesa-pn-TAEE4','cambuci-pn-CAMB4','hapvida-on-HAPV3','log-commercial-on-LOGG3','intermedica-on-GNDI3')
  
  stocks_year_2020 <- c("BMGB4.SA","BIDI4.SA","BRPR3.SA","CEAB3.SA",
                      "CNTO3.SA","NTCO3.SA","NEOE3.SA","VIVA3.SA",
                      "CAML3.SA","PARD3.SA","IRBR3.SA","MOVI3.SA",
                      "SULA4.SA","BRDT3.SA")
  advfn_name_2020 <- c(NA,'banco-inter-pn-BIDI4','br-propert-on-BRPR3',NA,
                       'centauro-on-CNTO3',NA,'neoenergia-on-NEOE3','vivara-on-VIVA3',
                       'camil-alimentos-on-CAML3','ihpardini-on-PARD3','irb-brasil-on-IRBR3','movida-on-MOVI3',
                       'sul-america-pn-SULA4','petrobras-br-on-BRDT3')
  
  stocks_year_2021 <- c("AURA32.SA","GPCP4.SA","ALPK3.SA","AMBP3.SA","CEGR3.SA","DMVF3.SA","SOMA3.SA",
                      "LWSA3.SA","LJQQ3.SA","MTRE3.SA","MDNE3.SA","PDTC3.SA",
                      "PRNR3.SA")#, 'INTB3.SA'
  
  advfn_name_2021 <- c(NA,'gpc-part-pn-GPCP4','allpark-empreendimentos-on-ALPK3','ambipar-participstocks-e-on-AMBP3',NA,NA,NA,
                       'locaweb-on-LWSA3',NA,NA,'moura-dubeaux-on-MDNE3',NA,
                       'priner-on-PRNR3')#,'intelbras-on-INTB3'
  
  
  todos_tickers <- c(stocks_year_2000,stocks_year_2001,stocks_year_2002,stocks_year_2003
                     ,stocks_year_2004,stocks_year_2005,stocks_year_2006,stocks_year_2007,
                     stocks_year_2008,stocks_year_2009,stocks_year_2010,stocks_year_2011,
                     stocks_year_2012,stocks_year_2013,stocks_year_2014,stocks_year_2015,
                     stocks_year_2016,stocks_year_2017,stocks_year_2018, stocks_year_2019,
                     stocks_year_2020, stocks_year_2021)
  
  todos_advfn <- c(advfn_name_2000,advfn_name_2001,advfn_name_2002,advfn_name_2003,advfn_name_2004,
                   advfn_name_2005,advfn_name_2006,advfn_name_2007,advfn_name_2008,advfn_name_2009,
                   advfn_name_2010,advfn_name_2011,advfn_name_2012,advfn_name_2013,advfn_name_2014,
                   advfn_name_2015,advfn_name_2016,advfn_name_2017,advfn_name_2018,advfn_name_2019,
                   advfn_name_2020,advfn_name_2021)
  
  my_list <- list(todos_tickers= todos_tickers, todos_advfn= todos_advfn, 
                tickers = list('2000' = stocks_year_2000,
                               '2001'= stocks_year_2001,
                               '2002' = stocks_year_2002,
                               '2003' = stocks_year_2003,
                               '2004' = stocks_year_2004,
                               '2005' = stocks_year_2005,
                               '2006' = stocks_year_2006,
                               '2007' = stocks_year_2007,
                               '2008' = stocks_year_2008,
                               '2009' = stocks_year_2009,
                               '2010' = stocks_year_2010,
                               '2011' = stocks_year_2011,
                               '2012' = stocks_year_2012,
                               '2013' = stocks_year_2013,
                               '2014' = stocks_year_2014,
                               '2015' = stocks_year_2015,
                               '2016' = stocks_year_2016,
                               '2017' = stocks_year_2017,
                               '2018' = stocks_year_2018,
                               '2019' = stocks_year_2019,
                               '2020' = stocks_year_2020,
                               '2021' = stocks_year_2021
                               
                               
                ),
                advfn = list('2000' = advfn_name_2000,
                             '2001' = advfn_name_2001,
                             '2002' = advfn_name_2002,
                             '2003' = advfn_name_2003,
                             '2004' = advfn_name_2004,
                             '2005' = advfn_name_2005,
                             '2006' = advfn_name_2006,
                             '2007' = advfn_name_2007,
                             '2008' = advfn_name_2008,
                             '2009' = advfn_name_2009,
                             '2010' = advfn_name_2010,
                             '2011' = advfn_name_2011,
                             '2012' = advfn_name_2012,
                             '2013' = advfn_name_2013,
                             '2014' = advfn_name_2014,
                             '2015' = advfn_name_2015,
                             '2016' = advfn_name_2016,
                             '2017' = advfn_name_2017,
                             '2018' = advfn_name_2018,
                             '2019' = advfn_name_2019,
                             '2020' = advfn_name_2020,
                             '2021' = advfn_name_2021
                ))
  return(my_list)
}


#require('GetFREData')
#df_info <- get_info_companies()
#df_info_bolsa <- df_info[df_info$TP_MERC =='BOLSA',]
#df_info_bolsa <- df_info_bolsa[!is.na(df_info_bolsa$CD_CVM),]

#df_info_bolsa$DT_REG <- as.Date(df_info_bolsa$DT_REG, "%d/%m/%Y")
#df_info_bolsa$DT_CANCEL <- as.Date(df_info_bolsa$DT_CANCEL, "%d/%m/%Y")
#df_info_bolsa$DT_CONST <- as.Date(df_info_bolsa$DT_CONST, "%d/%m/%Y")

pegar_info_de_code_cvm <- function(code_cvm){
  if(!require('XML')) install.packages('XML',repos = "http://cran.us.r-project.org"); library(XML)
  if(!require('httr')) install.packages('httr',repos = "http://cran.us.r-project.org"); library(httr)
  if(!require('rvest')) install.packages('rvest',repos = "http://cran.us.r-project.org"); library(rvest)
  
  
  
  url <- paste0("http://bvmf.bmfbovespa.com.br/pt-br/mercados/acoes/empresas/ExecutaAcaoConsultaInfoEmp.asp?CodCVM=",code_cvm,"&ViewDoc=1&AnoDoc=2021&VersaoDoc=1&NumSeqDoc=100933#a")
  html <- xml2::read_html(url)
  tabela_html <- XML::htmlParse(html)
  #Extrair a raíz do arquivo HTML que estamos interessados, sem as informações superiores (desnecessárias)
  root <-  xmlRoot(tabela_html)
  #Ler o HTLM como tabela. Lembrar que a estrutura deve estar em caracteres 
  dados <-  readHTMLTable(root, stringsAsFactors = FALSE)#return(tabela)
  dados$V2 <- gsub('Mais Códigos','', dados$V2)
  my_index = 1
  while(';' %in% strsplit(strsplit(dados$V2[2],' ')[[1]][my_index],'')[[1]]){
    my_index = my_index + 1
  }
  dados$V2[2] <-sub("\r\n","", strsplit(dados$V2[2], " ")[[1]][my_index])
  
  return(dados)
}


table_code_cvm_tickers <- function(data){
 tickers <- sapply(data$CD_CVM, function(x){
   tab <- pegar_info_de_code_cvm(x)
   return(tab$V2[2])
 })
 df_code_tickers <- data.frame(code =data$CD_CVM, ticket = tickers )
 df_code_tickers <- na.exclude(df_code_tickers)
 df_code_tickers <- df_code_tickers[df_code_tickers$ticket!="",]
 return(df_code_tickers)   
}
#activo <- df_info_bolsa[df_info_bolsa$SIT_REG =="ATIVO",]
#test <- table_code_cvm_tickers(activo)
