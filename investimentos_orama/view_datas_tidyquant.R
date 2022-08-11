#view datas
#setwd('/home/matheus/Documentos/Programas/financial_r_project')
#if(!require("ggplot2")) install.packages("ggplot2"); require(ggplot2)
#if(!require('tidyverse')) install.packages('tidyverse'); require(tidyverse)

view_data <- function(table_trade, stock_portfolio_list){
   
  wins_amount <-length(table_trade$balance[table_trade$balance > 0])
  wins_percent_balance_mean <- mean(na.exclude(table_trade$percent_balance[table_trade$percent_balance>0]))
  
  loss_amount <- length(table_trade$balance[table_trade$balance <= 0])
  loss_percent_balance_mean <- mean(na.exclude(table_trade$percent_balance[table_trade$percent_balance <=0]))
  
  wins_proportion <- wins_amount/(wins_amount + loss_amount)
  mean_balance <- mean(na.exclude(table_trade$balance))
  mean_percente_balance <- mean(na.exclude(table_trade$percent_balance))
  
  results <- list(wins_amount = wins_amount,
                  wins_percent_balance_mean = wins_percent_balance_mean,
                  loss_amount = loss_amount,
                  loss_percent_balance_mean = loss_percent_balance_mean,
                  wins_proportion = wins_proportion,
                  mean_balance = mean_balance,
                  mean_percente_balance = mean_percente_balance)
  
  extrac_from_stock_portfolio <- function(stock_portfolio_list, my_element){
    
    my_df <- sapply(stock_portfolio_list, function(portfolio){
      
      if(!is.null(portfolio[[my_element]])){
        
        return(portfolio[[my_element]])
      }else{
        return(NA)
      }
      
    })
    
    return(my_df)
  }
  
  
  extract_portfolio_values <- function(stock_portfolio_list){
    
    return(extrac_from_stock_portfolio(stock_portfolio_list, "value"))
  }
  extract_portfolio_cash <- function(stock_portfolio_list){
    
    
    return(extrac_from_stock_portfolio(stock_portfolio_list, "Cash"))    
  }
  
  extract_portfolio_dates <- function(stock_portfolio_list){
    return(as.Date(names(stock_portfolio_list)))
  }
  
  extract_portfolio_dividends <- function(stock_portfolio_list){
    sapply(stock_portfolio_list, function(x){
      if(!is.null(x[['Dividends']])){
        return(x[['Dividends']])
      }else{
        return(0)
      }
    })
  }
  
  extract_portfolio_diversification <- function(stock_portfolio_list){
    return(sapply( stock_portfolio_list, function(x){
      return(length(x[['stock']]))
    }))  
  }
  
  extract_portfolio_risk <- function(stock_portfolio_list){
    return(sapply( stock_portfolio_list, function(x){
      return(length(x[['risk']]))
    }))  
  }
  portfolio_values          <- extract_portfolio_values(stock_portfolio_list = stock_portfolio_list)
  portfolio_cashs           <- extract_portfolio_cash(stock_portfolio_list = stock_portfolio_list)
  portfolio_dates           <- extract_portfolio_dates(stock_portfolio_list = stock_portfolio_list)
  portfolio_dividends       <- extract_portfolio_dividends(stock_portfolio_list = stock_portfolio_list)
  portfolio_diversification <- extract_portfolio_diversification(stock_portfolio_list = stock_portfolio_list)

  portfolio_values_plus_cash <- portfolio_values + portfolio_cashs
  change_percente <- (portfolio_values_plus_cash[-1] - portfolio_values_plus_cash[-length(portfolio_values_plus_cash)])/portfolio_values_plus_cash[-length(portfolio_values_plus_cash)]
 
  portfolio_datas <- data.frame(dates = portfolio_dates,
                                values = portfolio_values,
                                cashs = portfolio_cashs,
                                values_plus_cash = portfolio_values_plus_cash,
                                dividends = portfolio_dividends,
                                diversification = portfolio_diversification,
                                change_percente = append(NA ,change_percente) )
results <- append(results, list(var = var(change_percente )))
return(list(portfolio_datas = portfolio_datas, results = results))
}

#backtest_stand <- view_data(table_trade = table_trade, stock_portfolio_list = stock_portfolio_list)
#backtest_min <- view_data(table_trade = table_trade_min, stock_portfolio_list = stock_portfolio_min_list)
#backtest_max <- view_data(table_trade = table_trade_max, stock_portfolio_list = stock_portfolio_max_list)
#backtest_dynamic <- view_data(table_trade = table_trade_dynamic, stock_portfolio_list = stock_portfolio_dynamic_list)
#backtest_dynamic_min <- view_data(table_trade = table_trade_dynamic_min, stock_portfolio_list = stock_portfolio_dynamic_min_list)
#backtest_dynamic_max <- view_data(table_trade = table_trade_dynamic_max, stock_portfolio_list = stock_portfolio_dynamic_max_list)


#my_plot <- ggplot(data = backtest_stand$portfolio_datas, aes(x = dates, y = values_plus_cash ))

#my_plot + geom_line(colour = 'Darkblue') #+
#  geom_line(aes(y = backtest_min$portfolio_datas$values_plus_cash), colour = 'Darkred') +
#  geom_line( aes(y = backtest_max$portfolio_datas$values_plus_cash), colour = 'Darkgreen')+ # +
#  geom_line( aes(y = backtest_dynamic$portfolio_datas$values_plus_cash), colour = 'Blue') +
#  geom_line( aes(y = backtest_dynamic_min$portfolio_datas$values_plus_cash), colour = 'Red') +
#  geom_line( aes(y = backtest_dynamic_max$portfolio_datas$values_plus_cash), colour = 'Green') # +


#geom_line(aes(x = unique(format(as.Date(names(stock_portfolio_list)), "01-%m-%Y")),
#                y = seq(200, 200*length(unique(format(as.Date(names(stock_portfolio_list)), "%m-%Y"))))
#, by = 200) )
# Add label position

#unique(format(as.Date(names(stock_portfolio_list)), "01-%m-%Y"))

#back <- readRDS('Backtest_view_div_2021-06-21 01_56_40.rds')
#table_trade <- back$table_trade
#table_trade_min <- back$table_trade_min
#table_trade_max <- back$table_trade_max
#table_trade_dynamic <- back$table_trade_dynamic

#stock_portfolio_list <- back$stock_portfolio_list
#stock_portfolio_min_list <- back$stock_portfolio_min_list
#stock_portfolio_max_list <- back$stock_portfolio_max_list
#stock_portfolio_max_dynamic <- back$stock_portfolio_dynamic_list

#price_dividend_data <- back$prices_dividends_data



