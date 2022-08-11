#setwd('/home/matheus/Documentos/Programas/investimentos_orama')


dividend_analy <- function(dividend, price_datas, last_date, ticker){
  
  x = ticker
  price_datas <- as.data.frame(price_datas)
  price_datas <- na.exclude(price_datas)
  dates_prices <- price_datas[, 'date']
  dividend <- as.data.frame(dividend)
  dates_div <- dividend$date
  
  #dates_prices <- as.Date(price_dates, "%Y-%m-%d")#[[1]]
  for( i in 1:length(dates_div)){
    dividend_date <- dates_div[i]
    if(length(which( dates_prices > dates_div[i]))>0){
      foot = 1
    }else if(length(which( dates_prices < dates_div[i]))>0){
      foot = -1
    }


    #while(!(dates_div[i] %in% dates_prices)){
    #  dates_div[i] =  dates_div[i] + foot
      
   # }
    
  }
  
#  prices <- list_data_price[[x]][['df.tickers']]
  prices <-  price_datas
 
   vector_prices <- sapply(unique(dates_div), function(x){
     
    while(!length(prices[,'adjusted'][prices[,'date'] == x])>0){
      print("loop")
      x = x + 1
    }
    price <- prices[,'adjusted'][prices[,'date'] == x]
    return(price)
  })
  #print(vector_prices)
 # print("-------------")
  vector_prices <- as.vector(sapply(vector_prices,'[[',1 ))
  
 # if(ticker == "MODL4.SA"){
    #print(vector_prices)
    #View(dividend)
  #}
  dividend$price.adj_dividend_day <-vector_prices#(prices)[filter_datas_price]
  #print(x)
  #print(paste('dividend =', dividend$dividend))
  #print(paste('price    =', dividend$price.adj_dividend_day))
  dividend$dividend_per_price <- dividend$dividend / dividend$price.adj_dividend_day
  
  
  list_year <- as.numeric(format(dividend$date, "%Y"))
  year <- unique(list_year)
  sum_per_year_dividends <- sapply(year, function(x){return(sum(na.exclude(dividend$dividend[list_year == x])))})
  year_dividend_table <- data.frame(Year = year, Dividend = sum_per_year_dividends)
  year_dividend_table$year_adj_price_mean <- sapply(year, function(x){return(mean(na.exclude(prices[,'adjusted'][as.numeric(format(dates_prices, "%Y")) == x])))})      
  year_dividend_table$dividend_yeald_per_year <- year_dividend_table$Dividend/year_dividend_table$year_adj_price_mean
  
  last_365_day <- as.Date((last_date - 365):last_date, origin = "1970-01-01")
  last_12_month_dividends <- sum(dividend$dividend[dividend$date %in% last_365_day])
  last_12_month_mean_price <- mean(prices[,'adjusted'][dates_prices %in% last_365_day])
  last_12_month_dividend_yield <- last_12_month_dividends/last_12_month_mean_price 
  last_12_month <- list(Dividend =last_12_month_dividends, 
                        Mean_price = last_12_month_mean_price,
                        Dividend_yield =last_12_month_dividend_yield  )
  
  like_dividend_yield <-tryCatch( 
    dividend$dividend[nrow(dividend)]/price_datas[,'adjusted'][nrow(price_datas)],
    error = function(cond){
      #message("deu meerda")
      return(NA)
    }
  )
  
  return(list(dividend_table = dividend,
              year_dividend_table = year_dividend_table,
              like_dividend_yield = like_dividend_yield,
              last_12_month = last_12_month))
  
  
}

