#Este programa gerara 1 arquivo xlsx, com 6 planilhas diferentes. 4 para cada cargo, 
#um pros NAs(funcionários que nao falaram qual era o cargo e a ultima é a media da empresa em geral)
#Cada planiha contem as empresas, os anos e a media para cada segmento de formacao
#Atençao pois a incompatibilidade do programa esta comendo os acentos, entao verifique se as palavras acentudas de fao estao 

#Colocar sua pasta de trabalho aqui
minha_pasta <- "C:\\Users\\Theresa\\Downloads\\freelancer"

#funcoes

merge_total_dados_filtrados <- function(total, dados_filtrados){ 
  return(merge(y = total, 
        x = dados_filtrados, 
        by.y = "year", 
        by.x = "year.fre"))
}

fun_dados <- function(dados_filtrados_4, dados){
  first <- merge(x = dados_filtrados_4, 
                   y = dados, 
                   by.x = c("year" , "cod"), 
                   by.y = c("year.fre" ,"codigo"),
                   all.x = TRUE)
  first$year <- first$year -1
  return(list(first))
}

#_____________________________________________________________-

romao_medias <- function(minha_pasta){
  setwd(minha_pasta)
  if(!require('readxl')) install.packages('readxl',repos = "http://cran.us.r-project.org"); library(readxl)
  if(!require('writexl')) install.packages('writexl',repos = "http://cran.us.r-project.org"); library(writexl)
  
  nome_xlsx <- list.files(pattern ="GESTOREs ATUAL.xlsx")
  dados <- readxl::read_xlsx(nome_xlsx)
  dados$name.company <- as.factor(dados$name.company)
  dados$desc.type.board <- as.factor(dados$desc.type.board)
  dados$cod...5 <- as.factor(dados$cod...5)
  dados$code.type.job <-  as.factor(dados$code.type.job)
  
  anos <- c(min(na.exclude(dados$year.fre)):max(na.exclude(dados$year.fre)))
  
  dados_filtrados <- data.frame( cod...5 = dados$cod...5, 
                                 name.company = dados$name.company,
                                 year.fre = dados$year.fre, 
                                 desc.type.board = dados$desc.type.board ,
                                 code.type.job = dados$code.type.job,
                                 graduaçao = dados$graduaçao, #atençao a acentuaçao aqui
                                 `pos lato` = dados$`pos lato`, 
                                 `pos strito` = dados$`pos strito`)
  
  media_gra_pl_ps_per_yr <- data.frame()
  total_1 <- data.frame()
  total_2 <- data.frame()
  total_1_1 <- data.frame()
  for(name in levels(dados$name.company)){
    codigo <- levels(dados_filtrados$cod...5)[levels(dados$name.company) == name]
    for(year in anos){
      
      for(cargo in levels(dados$desc.type.board )){
        x <-dados_filtrados[levels(dados$name.company) == name & dados_filtrados$year.fre == year & levels(dados$desc.type.board )== cargo, ] 
        
        x1 <-x[, c(6:8)] 
        
        media_gra_pl_ps_per_yr <- apply(na.exclude(x1), MARGIN = 2, mean)
        
        y <- data.frame(codigo ,name, year, cargo, t(media_gra_pl_ps_per_yr))
        total_1 <- rbind(total_1, y)
          for(tipo_codigo in levels(dados$code.type.job )){
            if(tipo_codigo %in% c("10", "12" ,"13","30","31","32","33", "36")){
              x2 <- x[levels(x$code.type.job) == tipo_codigo, c(6:8)]
            
              media_gra_pl_ps_per_yr_1 <- apply(na.exclude(x2), MARGIN = 2, mean)
              if(!is.na(mean(na.exclude(media_gra_pl_ps_per_yr_1 )))){
              y1 <- data.frame(codigo, name, year, cargo, tipo_codigo, t(media_gra_pl_ps_per_yr_1))
              total_1_1 <- rbind(total_1_1, y1)
              }
            }
          }

          
        
      }
      z <-dados_filtrados[levels(dados$name.company) ==name & dados_filtrados$year.fre == year , c(6:8)] 
      media_gra_pl_ps_per_yr_2 <- apply(na.exclude(z), MARGIN = 2, mean)
      f <-  data.frame(codigo ,name, year, t(media_gra_pl_ps_per_yr_2))
      total_2 <- rbind(total_2, f)
    }
  }
  
  
  dados_filtrados_2 <- data.frame( ref.date = levels(as.factor(dados$ref.date)), year.fre = anos)

  dados_filtrados_3 <- merge_total_dados_filtrados(total_1, dados_filtrados_2)
  
  dados_filtrados_4 <- na.exclude(data.frame(year = (1 + dados$...1), cod = dados$cod...2, dados$Nome))
  
  lista <- list()
  for(carg in levels(dados$desc.type.board )){
    filtro <- dados_filtrados_3[dados_filtrados_3$cargo == carg,]
    dados_2 <- fun_dados(dados_filtrados_4, filtro)
    lista <- append(lista, dados_2)
  }
  
 
  dados_filtrados_6 <- merge_total_dados_filtrados(total_1_1, dados_filtrados_2)
 
  dados_4 <-  fun_dados(dados_filtrados_4, dados_filtrados_6)
  lista <- append(lista, dados_4) 
  
  
  dados_filtrados_5 <- merge_total_dados_filtrados(total_2, dados_filtrados_2)
  dados_3 <- fun_dados(dados_filtrados_4, dados_filtrados_5)
  lista <- append(lista, dados_3)
  
  
  
  
  names(lista) <- c(levels(dados$desc.type.board ),"media considerando o tipo de CEO","media total das empresas")
  for(name in names(lista)){
    for(coluna in c("graduaçao","pos.lato","pos.strito")){#atençao a acentuaçao aqui
      x <- lista[[name]][, coluna]
      for(ranking in 1:length(x)){
        if(is.na(x[ranking])== FALSE & x[ranking] == 0){#if nao funciona se tiver NA no vetor de comparacao
          x[ranking] <- " "
        }
      }
      lista[[name]][, coluna] <- as.numeric(x)
      
      
    }
  }
  n <- paste0(minha_pasta, "//dados_cargo_empresas.xlsx")
  write_xlsx(lista, path = n)
}

romao_medias(minha_pasta)
