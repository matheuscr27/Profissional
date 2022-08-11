#setwd('/home/matheus/Documentos/Programas/investimentos_orama')

mean_and_sd_for_prices <- function(my_datas, first_date = Sys.Date() -365, last_date = Sys.Date() , percent_sample_size, parametro){
  datas <- lapply(names(my_datas), function(x){
    my_dates <- my_datas[[x]][["price"]]$date   
    time_filter <- (my_dates >= first_date) & (my_dates <= last_date)
    if(length(which(time_filter))!= 0){
      data_vector <- na.exclude(my_datas[[x]][["price"]]$adjusted[time_filter])
      my_datas <- central_limit_theorem(data_vector, percent_sample_size = percent_sample_size , parametro$number_samples)
      return(my_datas)
    }else{
      return(list(NA,NA,NA,NA))
      }  
  })
  my_mean <-sapply(datas, "[[",1)  #datas$my_mean
  sd <- sapply(datas, "[[",3)  #datas$sd 
  var <- sapply(datas, "[[",4) 
  
  return(list(my_mean = my_mean, sd = sd, var = var))
}


#--------------------------------------------------------------------
#Consolidar os my_datas necessarios para a analise da estrategia
analysis_table <- function(price_and_dividends_data,
                           stock_portfolio,
                           today_trades_results,
                           first_date, 
                           last_date, 
                           percent_sample_size, 
                           parametro){

  
  my_means_sd_and_var <- as.data.frame(mean_and_sd_for_prices(price_and_dividends_data, 
                                                              first_date = first_date, 
                                                              last_date = last_date,
                                                              percent_sample_size = percent_sample_size,
                                                              parametro = parametro))

  
  my_means_sd_and_var$names <- names(price_and_dividends_data)
  last_price <- sapply(price_and_dividends_data, function(x){
    my_index <- length(x[['price']]$adjusted)
    
    return(x[['price']]$adjusted[my_index])
    
  })
  last_price <- sapply(last_price, '[',1)
  #last_price <- t(t(last_price))
  last_price <- data.frame(last_price = last_price)
  names(last_price) <- c("last_price")
  last_price$names <- names(price_and_dividends_data)
  last_dividend <-as.data.frame( t(sapply(price_and_dividends_data, function(x){
    if(is.na(x['dividends'])){
      return(c(NA,NA))
    }else{
      return(x[['dividends']][['dividend_table']][,c('date','dividend')][nrow(x[['dividends']][['dividend_table']]),])
    }
  })))
  
  names(last_dividend) <- c("last_payment_date","last_dividend")
  class(last_dividend$`last_payment_date`) <- 'Date'
  
  last_dividend$names <-  names(price_and_dividends_data)
  last_year_dividend_yield <-as.data.frame( sapply(price_and_dividends_data, function(x){
  
    if(is.na(x['dividends'])){
      return(NA)
    }else{
      return( x[['dividends']][["year_dividend_table"]][,"dividend_yeald_per_year"][nrow(x[['dividends']][["year_dividend_table"]])])
    }
  }))
  
  names(last_year_dividend_yield) <- c("last_year_dividend_yield")
  
  last_year_dividend_yield$names <-  names(price_and_dividends_data)
  
  
  last_dividend_yield <-as.data.frame( sapply(price_and_dividends_data, function(x){
    
    if(is.na(x['dividends'])){
      return(NA)
    }else{
      return( x[['dividends']][["dividend_table"]][ ,"dividend_per_price"][nrow(x[['dividends']][["dividend_table"]])])
    }
  }))
  
  names(last_dividend_yield) <- c("last_dividend_yield")
  last_dividend_yield$names <-  names(price_and_dividends_data)
  
  apparent_dividend_yield <- as.data.frame(sapply(price_and_dividends_data, function(x){
    if(is.na(x['dividends'])){
      return(NA)
    }else{
      return( x[['dividends']][["like_dividend_yield"]])
    }
  }))
  names(apparent_dividend_yield) <- c("apparent_dividend_yield")
  apparent_dividend_yield$names <-  names(price_and_dividends_data)
  
  price_and_dividend <- (merge(x = last_price, y = last_dividend, by.x = "names", by.y = "names"))
  price_and_dividend <- (merge(x = price_and_dividend, y = last_year_dividend_yield , by.x = "names", by.y = "names"))
  price_and_dividend <- (merge(x = price_and_dividend, y = last_dividend_yield , by.x = "names", by.y = "names"))
  price_and_dividend <- (merge(x = price_and_dividend, y = apparent_dividend_yield , by.x = "names", by.y = "names"))
  
  #----------------------------------
  end_table <- merge(x = price_and_dividend, y = my_means_sd_and_var, by.x = "names", by.y = "names", all.x = T)
  #-----------------------------------
  end_table$x <- (end_table$last_price - end_table$my_mean)/end_table$sd 
  
  end_table$percent_to_sell <- NA
  
  if(length(names(stock_portfolio$stock))>1){
    
    risk_table <- risk(stock_portfolio = stock_portfolio,
                       price_dividends_data = price_and_dividends_data)
    
    
    high_below_best_percent <- risk_table$high_below_ideal_percent
    above_best_percente <- apply(high_below_best_percent, MARGIN = 2, function(my_vector){
      return(max(na.exclude(my_vector)))
    })#get the high percent I need to sell to minimalize the risk 
  
    
    for (my_name in names(stock_portfolio$stock)){
      if(above_best_percente[my_name] >0){
        
        end_table$percent_to_sell[end_table$names == my_name] <- above_best_percente[my_name]
        
      }
    }
    
  }

  end_table$concentration_in_portfolio <- NA
  if(length(names(stock_portfolio$stock))>0){
    
    my_percents<- percent_stock_concentration(stock_portfolio = stock_portfolio, look = "owned value")

    for (my_name in names(stock_portfolio$stock)){
        
        end_table$concentration_in_portfolio[end_table$names == my_name] <- my_percents[my_name]
        
      
    }
  }
  

  end_table$index_prices_trader <- NA
  if(!is.na(today_trades_results)){
    
    
    price_index <- index_prices_trader(today_trades = today_trades_results)

    for (my_name in names(stock_portfolio$stock)){
      
      end_table$index_prices_trader[end_table$names == my_name] <- price_index[my_name]
      
    }
    
  }
  
  end_table$price_variation <- (end_table$last_price - end_table$index_prices_trader)/end_table$index_prices_trader
  
  #analisar se mercado e carteira estão em situação excepcional
  #backtest_stand <- view_data(table_trade = table_trade, stock_portfolio_list = stock_portfolio_list)
  
  #------------------------------------------------
  ibovespa <- price_and_dividends_data[['ibovespa']]$price$adjusted
  
  form_initial_change <- (ibovespa/(( ibovespa -ibovespa[1])))[-1]
  ibovespa_var <-abs((ibovespa[-1] - ibovespa[-length(ibovespa)])/(ibovespa[-length(ibovespa)]*form_initial_change))
  
  
  
  
  ibovespa_var_stats <- central_limit_theorem(vector_data = ibovespa_var[-length(ibovespa_var)],
                                              percent_sample_size = parametro$percent_sample_size_ibov, parametro$number_samples_ibov)

    
  
  market_normal_sd <-(ibovespa_var[length(ibovespa_var)] - ibovespa_var_stats$my_mean)/ibovespa_var_stats$sd
  print(market_normal_sd)
  if(is.na(market_normal_sd)){
    market_normal_sd = 0
  }
  
  if(abs(market_normal_sd) < 1.5*parameter$max_allowed_sd){
    #testa se o marcado esta em condições normais ou não
    
    end_table$sell <- (end_table$names %in% names(stock_portfolio$stock)) & 
      ((end_table$x > abs(parameter$max_allowed_sd)| 
          (end_table$concentration_in_portfolio > parameter$max_allowed_percent_concentration)&
          ((end_table$price_variation > parameter$stop_gain_percent)|(end_table$price_variation < parameter$stop_loss_percent))))
    
    end_table$sell <-  end_table$sell & !is.na( end_table$sell)
    
#    if(length(stock_portfolio[['stock']])< parameter$max_allowed_number_stocks){
      
#      max_allowe_number_stocks_filter <- rep(TRUE, nrow(end_table))
      
#    }else if(length(stock_portfolio[['stock']]) == parameter$max_allowed_number_stocks){
      
#      max_allowe_number_stocks_filter <- end_table$names %in% names(stock_portfolio[['stock']])
      
#    }else{
      
#      max_allowe_number_stocks_filter <- (end_table$names %in% names(stock_portfolio[['stock']])) 
 #     #stocks_to_sell_in_portfolio <- length(stock_portfolio[['stock']]) - parameter$max_allowed_number_stocks 
#      end_table$percent_to_sell[end_table$sell] <- 1
#    }
    
    end_table$buy <- (end_table$x <= abs(parameter$max_allowed_sd)) & 
      (end_table$last_price < parameter$highest_price) & 
      (end_table$last_year_dividend_yield >parameter$min_last_dividend_yield) &
      (end_table$var < parameter$max_allowed_var) #&
    #(end_table$last_price> end_table$my_mean)
    end_table$buy <-  end_table$buy & !is.na( end_table$buy) & !is.na(end_table$names) #&  max_allowe_number_stocks_filter
    
  }else{
      end_table$sell <- (end_table$names %in% names(stock_portfolio$stock))
      #end_table$sell <-  end_table$sell & !is.na( end_table$sell)
      end_table$percent_to_sell[end_table$sell] <- 1
      end_table$buy <- FALSE
      #end_table$buy <-  end_table$buy & !is.na( end_table$buy) & !is.na(end_table$names)
    
     }
    end_table$sell[which(end_table$names == "ibovespa")] <- FALSE
    end_table$buy[which(end_table$names == "ibovespa")] <- FALSE
    return(end_table)
}