import_datas <- function(tickers, 
                         first_date= Sys.Date()-1000, 
                         last_date = Sys.Date(),
                         list_price_dividend = NULL){
  if(!require('quantmod')) install.packages('quantmod'); require(quantmod)
  if(!require('dplyr')) install.packages('dplyr'); require(dplyr)
  if(!require('tidyverse')) install.packages('tidyverse'); require(tidyverse)
  if(!require('devtools')) install.packages('devtools'); require(devtools)
  if(!require('tidyquant')) devtools::install_github("business-science/tidyquant"); require(tidyquant)
  #require("GetDFPData2")

  number = length(tickers)
  #list_data_price <- lapply(tickers, 
  #                          tidyquant::tq_get, 
  #                          from =  first_date, 
  #                          to = last_date, 
  #                          get = tq_get_options()[1])
  list_data_price <- lapply(tickers, function(ticker){
    #print(ticker)
    #print(paste("Falta =", number - which(tickers == ticker)))
    
    return(tidyquant::tq_get(ticker,
                            from =  first_date, 
                            to = last_date, 
                            get = tq_get_options()[1] ))
  })
  
  names(list_data_price) <- tickers
  
  list_data_price <- list_data_price[!is.na(list_data_price[1:length(list_data_price)])]
  
  if(!(is.null(list_price_dividend ))){
    for(ticker in names(list_data_price)){
      if(ticker %in% names(list_price_dividend)){
          list_data_price[[ticker]] <- unique(rbind(list_price_dividend[[ticker]]$price,
                                                list_data_price[[ticker]]))
        }
      }
  }
  #list_data_dividend <- lapply(names(list_data_price), 
   #                            tidyquant::tq_get, 
  #                             from = first_date, 
  #                             to = last_date, 
  #                             get = tq_get_options()[3])
  
  
  list_data_dividend <- lapply(names(list_data_price), function(ticker){
  
    #print(paste("Falta =", number - which(tickers == ticker)))
    
    return(tidyquant::tq_get(ticker,
                             from =  first_date, 
                             to = last_date, 
                             get = tq_get_options()[3] ))
  })
  #list_price_dividend = price_dividend_data)
  names(list_data_dividend) <- names(list_data_price)
  
  
  list_data_dividend <- list_data_dividend[!is.na(list_data_dividend[1:length(list_data_dividend)])]

  list_table_dividends <- lapply(names(list_data_dividend), function(x){
      
      #if(is.null(list_data_dividend[[x]])){
      if(nrow(list_data_dividend[[x]]) == 0){
        return(NA)
      }else{
        #print(paste("is na =", is.na(list_data_dividend[[x]])))
        #print(paste("is null =", is.null(list_data_dividend[[x]])))
        
        dividend_table <- list_data_dividend[[x]]
        names(dividend_table)[3] <- c("dividend")
        dividend_table$date <- as.Date(dividend_table$date)
        if(!(is.null(list_price_dividend ))){
          if(x %in% names(list_price_dividend)){
            if(!(length(list_price_dividend[[x]]$dividends)==1)){
              dividend_table <-unique(rbind(list_price_dividend[[x]]$dividends$dividend_table[,c(1:3)], dividend_table))
              }
            
          } 
        }
 #     list_divi <- dividend_analy(dividend = dividend_table, ticker = x ,price_datas = list_data_price[[x]], last_date = last_date, list_price_dividend = list_price_dividend) 
          
        list_divi <- dividend_analy(dividend = dividend_table, ticker = x ,price_datas = list_data_price[[x]], last_date = last_date) 
        return(list_divi)
      }
  })
  names(list_table_dividends) <- names(list_data_dividend)
  names_old_dividends <- c()
  if(!(is.null(list_price_dividend ))){
    names_old_dividends <- names(list_price_dividend)[!(names(list_price_dividend) %in% names(list_table_dividends)) &
                               sapply(names(list_price_dividend), function(x){return(length(list_price_dividend[[x]]$dividends))})>1]
  #pega os nomes dos tickers que tiveram dividendos antes da data de atualizacao
  }
  for(ticker in names_old_dividends){
    list_table_dividends <- append(list_table_dividends, list_price_dividend[[ticker]]$dividends)
    names(list_table_dividends)[length(list_table_dividends)] <- ticker
  }
  df_date_list <- lapply(c(names(list_data_dividend),names_old_dividends), 
                         #function(x){return(list(price=as.data.frame(list_data_price[[x]]),
                        #                                  dividends = ifelse(
                         #                                   x %in% names_old_dividends,list_price_dividend[[x]]$dividends , list_table_dividends[[x]])))
                        function(x){return(list(price=as.data.frame(list_data_price[[x]]),
                                                dividends = list_table_dividends[[x]]))
                          
                        })
  names(df_date_list) <- c(names(list_data_dividend),names_old_dividends)
  #incluir
  bvsp = tidyquant::tq_get('^BVSP', from = first_date,to = last_date)
  df_date_list <- append(df_date_list, list(ibovespa = list(price = bvsp, dividends = NA)))
  
  return(df_date_list)
}


filter_price_dividend_by_date <- function(import_datas, first_date, last_date, tickers){
  
  tickers_names <- names(import_datas)
  tickers_names <- tickers_names[tickers_names %in% tickers]
  df_date_list <- lapply(tickers_names, 
                         function(x){ 
                           
                           price = import_datas[[x]]$price
                           price = price[(price$date>= first_date) &(price$date<= last_date),]

                           if(nrow(price) == 0){
                             return(NULL)
                           }
                           if(!is.na(import_datas[[x]]$dividends[1])){
                            dividends = import_datas[[x]]$dividends
                            dividends = dividends$dividend_table[(dividends$dividend_table$date >= first_date)&(dividends$dividend_table$date <= last_date),]
                            
                            if(length(dividends$date) == 0){
                              dividends = NA
                            }else{
                            dividends = dividend_analy(dividend = dividends, 
                                                       price_datas = price, 
                                                       last_date = last_date, ticker = x)
                            }
                            
                           }else{
                             dividends = NA
                           }
                           return(list(price= price,
                                                 dividends = dividends))
                           }) 
  
  names(df_date_list) <- tickers_names
  #df_date_list <- df_date_list[sapply(df_date_list, length)>1]
  df_date_list <- df_date_list[which(!sapply(df_date_list, is.null))]
  
  return(df_date_list)
  
}

