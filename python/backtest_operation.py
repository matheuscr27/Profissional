import carteira, get_dividends, get_prices, get_strategy_table, ordens, initialize_mt
import time
import pandas as pd, numpy as np, datetime
import sql_functions
import mysql.connector

initialize_mt.initialize_mt5()
#if __name__ == '__main__':
#    import MetaTrader5 as mt5
#    if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ):
#        print("initialize() failed, error code =", mt5.last_error())
#        quit()

host_name = 'localhost'
user_name = 'root'
password = 'ojDPr&0AGZPmnrV'
db_name = 'MetaTrader'
connection = sql_functions.create_db_connection(host_name,user_name, password, db_name)

percent_to_use_from_balance = 0.8
month_contribution = 1000
stop_gain = 0.03
stop_loss = 0.015
time_market_open = pd.Timestamp(datetime.datetime.today().strftime("%Y-%m-%d")+ "-10:10:00")
time_market_close = pd.Timestamp(datetime.datetime.today().strftime("%Y-%m-%d")+ "-17:30:00")
max_hour_count = 5

program_work = True
month_mark = time_market_open.month #vai ser usado para ver se houve alteração de mes na form de if assim:
#data_from =pd.to_datetime(pd.DataFrame({'year':[2021],'month':[1],'day':[1]}))[0]
data_from = datetime.datetime.today()- 100*pd.tseries.offsets.Day()

#data_first_operation = pd.to_datetime(pd.DataFrame({'year':[2022],'month':[5],'day':[1]}))[0]
data_first_operation = datetime.datetime.today()- 20*pd.tseries.offsets.Day() - 8*pd.tseries.offsets.Hour()
data_in_backtest = data_first_operation
data_in_backtest_back = data_in_backtest - pd.tseries.offsets.Day()
while data_in_backtest_back.day_name() in ['Saturday', 'Sunday']:
    data_in_backtest_back = data_in_backtest_back - pd.tseries.offsets.Day()

#data_to = pd.to_datetime(pd.DataFrame({'year':[2022],'month':[7],'day':[2]}))[0]
data_to = datetime.datetime.today()

month_mark = data_first_operation.month
print(data_first_operation.day_name())
data_from_dividends =pd.to_datetime(pd.DataFrame({'year':[2000],'month':[1],'day':[1]}))[0]
#tickers = ['OIBR3','CPLE3','CMIG4']#,'SULA4','BBDC3','REDE3','BBAS3','BBSE3','ITSA4','PETR4' ]
tickers = list(sql_functions.get_table_as_pandas_df(connection, '''SELECT metatrader.symbol.symbol FROM metatrader.symbol;''',
                                 colnames=['symbols'])['symbols'])
#print(list(tickers['symbols']))
#dict_df = get_prices.get_prices(['OIBR3'], data_from, data_to)
for tick in ["KISU11","MXRF11","XPML11",'HCTR11','HGLG11', 'RBVA11', 'RCRB11','DEVA11']:
    tickers.remove(tick) #tickers com algum problema

dict_df = sql_functions.get_prices_from_mysql(connection,tickers,first_date= data_from,
                                last_date=data_to)

parameters = {'number_of_samples': 5000,
'sample_size' : 5,
'break_data_from_now_to': 1000,
'price_col_name': 'last',
'near_distance': 10000,
'middle_distance' : 100000,
'far_distance' : 1000000}
my_carteira = carteira.carteira()
my_carteira.backtest_balance_update(option="contribution", contribution= month_contribution)
isbacktest = True

#program_work = False

df_value_carteira_register = pd.DataFrame({'date':[],'balance':[],'stock_value_sum':[], 'value': []})
while program_work == True:
    hour_count = 0
    # ----------------
    # Colocar dividendo  do periodo (lembrar que operação deve ser compativel com intervalos de operação dentro de um dia
    # portanto, dever se evitado que o mesmo dividendo seja contado multiplasvvezes se for feita mais de uma operação no dia
    # se possivel, no futuro, impementar data de corte)