#Central_limit_theorem
central_limit_theorem <- function(vector_data, percent_sample_size, number_samples){
  means_samples <- c()
  price_vector <- na.exclude(vector_data)
  while(length(means_samples)<= number_samples){
    #if(length(price_vector)< percent_sample_size){
    #  percent_sample_size = length(price_vector)
    #}
  
    sample_location <- sample(1:length(price_vector), round(percent_sample_size*length(price_vector)))
    sample_mean <- mean(price_vector[sample_location])
    means_samples <- append(means_samples,sample_mean)
   # price_vector <- price_vector[-sample_location]
  }
  return(list(my_mean = mean(means_samples), means_samples = means_samples, sd = sd(means_samples), var = var(means_samples)))
}

#test4 <- central_limit_theorem(vector_data = test[[4]]$price$adjusted, percent_sample_size = 5)
#test4$my_mean
#plot(table(round((test4$means_samples - test4$my_mean)/test4$sd, 1)))
#ibovespa <- price_dividend_data[['ibovespa']]$price$adjusted

#form_initial_change <- (ibovespa/(( ibovespa -ibovespa[1])))[-1]
#ibovespa_var <-abs((ibovespa[-1] - ibovespa[-length(ibovespa)])/(ibovespa[-length(ibovespa)]*form_initial_change))