dividend_analy <- function(dividend, price_datas, last_date, ticker){
  
  x = ticker
  price_datas <- as.data.frame(price_datas)
  
  dates_prices <- price_datas[, "date"]
  #print(class(dates_prices))
  dividend <- as.data.frame(dividend)
  dates_div <- dividend$date
  
  #dates_prices <- as.Date(price_dates, "%Y-%m-%d")#[[1]]
  for( i in 1:length(dates_div)){
    dividend_date <- dates_div[i]
    if(length(which( dates_prices > dates_div[i]))>0){
      foot = 1
    }else if(length(which( dates_prices < dates_div[i]))>0){
      foot = -1
    }
    
    
    while(!(dates_div[i] %in% dates_prices)){
      print('loop2')
      dates_div[i] =  dates_div[i] + foot
      
    }
    
  }
  
  #  prices <- list_data_price[[x]][['df.tickers']]
  prices <-  price_datas
  date_index_name_2 <- if('price.adjusted'%in% colnames(prices)){
    c('price.adjusted', 'ref.date')
  }else{
    c('df.tickers.price.adjusted', 'df.tickers.ref.date')
  }
  vector_prices <- sapply(dates_div, function(x){
    return(
      
      prices[,"adjusted"][prices[,"date"] == x])
  })
  vector_prices <- as.vector(sapply(vector_prices,'[[',1 ))
  
  
  dividend$price.adj_dividend_day <-vector_prices#(prices)[filter_datas_price]
  dividend$dividend_per_price <- dividend$dividend / dividend$price.adj_dividend_day
  
  list_year <- as.numeric(format(dividend$date, "%Y"))
  year <- unique(list_year)
  sum_per_year_dividends <- sapply(year, function(x){return(sum(na.exclude(dividend$dividend[list_year == x])))})
  year_dividend_table <- data.frame(Year = year, Dividend = sum_per_year_dividends)
  year_dividend_table$year_adj_price_mean <- sapply(year, function(x){return(mean(na.exclude(prices[,"adjusted"][as.numeric(format(dates_prices, "%Y")) == x])))})      
  year_dividend_table$dividend_yeald_per_year <- year_dividend_table$Dividend/year_dividend_table$year_adj_price_mean
  
  last_365_day <- as.Date((last_date - 365):last_date, origin = "1970-01-01")
  last_12_month_dividends <- sum(dividend$dividend[dividend$date %in% last_365_day])
  last_12_month_mean_price <- mean(prices[,"adjusted"][dates_prices %in% last_365_day])
  last_12_month_dividend_yield <- last_12_month_dividends/last_12_month_mean_price 
  last_12_month <- list(Dividend =last_12_month_dividends, 
                        Mean_price = last_12_month_mean_price,
                        Dividend_yield =last_12_month_dividend_yield  )
  
  like_dividend_yield <-tryCatch( 
    dividend$dividend[nrow(dividend)]/price_datas[,"adjusted"][nrow(price_datas)],
    error = function(cond){
      #message("deu meerda")
      #print(cond)
      return(NA)
    }
  )
  
  return(list(dividend_table = dividend,
              year_dividend_table = year_dividend_table,
              like_dividend_yield = like_dividend_yield,
              last_12_month = last_12_month))
  
  
}

#test <- import_datas(tickers =paste0("CPLE3",".SA"), list_price_dividend = list_price_dividend)

#test_tickers <- readRDS("Tickers/all_tickers_with_nas.rds")
#test <- import_datas(tickers =paste0(test_tickers$ticket[1:10],".SA"))
#test2 <- filter_price_dividend_by_date(import_datas = price_dividend_data, first_date = Sys.Date() - 365, last_date = Sys.Date(), 
#                                       tickers = stocks_in_b3$ticket[-which(stocks_in_b3$ticket %in% parameter$exclude_tickers)])
#system.time(import_datas(tickers = tickers$todos_tickers))
#tickers <- get_tickets()
#my_datas <- import_datas(tickers = tickers$todos_tickers[c(12, 14,16,20,25)])