#lembrar de colocar condição 'se tiver elemento na carteira'
    #dividend_table = get_dividends.get_dividends_table(my_carteira.carteira().index, data_in_backtest_back, data_in_backtest_back)
    #if(len(dividend_table)!= 0):


    #-------------------------------------------------

    if data_in_backtest.month > month_mark:
        my_carteira.backtest_balance_update(option="contribution", contribution= month_contribution)
        month_mark = data_in_backtest.month


    #time.sleep(5)
    #now_time = datetime.now()
    #in_market_time = now_time > time_market_open and now_time < time_market_close

    #if not in_market_time:
    #    program_work = False

    if program_work == True:
        while hour_count <= max_hour_count:

            #print(f'date_from = {data_from}')
            print(f'date_to= {data_in_backtest + hour_count * pd.tseries.offsets.Hour()}')
            dict_df_filtered = get_prices.get_prices_filter_by_date(dict_df = dict_df, date_from=data_from, date_to=data_in_backtest + hour_count * pd.tseries.offsets.Hour())


            if(len(my_carteira.carteira())>0):
                #my_carteira.split_inplit(data_in_backtest)

                my_carteira.carteira_update(dict_df_filtered)
                #print(my_carteira.carteira())
            strategic_table = get_strategy_table.strategy_table(dict_df_filtered, my_carteira,
                                                                data_from, data_to, data_from_dividends, parameters=parameters)
            #print(f'strategic_table = {strategic_table}')

            operation_tables = my_carteira.operation_prepare_table(strategic_table, isbacktest=isbacktest,
                                                                   percent_to_use_from_balance = percent_to_use_from_balance, sl_points= stop_loss*2, tp_points= stop_gain*2, deviation=3)

            #print(f'operation_tables = {operation_tables}')
            operation_tables = operation_tables.T.to_dict()

            for tick in list(operation_tables.keys()):

                    my_carteira.operation(my_request=operation_tables[tick],operation_type = 'open')

            table_operations_open = my_carteira.get_operation_table(dict_df_filtered)

            if len(table_operations_open) > 0:

                #pd.set_option('display.max_columns', 500) # number of columns to be displayed
                #pd.set_option('display.width', 1500)      # max table width to display

                if hour_count < max_hour_count:
                    table_operations_to_close = table_operations_open[((table_operations_open['price_change']>=stop_gain) & (table_operations_open['action']==mt5.ORDER_TYPE_BUY)) |
                                                                      ((table_operations_open['price_change']<=stop_loss) & (table_operations_open['action']==mt5.ORDER_TYPE_SELL))]
                elif hour_count == max_hour_count:
                    table_operations_to_close = table_operations_open

                table_operations_to_close = table_operations_to_close.drop(labels = ['today_price', 'price_change'], axis=1)
                table_operations_to_close.index = table_operations_to_close['magic']
                table_operations_to_close = table_operations_to_close.T.to_dict()
                for magic in list(table_operations_to_close.keys()):

                        my_carteira.operation(my_request=table_operations_to_close[magic],operation_type = 'close')

                hour_count += 1

        #print("carteira_info = \n",my_carteira.carteira_info(isbacktest=True))

        df_value_carteira_register.loc[len(df_value_carteira_register)] = [data_in_backtest, my_carteira.backtest_balance, my_carteira.carteira_info(isbacktest=True).loc[28].at["value"],my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]]



    data_in_backtest_back = data_in_backtest
    data_in_backtest = data_in_backtest + pd.tseries.offsets.Day()
    while data_in_backtest.day_name() in ['Saturday', 'Sunday']:
        data_in_backtest = data_in_backtest + pd.tseries.offsets.Day()

    print(data_in_backtest)
    print(f'balance = {my_carteira.backtest_balance}')
    print(f'stock volume = {my_carteira.carteira_info(isbacktest=True).loc[28].at["value"]}')
    print(f'carteira total value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]}')
    #print(my_carteira.carteira())
    #print(my_carteira.get_operation_table(dict_df_filtered))
    #print(my_carteira.get_closed_operation_table())
    program_work = True if data_in_backtest < data_to else False

print(df_value_carteira_register)
print(my_carteira.carteira())
print(f''' operation_table open 
{my_carteira.get_operation_table(dict_df_filtered)}
operation_table close
{my_carteira.get_closed_operation_table()}''')