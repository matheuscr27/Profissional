get_dividends <- function(datas,stock_portfolio, first_date = Sys.Date()-365, last_date = Sys.Date()){
  
  dividends_sum  <-sapply(names(stock_portfolio[['stock']]), function(x){ 
    if(is.na(datas[[x]][["dividends"]])){
      return(0)
    }else{
      return(sum(datas[[x]][["dividends"]][["dividend_table"]]$dividend[datas[[x]][["dividends"]][["dividend_table"]]$date %in% as.Date(first_date:last_date, origin = '1970-01-01')])*stock_portfolio[['stock']][[x]][['amount']]) #soma dividendos e multiplica pela amount de stock possuidas
    }
  })
  my_df <- data.frame(tickers =names(stock_portfolio[['stock']]), dividends_sum = dividends_sum)

  stock_portfolio$Dividends <- sum(my_df$dividends_sum)

  stock_portfolio$Cash <- stock_portfolio$Cash + stock_portfolio$Dividends

  return(stock_portfolio)
  
}



contribution <- function(value_contribution, stock_portfolio){
  stock_portfolio[['Cash']] = stock_portfolio[['Cash']] + value_contribution
  stock_portfolio[['contribution']] = stock_portfolio[['contribution']] + value_contribution

  return(stock_portfolio)
  
}

update_stock_portfolio <- function(datas, stock_portfolio){
  for(name in names(stock_portfolio[['stock']])){
    if(length(datas$'last_price'[datas$names == name]) > 0){
      
      if(!is.na(datas$'last_price'[datas$names == name])){
        
        stock_portfolio[['stock']][[name]][['price']] = datas$'last_price'[datas$names == name]
      }
      stock_portfolio[['stock']][[name]][['owned value']] = stock_portfolio[['stock']][[name]][['price']]*stock_portfolio[['stock']][[name]][['amount']]
    }else{
      stock_portfolio[['stock']][[name]] <- NULL 
    }
  }
  
  if(length(names(stock_portfolio$stock))>0){
    
    values <- sapply(stock_portfolio[['stock']],'[[',3)

    #values <- sapply(values,'[[',1)
    values <- sapply(values, function(x){
      if(!is.null(x[1])){
        return(x[[1]])
      }else{
        return(NULL)
      }
    })
    

    sum_values <- sum(values)
    stock_portfolio$value <- sum_values
  }else{
    stock_portfolio$value = 0
    stock_portfolio$stock <- NULL
  }
  
  if(!is.null(stock_portfolio$Dividends)){
    stock_portfolio$stock_portfolio_dividend_yield <- stock_portfolio$Dividends/stock_portfolio$value
  }
  
  stock_portfolio$overall_value <- stock_portfolio$value + stock_portfolio$Cash
  
  return(stock_portfolio)
}

buy_operation <- function(tickers_to_buy, stock_portfolio, datas, table_trade, date,max_use_cash_percent){
  #rankear datas em relacao a dada do pagamento do dividendo, do mais antigo para o mais recente
  datas <- datas[order(datas$last_payment_date),]
  tickers_to_buy <- tickers_to_buy[rank(match(tickers_to_buy, datas$names))]
  if(length(tickers_to_buy)==0){

    return(list(stock_portfolio = stock_portfolio, table_trade = table_trade))
  }else{
    #---------------------------------------------------------------------------------
    rate_cash_per_value_stock_buy = 0

    cash <- round(stock_portfolio[['Cash']]*max_use_cash_percent, digits = 2)
    while((rate_cash_per_value_stock_buy < 1) & (length(tickers_to_buy)>0)){
      values_stocks_to_buy <- as.data.frame(sapply(tickers_to_buy, function(x){
        return(datas$'last_price'[datas$names == x])
        
      }))
     
      stock_to_buy_value <- sum(values_stocks_to_buy[,1])
      rate_cash_per_value_stock_buy = cash/stock_to_buy_value
      #definir quem ? o mais caro e o mais barato e retirar o mais caro (fazer depois)
      tickers_to_buy_backup = tickers_to_buy
      tickers_to_buy = tickers_to_buy[-1]
      
    }
    amount_to_buy = as.integer(rate_cash_per_value_stock_buy)
    if(amount_to_buy > 0){
      for(name in tickers_to_buy_backup){
        
        past_amount <- if(!is.null(stock_portfolio[['stock']][[name]][["amount"]])){
          stock_portfolio[['stock']][[name]][["amount"]]
        }else{0}
        stock_price <- datas$'last_price'[datas$names == name]
        stock_portfolio[['stock']][[name]][['price']] <- stock_price 
        
        stock_portfolio[['stock']][[name]][["amount"]] <-  amount_to_buy + past_amount
        stock_portfolio[['stock']][[name]][['owned value']] <- stock_portfolio[['stock']][[name]][['price']]*stock_portfolio[['stock']][[name]][['amount']]
        
        table_trade <- register_buy(ticker = name,
                                    table_trade = table_trade,
                                    amount = amount_to_buy,
                                    date_buy = date,
                                    price_buy = stock_price)
      }
    }
    stock_portfolio[['Cash']] = stock_portfolio[['Cash']] - amount_to_buy*stock_to_buy_value


    return(list(stock_portfolio = stock_portfolio, table_trade = table_trade))
  }
}

