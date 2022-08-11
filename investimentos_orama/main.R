if(!require("tidyverse")) install.packages('tidyverse'); require(tidyverse)
if(!require("GetFREData")) install.packages('GetFREData'); require(GetFREData)#GetFREData only work with tidyverse


setwd('C:\\Users\\mths2\\Documents\\Programas\\investimentos_orama')
current_file <- c('execucao_orama.R',"main.R")
project_files <- list.files(pattern = "\\.R")
sapply(project_files[-(which(project_files %in% current_file))], source)# find all files in the current dir and import all their function 

#get tickers

#df_info <- get_info_companies()


df_info <- read.csv2("http://dados.cvm.gov.br/dados/CIA_ABERTA/CAD/DADOS/cad_cia_aberta.csv")
df_info_bolsa <- df_info[(df_info$TP_MERC =='BOLSA')|(is.na(df_info$TP_MERC)),]
df_info_bolsa <- df_info_bolsa[!is.na(df_info_bolsa$CD_CVM),]

df_info_bolsa$DT_REG <- as.Date(df_info_bolsa$DT_REG)
df_info_bolsa$DT_CANCEL <- as.Date(df_info_bolsa$DT_CANCEL)
df_info_bolsa$DT_CONST <- as.Date(df_info_bolsa$DT_CONST)

all_tickers_na <- table_code_cvm_tickers(df_info_bolsa)
all_tickers <- readRDS('Tickers/all_tickers_with_nas.rds')
all_tickers <- unique(all_tickers)
#saveRDS(all_tickers, 'Tickers/all_tickers_with_nas.rds')

#----------------------------------
#get data
price_dividend_data <- list()
tickers_length <- length( all_tickers$ticket)
count = 1
while (count <tickers_length){
  beging <- count
  if(beging+20 < tickers_length){count
    my_end = beging + 19
  }else{
    my_end = tickers_length
  }
  Sys.sleep(2)
  sub_price_dividend_data <- import_datas(tickers =paste0( all_tickers$ticket[beging:my_end], '.SA'), 
                                      first_date = Sys.Date()-4463,
                                      last_date = Sys.Date())
  
  price_dividend_data <- append(price_dividend_data, sub_price_dividend_data)
  count = count + 20
}
#price_dividend_data <- lapply(price_dividend_data, function(x){
#  colnames(x$price) <- gsub("df.tickers.","",colnames(x$price)) 
#  return(x)
#})
saveRDS(price_dividend_data,"price_dividend_data.rds")

price_dividend_data <- readRDS("price_dividend_data.rds")
price_dividend_data <- import_datas(tickers =paste0( all_tickers$ticket, '.SA'), 
             first_date = Sys.Date()-4447,
             last_date = Sys.Date())

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

parameter_min <- list(
  first_cash = 1000,
  contribution = 1000,
  highest_price = 100,
  max_allowed_percent_concentration = 0.12,
  max_allowed_sd = 1,
  max_allowed_var = 10,
  min_last_dividend_yield = 0.05,
  classification_criteria = 'var',
  percent_to_hold = 0.50,
  stop_gain_percent = 0.40,
  stop_loss_percent = -0.1,
  max_use_cash_percent = 0.9,
  exclude_tickers = c('MMAQ4.SA','BAZA3.SA'),
  percent_sample_size = 0.25
)
parameter_max <- list(
  first_cash = 1000, 
  contribution = 1000,
  highest_price = 100,
  max_allowed_percent_concentration = 0.12,
  max_allowed_sd = 3,
  max_allowed_var = 10,
  min_last_dividend_yield = 0.05,
  classification_criteria = 'var',
  percent_to_hold = 0.0,
  stop_gain_percent = 0.40,
  stop_loss_percent = -0.1,
  max_use_cash_percent = 0.9,
  exclude_tickers = c('MMAQ4.SA','BAZA3.SA'),
  percent_sample_size = 0.25
)
dynamic_parameter <- parameter
dynamic_parameter_min <- parameter_min
dynamic_parameter_max <- parameter_max
var_stock_portfolio = 0
var_stock_portfolio_min = 0
var_stock_portfolio_max = 0
parameter_list <- list(parameter             = parameter,
                       parameter_min         = parameter_min,
                       parameter_max         = parameter_max,
                       dynamic_parameter     = dynamic_parameter,
                       dynamic_parameter_min = dynamic_parameter_min,
                       dynamic_parameter_max = dynamic_parameter_max)

valid_dates <- valid_date_list(price_dividend_data = price_dividend_data)

first_date <- valid_dates[length(valid_dates)- 1849]# 2390 #4189  
last_date <- Sys.Date() #-528 
time_data_intervals_days <- 1000
time_gap_day <- 30
operation_day <- first_date
stocks_in_b3_list <- list()
stock_portfolio_list <- list()
stock_portfolio_min_list <- list()
stock_portfolio_max_list <- list()

