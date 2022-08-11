#this file registre and help view the trades result
#setwd('/home/matheus/Documentos/Programas/investimentos_orama')

create_table_trade <- function(){
  table_trade <- data.frame(t(rep(NA, each=10)))
  colnames(table_trade) <- c('ticker', 'amount',
                             'buy_date','buy_price','buy_value',
                             'sell_date','sell_price','sell_value',
                             'balance', 'percent_balance')
  class(table_trade$buy_date) <- 'Date'
  class(table_trade$sell_date) <- 'Date'
  
  table_trade <- na.exclude(table_trade)
  return(table_trade)
}
register_buy <- function(ticker, amount,table_trade, date_buy, price_buy){
  names_table <- colnames(table_trade)
  my_table <- rbind(table_trade, c(rep(NA, each = ncol(table_trade))))
  colnames(my_table) <- names_table

  my_table$ticker[nrow(my_table)] = ticker
  my_table$amount[nrow(my_table)] = amount
  my_table$buy_date[nrow(my_table)] = date_buy
  class(my_table$buy_date) <- 'Date'
  class(my_table$sell_date) <- 'Date'
  my_table$buy_price[nrow(my_table)] = price_buy
  my_table$buy_value[nrow(my_table)] = my_table$buy_price[nrow(my_table)]*my_table$amount[nrow(my_table)]
  
  return(my_table)
}

register_sell <- function(ticker,table, date_buy, date_sell, price_sell){
 find_ticker <- which(table$ticker==ticker & table$buy_date==date_buy)
 table$sell_date[find_ticker] = date_sell
 table$sell_price[find_ticker] = price_sell
 table$sell_value[find_ticker] = table$amount[find_ticker]*table$sell_price[find_ticker]
 table$balance[find_ticker] <- table$sell_value[find_ticker]- table$buy_value[find_ticker]
 table$percent_balance[find_ticker] <- table$balance[find_ticker]/table$buy_value[find_ticker]
 return(table)
}

current_table_trades <- function(data_table){
  return(data_table[is.na(data_table$sell_date),])
}

today_trades_results <- function(current_table_trades, stock_portfolio, date){#all stocks in stock_portfolio are in my_table tickers
  #stock_portfolio' stocks prices need to be update
  fun_current_table_trades <- current_table_trades
  if(nrow(fun_current_table_trades)!=0){
    fun_current_table_trades$today_date <- date
    fun_current_table_trades$today_price <- NA
    fun_current_table_trades$today_value <- NA
    fun_current_table_trades$balance_today <- NA
    fun_current_table_trades$percent_balance_today <- NA

    fun_current_table_trades$sell_date <- NULL
    fun_current_table_trades$sell_price <- NULL
    fun_current_table_trades$sell_value <- NULL
    fun_current_table_trades$balance <- NULL

    fun_current_table_trades$percent_balance <- NULL
    for(x in names(stock_portfolio[['stock']])){
    #my_table_balance <- lapply(names(stock_portfolio[['stock']]), function(x){

      position_ticker <- which(fun_current_table_trades$ticker == x)
      fun_current_table_trades$today_price[position_ticker] <-  stock_portfolio[['stock']][[x]][['price']]
      fun_current_table_trades$today_value[position_ticker] <- fun_current_table_trades$today_price[position_ticker]*current_table_trades$amount[position_ticker]  
      fun_current_table_trades$balance_today[position_ticker] <- fun_current_table_trades$today_value[position_ticker]-fun_current_table_trades$buy_value[position_ticker] 
      fun_current_table_trades$percent_balance_today[position_ticker] <- fun_current_table_trades$balance_today[position_ticker]/fun_current_table_trades$buy_value[position_ticker] 

      #return(fun_current_table_trades[position_ticker,])
      }
    
    return(fun_current_table_trades)
    
  }else{
    return(NA)
  }
}

index_prices_trader <- function(today_trades){
  prices <- sapply(unique(today_trades$ticker), function(ticker){
    
    prices <- today_trades$today_price[today_trades$ticker == ticker]
    amount <- today_trades$amount[today_trades$ticker == ticker] 
    
    ticker_index_price <- sum(prices*amount)/sum(amount)
    return(ticker_index_price)
  })
  
  return(prices) 
  
}
#stock_portfolio <- list(stock = list(OIBR3.SA = list(price = 17), PETR3.SA = list(price = 24), VALE3.SA = list(price = 40)))
#test <- register_buy(ticker = 'OIBR3.SA',amount = 3, table_trade = table_trade, date_buy = "2020-01-01", price_buy = 12)
#test2 <- register_sell(ticker = 'OIBR3.SA',table = test, date_buy = '2020-01-01', date_sell = '2020-01-25', price_sell = 13)
#test3 <- register_buy(ticker = 'OIBR3.SA',amount = 4, table_trade = test2, date_buy = "2020-01-03", price_buy = 14)
#test4 <- register_buy(ticker = 'PETR3.SA',amount = 10, table_trade = test3, date_buy = "2020-01-05", price_buy = 20)
#test5 <- register_sell(ticker = 'PETR3.SA',table = test4, date_buy = '2020-01-05', date_sell = '2020-01-25', price_sell = 13)
#test5 <- register_buy(ticker = 'PETR3.SA',amount = 10, table_trade = test5, date_buy = "2020-01-06", price_buy = 21)
#test6 <- current_table_trades(data_table = test5)
#test7 <- today_trades_results(current_table_trades = test6, stock_portfolio = stock_portfolio, date = '2020-02-01')
#test5 <- register_buy(ticker = 'VALE3.SA',amount = 20, table_trade = test5, date_buy = "2020-04-27", price_buy = 50)
#meu controle da stock_portfolio real

#my_rico_table <- table_trade


#import my trader table
#my_rico_table <- readRDS("my_rico_table.R")
#put new dates
#my_rico_table <- register_buy(ticker = 'WIZS3.SA', 
#                              table_trade = my_rico_table, 
#                              amount = 12, 
#                              date_buy = as.Date('2021-04-16'),
#                              price_buy = 8.13)
#Save
#saveRDS(my_rico_table,file = "my_rico_table.R")