sell_operation <- function(tickers_for_sell, stock_portfolio, datas, percent_to_keep, table_trade, my_today_trades_results, date){
  
  percent_to_keep_stock <- percent_to_keep_function(tickers_for_sell = tickers_for_sell, 
                                                    percent_to_keep = percent_to_keep,
                                                    my_today_trades_results = my_today_trades_results,
                                                    datas = datas)
  
  
  new_cash_vector <- c()
  for(name in unique(tickers_for_sell)){
    
    sub_today_table_trade <- my_today_trades_results[my_today_trades_results$ticker == name,]
    
    sum_amount <- sum(sub_today_table_trade$amount)
    backup_sum_amount <- sum_amount
    
    #amount_to_sell <-round(sum_amount*(1 - percent_to_keep_stock[[name]]))
    amount_to_sell <-round(stock_portfolio[['stock']][[name]][['amount']]*(1 - percent_to_keep_stock[[name]]))
    
    #sum_amount_back <- sum_amount
    while((sum_amount > amount_to_sell)& (nrow(sub_today_table_trade)>=1)){
      #sum_amount <- sum_amount_back
      #sub_today_table_trade_back <- sub_today_table_trade
      sub_today_table_trade <- sub_today_table_trade[-nrow(sub_today_table_trade),]
     # sum_amount_back <- sum(sub_today_table_trade$amount)
      sum_amount <- sum(sub_today_table_trade$amount)
    } 
    #if(sum_amount_back != sum_amount){
      
    #  sum_amount <- sum_amount_back
    #  sub_today_table_trade <- sub_today_table_trade_back 
    #}
   
   
      for(my_date in sub_today_table_trade$buy_date){
        table_trade <- register_sell(ticker = name,
                                     table = table_trade,
                                     date_buy = my_date,
                                     date_sell = date,
                                     price_sell = stock_portfolio$stock[[name]]$price)
        
      }
    
      stock_portfolio[['stock']][[name]][['amount']] =stock_portfolio[['stock']][[name]][['amount']] - sum_amount #backup_sum_amount - sum_amount
      past_owned_value <- stock_portfolio[['stock']][[name]][['owned value']]
      stock_portfolio[['stock']][[name]][['owned value']]=stock_portfolio[['stock']][[name]][['price']]*stock_portfolio[['stock']][[name]][['amount']]
      stock_portfolio[["Cash"]] <-  stock_portfolio[["Cash"]] + past_owned_value - stock_portfolio[['stock']][[name]][['owned value']]
      if(stock_portfolio[['stock']][[name]][['amount']] ==0){
        stock_portfolio[["stock"]][name] <- NULL
      }

    
  }

  return(list(stock_portfolio = stock_portfolio, table_trade = table_trade)) 
}

percent_to_keep_function <- function(tickers_for_sell, percent_to_keep ,my_today_trades_results, datas){
  values <- lapply(unique(tickers_for_sell), function(name){
    
    if(!is.na(datas$percent_to_sell[datas$names == name])){
      
      percent_to_keep_stock = 1 - datas$percent_to_sell[datas$names == name]
      if(percent_to_keep_stock> percent_to_keep){
        return(percent_to_keep) 
      }else{
        return(percent_to_keep_stock)
      }
      
    }else{
      return(percent_to_keep)
    }
    
    
    
  })
  names(values) <- tickers_for_sell

  return(values)
}