while((operation_day < last_date)&!is.na(operation_day)){
  
  if(operation_day == first_date){
   
    table_trade <- create_table_trade()
    stock_portfolio <- list(Cash = parameter$first_cash, contribution = parameter$contribution)
    
    stocks_in_b3 <- df_info_bolsa[df_info_bolsa$DT_REG <= operation_day & (is.na(df_info_bolsa$DT_CANCEL)|df_info_bolsa$DT_CANCEL>operation_day),]
    stocks_in_b3 <- all_tickers[all_tickers$code %in% stocks_in_b3$CD_CVM,]
    stocks_in_b3$ticket  <- paste0(stocks_in_b3$ticket, '.SA')
    
  }else{
    print(1)
    new_stocks <- df_info_bolsa[df_info_bolsa$DT_REG <= operation_day & (is.na(df_info_bolsa$DT_CANCEL)|df_info_bolsa$DT_CANCEL>operation_day)& !(df_info_bolsa$CD_CVM %in% stocks_in_b3$code),]
    print(2)
    new_stocks <- all_tickers[all_tickers$code %in% new_stocks$CD_CVM,]
    print(3)
    if(nrow(new_stocks)!=0){
      print(4)
      new_stocks$ticket <- paste0(new_stocks$ticket, '.SA')
      print(4.1)
      stocks_in_b3 <- rbind(stocks_in_b3, new_stocks)#bind_cols(stocks_in_b3, new_stocks)
      print(4.2)
    }
    print(5)
    stocks_out_b3 <- df_info_bolsa[!(df_info_bolsa$DT_REG <= operation_day & (is.na(df_info_bolsa$DT_CANCEL)|df_info_bolsa$DT_CANCEL>operation_day))& df_info_bolsa$CD_CVM %in% stocks_in_b3$code,]
    print(6)
    step_stocks_in_b3 <- stocks_in_b3
    print(7)
    if(nrow(stocks_out_b3!=0)){
      print(8)
      stocks_in_b3 <- stocks_in_b3[!(stocks_in_b3$code %in% stocks_out_b3$CD_CVM),]
      print(8.1)
      #search if stocks portfolio are current in market
      if(!(length(which(names(stock_portfolio$stock) == stocks_out_b3$ticket)) == 0)){
        print(8.2)
        not_exist_filter <- names(stock_portfolio$stock) == stocks_out_b3$ticket
        print(8.3)
        stock_portfolio$stock[[not_exist_filter]] <- NULL
        print(8.4)
      }
      
    }
    print(9)
    stocks_out_b3 <-step_stocks_in_b3[step_stocks_in_b3$code %in% stocks_out_b3$CD_CVM,]
    print(10)
    rm(step_stocks_in_b3) 
    
    #put month cash
    stock_portfolio <- contribution(stock_portfolio = stock_portfolio, value_contribution = parameter$contribution)
    print(11)
  }
  

  print(12)
    operation <- mensal_and_daily_operations(stocks_in_b3 =stocks_in_b3$ticket[-which(stocks_in_b3$ticket %in% parameter$exclude_tickers)], 
                                             parameter = parameter,
                                             operation_day = operation_day,
                                             valid_dates = valid_dates,
                                             time_data_intervals_days = time_data_intervals_days,
                                             time_gap_day = time_gap_day,
                                             prices_dividends_data = price_dividend_data,
                                             stock_portfolio = stock_portfolio,
                                             table_trade = table_trade,
                                             )
    print(13)
    operation_day <- operation$operation_day
    stock_portfolio <- operation$stock_portfolio
    table_trade <- operation$table_trade
    my_table <- operation$my_table
    print(14)
    if(length(names(stock_portfolio$stock))>0){
      print(15)#problema ta aqui
      rebalance <- Rebalancing_stock_portfolio(stock_portfolio = stock_portfolio,
                                               price_dividend_data = price_dividend_data,
                                               table_trade = table_trade,
                                               parameter = parameter,
                                               operation_day = operation_day,
                                               my_table = my_table,
                                               rebalancing_look_count = parameter$rebalancing_look_count)
      print(16)
      stock_portfolio <- rebalance$stock_portfolio
      table_trade <- rebalance$table_trade
    }
    print(17)
    stock_portfolio_list <- append(stock_portfolio_list, operation$list_per_day_stock_portfolio)
   
    print(18)
    #backtest_stand <- view_data(table_trade = table_trade, stock_portfolio_list = stock_portfolio_list)
    print(19)
    #my_plot <- ggplot(data = backtest_stand$portfolio_datas, aes(x = dates, y = values_plus_cash ))
    
    #my_plot + geom_line(colour = 'Darkblue')
  
  'operation_day = operation_day + time_gap_day'
}