#ibovespa_var_stats <- central_limit_theorem(vector_data = ibovespa_var[-length(ibovespa_var)],
#                                            percent_sample_size = parameter$percent_sample_size_ibov, number_samples = parameter$number_samples_ibov)

#market_normal_sd <-(ibovespa_var[length(ibovespa_var)] - ibovespa_var_stats$my_mean)/ibovespa_var_stats$sd
#ibovespa_var <-((ibovespa[-1])/(ibovespa[-length(ibovespa)]))
#tmean(ibovespa_var)

#test <- central_limit_theorem(ibovespa_var, 0.25, 10000)

#(ibovespa_var[length(ibovespa_var)]- test$my_mean)/test$sd

#round(test$my_mean, 5) + 3*round(test$sd,5)
#plot(table(round(test$means_samples, 5)))
#plot(table(round(price_dividend_data$PETR4.SA$price$adjusted, 2)))
#sd(price_dividend_data$PETR4.SA$price$adjusted)
#sd(means_samples - my_mean)
#sd(na.exclude(test[[4]]$price$adjusted))
#test3 <- analysis_table(price_and_dividends_data = price_dividend_data[1:150], first_date = Sys.Date() -1000, last_date = Sys.Date(), percent_sample_size = 5)
#test5 <- mean_and_sd_for_prices(test, percent_sample_size = 5)