make_stock_portfolio <- function(datas, first_cash, table_trade, date, max_use_cash_percent){
  stock_portfolio <- list(Cash = first_cash)
  
  new_portfolio <- buy_operation(tickers_to_buy = datas$names, 
                                 stock_portfolio = stock_portfolio,
                                 datas = datas,
                                 table_trade = table_trade,
                                 date = date,
                                 max_use_cash_percent = max_use_cash_percent)
  stock_portfolio <- new_portfolio$stock_portfolio 
  stock_portfolio$value <- sum(sapply(sapply(stock_portfolio$stock,'[',3),'['))
  stock_portfolio$overall_value <- stock_portfolio$value + stock_portfolio$Cash
  stock_portfolio[['contribution']] <- first_cash
  table_trade <- new_portfolio$table_trade
  
  return(list(stock_portfolio = stock_portfolio, table_trade = table_trade))
}

percent_stock_concentration <- function(stock_portfolio, look){
  value <-sapply(sapply(stock_portfolio[['stock']], function(x){
    return(x[[look]])
  }), '[[',1)
  percents <- value/sum(value)
  return(percents)
}


valid_date_list <- function(price_dividend_data){
 date_list <-  c()
 for(my_name in names(price_dividend_data)){
   date_list <- append(date_list, price_dividend_data[[my_name]]$price$date)
 }
 
  date_list <-as.Date(unique(date_list), "%Y-%m-%d")
 
  return(date_list[order(as.Date(date_list, format="%d/%m/%Y"))] )
}


mensal_and_daily_operations <- function(stocks_in_b3, 
                                        parameter, 
                                        operation_day,
                                        valid_dates,
                                        time_data_intervals_days,
                                        time_gap_day,
                                        prices_dividends_data, 
                                        stock_portfolio, 
                                        table_trade,
                                        stock_portfolio_list){
  
  
  list_per_day_stock_portfolio <- list()
  list_per_day_table_trade <- list()
  
  intra_operation_day <- operation_day
  
    while ((operation_day < intra_operation_day + time_gap_day)&!is.na(operation_day)){
      
      print(operation_day)

     filtered_price_dividend <-  filter_price_dividend_by_date(import_datas = prices_dividends_data, 
                                    first_date = operation_day - time_data_intervals_days,
                                    last_date = operation_day,
                                    tickers = c(stocks_in_b3,"ibovespa"))

     if(length(names(stock_portfolio$stock))>0){

      today_table_trader <- today_trades_results(current_table_trades = current_table_trades(table_trade),
                                                stock_portfolio = stock_portfolio,
                                                date = operation_day)
     }else{
       today_table_trader <- NA 
     }
      my_table <- analysis_table(price_and_dividends_data = filtered_price_dividend,
                              first_date = operation_day - time_data_intervals_days,
                              today_trades_results = today_table_trader,
                              last_date = operation_day, 
                              percent_sample_size = parameter$percent_sample_size,
                              stock_portfolio = stock_portfolio, 
                              parametro = parameter)
      if(length(names(stock_portfolio$stock))>0){

        stock_portfolio <- update_stock_portfolio(datas = my_table, 
                                                  stock_portfolio = stock_portfolio)
        

        stock_portfolio <- get_dividends(datas = prices_dividends_data,
                                         stock_portfolio = stock_portfolio,
                                         first_date = operation_day,
                                         last_date = operation_day)
      }

      my_today_trades_results = today_trades_results(current_table_trades = current_table_trades(table_trade),
                                                     stock_portfolio = stock_portfolio,
                                                     date = operation_day)
      
      if(((length(names(stock_portfolio[["stock"]]))>0))&(!is.na(my_today_trades_results))){

        
        my_sell <- sell_operation(tickers_for_sell = na.exclude(my_table$names[my_table$sell]),
                                  stock_portfolio = stock_portfolio,
                                  datas = my_table,
                                  percent_to_keep = parameter$percent_to_hold,
                                  table_trade = table_trade,
                                  my_today_trades_results = my_today_trades_results,
                                  date = operation_day)
        stock_portfolio <- my_sell$stock_portfolio
        table_trade <- my_sell$table_trade
        
      }
      
      stock_portfolio <- update_stock_portfolio(datas = my_table, 
                                                stock_portfolio = stock_portfolio)
      
      tickers_to_buy =na.exclude(my_table$names[my_table$buy])
      if(length(names(stock_portfolio[["stock"]]))>parameter$max_allowed_number_stocks){
        tickers_to_buy = tickers_to_buy[tickers_to_buy %in% names(stock_portfolio[["stock"]])]
      }
      
      my_buy <- buy_operation(tickers_to_buy =tickers_to_buy,
                              stock_portfolio = stock_portfolio,
                              datas = my_table,
                              table_trade = table_trade,
                              date = operation_day,
                              max_use_cash_percent = parameter$max_use_cash_percent)
      
      
      stock_portfolio <-update_stock_portfolio(my_table,my_buy$stock_portfolio)
      table_trade <- my_buy$table_trade
      
      
      
      list_per_day_stock_portfolio <- append(list_per_day_stock_portfolio, list(stock_portfolio))
      names(list_per_day_stock_portfolio)[length(list_per_day_stock_portfolio)] <- as.character(operation_day)
      list_per_day_table_trade<- append(list_per_day_table_trade, list(table_trade))
      names(list_per_day_table_trade)[length(list_per_day_table_trade)] <- as.character(operation_day)
      
      #--------
      operation_day <- valid_dates[which(valid_dates== operation_day)+1]
    }
  
return(list(stock_portfolio = stock_portfolio,table_trade = table_trade, 
            operation_day = operation_day, 
            list_per_day_stock_portfolio = list_per_day_stock_portfolio,
            list_per_day_table_trade = list_per_day_table_trade,
            my_table = my_table))
}


