#Execucao estrat√©gia

setwd("C:/Users/mths2/Documents/Programas/investimentos_orama")
current_file <- c('execucao_orama.R',"main.R")
project_files <- list.files(pattern = "\\.R")
sapply(project_files[-(which(project_files %in% current_file))], source)# find all files in the current dir and import all their function 

stock_portfolio_ticker <- c("BBAS3.SA","BBSE3.SA","ITSA4.SA","SULA4.SA","OIBR3.SA","CMIG4.SA","CPLE3.SA","BBDC3.SA","VALE3.SA","REDE3.SA")

stock_portfolio_amount <- c(16, 12,28,25,800, 40, 90, 33, 5,20)
gap_time = 1000

all_tickers <- readRDS('Tickers/all_tickers_with_nas.rds')
all_tickers <- unique(all_tickers)

check_if_ticker_in_all_ticker <- function(any_ticker, all_tickers){
  return(any_ticker %in% all_tickers)
}
check_if_ticker_in_all_ticker("OIBR3", all_tickers)
all_tickers <- rbind(all_tickers,c(NA,"OIBR3"))
saveRDS(all_tickers, 'Tickers/all_tickers_with_nas.rds')
df_price_dividend <- import_datas(tickers = paste0(all_tickers$ticket,".SA"),
                                  first_date = Sys.Date()- gap_time,
                                  last_date = Sys.Date())

stock_portfolio <- list(stock = list())
stock_portfolio[["stock"]] <-  lapply(stock_portfolio_ticker, function(my_stock){
  my_price <- df_price_dividend[[my_stock]]$price[nrow(df_price_dividend[[my_stock]]$price), "adjusted"]
  amount <- stock_portfolio_amount[which(stock_portfolio_ticker == my_stock)]
 # stock_portfolio[["stocks"]] <- append(stock_portfolio[["stocks"]],)
  #stock_portfolio[["stocks"]][[my_stock]] <- list(price = my_price, amount = amount, value = my_price*amount  )
  return(list(price = my_price, amount = amount, "owned value" = my_price*amount  ))
  })
names(stock_portfolio[["stock"]]) <- stock_portfolio_ticker



parameter <- list(
  first_cash = 1000,
  contribution = 1000,
  highest_price = 100,
  max_allowed_percent_concentration = 0.12,
  max_allowed_sd = 3,
  max_allowed_var = 10,
  min_last_dividend_yield = 0.05,
  classification_criteria = 'var',
  percent_to_hold = 0.5,
  stop_gain_percent = 0.25,
  stop_loss_percent = -0.15,
  max_use_cash_percent = 0.9,
  exclude_tickers = c('MMAQ4.SA','BAZA3.SA'),
  percent_sample_size = 0.01,
  percent_sample_size_ibov = 0.001,
  rebalancing_look_count = 20,
  max_allowed_number_stocks = 15,
  number_samples = 5000,
  number_samples_ibov = 10000
)
#se n„o tiver tabela com trades
table_trade <- create_table_trade()
for(my_ticker in names(stock_portfolio[["stock"]])){
  table_trade <- register_buy(ticker = my_ticker,
                               amount = stock_portfolio[["stock"]][[my_ticker]]$amount,
                               table_trade = table_trade,
                               date_buy = Sys.Date(),
                               price_buy =  stock_portfolio[["stock"]][[my_ticker]]$price)
}
#---------------------
table <- analysis_table(price_and_dividends_data = df_price_dividend, 
                        stock_portfolio = stock_portfolio, 
                        first_date = Sys.Date()- gap_time,
                        last_date = Sys.Date(),
                        today_trades_results
                        percent_sample_size = parameter$percent_sample_size,
                        parametro = parameter)

#atualizar valores da carteira
stock_portfolio <- update_stock_portfolio(df_price_dividend, stock_portfolio = stock_portfolio)

#Se tiver aporte

aporte = 0

stock_portfolio <-  contribution(aporte, stock_portfolio = stock_portfolio)
#------------------



my_risk <- risk(stock_portfolio = stock_portfolio, price_dividends_data = df_price_dividend)
high_below_best_percent_mean<- apply(my_risk[[4]], MARGIN = 2, function(x){mean(na.exclude(x))})
high_below_best_percent_mean
mean(high_below_best_percent_mean)
high_below_best_percent_mean2
mean(high_below_best_percent_mean2)

round(stock_portfolio_amount*(1-high_below_best_percent_mean2)) - stock_portfolio_amount

#lista 
View(my_risk[[4]])
lista <- readRDS('lista.rds')
#lista <- list(list(stock_portfolio))
lista <- append(lista, list(stock_portfolio))
names(lista)[length(lista)] <-as.character(Sys.Date())
saveRDS(lista, "lista.rds")