#stock_portfolio_back <- stock_portfolio
#stock_portfolio <- stock_portfolio_back
Rebalancing_stock_portfolio <- function(stock_portfolio, 
                                        price_dividend_data,
                                        table_trade,
                                        parameter,
                                        operation_day,
                                        my_table,
                                        rebalancing_look_count){
  original_risk <- risk(stock_portfolio = stock_portfolio, price_dividends_data = price_dividend_data)
  original_risk <-  mean(original_risk[[1]])
  
  my_count = 1
  while (my_count < rebalancing_look_count) {
    
    my_count = my_count + 1
    my_risk <- risk(stock_portfolio = stock_portfolio, price_dividends_data = price_dividend_data)
    stock_portfolio_risk <- mean(my_risk[[1]])
    risks_mean <- apply(my_risk[[1]], MARGIN = 2, mean)
    ticker_to_sell <- names(risks_mean)[which(risks_mean == max(risks_mean))]
    
    my_today_trades_results = today_trades_results(current_table_trades = current_table_trades(table_trade),
                                                   stock_portfolio = stock_portfolio,
                                                   date = operation_day)
    
    if(!is.na(my_today_trades_results)){
    my_sell <- sell_operation(tickers_for_sell = ticker_to_sell,
                              stock_portfolio = stock_portfolio,
                              datas = my_table,
                              percent_to_keep = parameter$percent_to_hold,
                              table_trade = table_trade,
                              my_today_trades_results = my_today_trades_results,
                              date = operation_day)
   
      stock_portfolio <- update_stock_portfolio(datas = my_table, stock_portfolio = my_sell$stock_portfolio)
      table_trade <- my_sell$table_trade
    }
    
    tickers_to_buy =na.exclude(my_table$names[my_table$buy])
    if(length(names(stock_portfolio[["stock"]]))>parameter$max_allowed_number_stocks){
      tickers_to_buy = tickers_to_buy[tickers_to_buy %in% names(stock_portfolio[["stock"]])]
    }
    
    my_buy <- buy_operation(tickers_to_buy =tickers_to_buy,
                            stock_portfolio = stock_portfolio,
                            datas = my_table,
                            table_trade = table_trade,
                            date = operation_day,
                            max_use_cash_percent = parameter$max_use_cash_percent)
    
    
    
    stock_portfolio <- my_buy$stock_portfolio
    table_trade <- my_buy$table_trade
  
    
    stock_portfolio <- update_stock_portfolio(datas = my_table, stock_portfolio = stock_portfolio)
    
    }
  
  my_risk <- risk(stock_portfolio = stock_portfolio, price_dividends_data = price_dividend_data)
  stock_portfolio_risk <- mean(my_risk[[1]])
  
  return(list(stock_portfolio = stock_portfolio,
              table_trade = table_trade,
              original_risk = original_risk,
              new_risk = stock_portfolio_risk)) 
}

#test <- Rebalancing_stock_portfolio(stock_portfolio = stock_portfolio,
#                            table_trade = table_trade,
#                            price_dividend_data = price_dividend_data,
#                            parameter = parameter,
#                             operation_day = operation_day,
#                            rebalancing_look_count = 25)

#test$original_risk
#test$new_risk

#test2 <- risk(stock_portfolio = test$stock_portfolio, price_dividends_data = price_dividend_data)

