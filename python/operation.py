import carteira, get_dividends, get_prices, get_strategy_table, ordens,sql_functions, initialize_mt
import time
import pandas as pd, numpy as np
import datetime, holidays
import MetaTrader5 as mt5

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
tickers = list(sql_functions.get_table_as_pandas_df(connection,'''SELECT metatrader.symbol.symbol FROM metatrader.symbol;''', colnames=['symbols'])['symbols'])
for tick in ["KISU11","MXRF11","XPML11",'HCTR11','HGLG11', 'RBVA11', 'RCRB11','DEVA11']:
    tickers.remove(tick) #tickers com algum problema


percent_to_use_from_balance = 0.1
stop_gain = 0.03
stop_loss = 0.015

program_work = True

time_market_open = pd.Timestamp(datetime.datetime.today().strftime("%Y-%m-%d")+ "-10:10:00")
time_market_close = pd.Timestamp(datetime.datetime.today().strftime("%Y-%m-%d")+ "-17:30:00")
month_mark = time_market_open.month #vai ser usado para ver se houve alteração de mes na form de if assim:
data_from = datetime.datetime.today()- 100*pd.tseries.offsets.Day()
#data_to = datetime.datetime.today()
data_from_dividends =pd.to_datetime(pd.DataFrame({'year':[2000],'month':[1],'day':[1]}))[0]
sp_holidays =  holidays.Brazil(years=list(range (1900,datetime.datetime.now().year+1)), subdiv= "SP").items()

parameters = {'number_of_samples': 50000,
'sample_size' : 5,
'break_data_from_now_to': 1000,
'price_col_name': 'last',
'near_distance': 10000,
'middle_distance' : 100000,
'far_distance' : 1000000}
my_carteira = carteira.carteira()
isbacktest = False

while program_work == True:

    now_time = datetime.datetime.now()
    in_market_time = now_time > time_market_open and now_time < time_market_close

    if not in_market_time:
        program_work = False

    if program_work == True:
        data_to = datetime.datetime.now()

        print(f'passo 1')
        sql_functions.update_metatredar_table(connection, tickers, 'forward', sp_holidays,host_name, user_name, password, db_name)

        dict_df = sql_functions.get_prices_from_mysql(connection, tickers, first_date=data_from,
                                                      last_date=data_to)
        print(f'passo 2')
        #----------------
        #Colocar dividendo  do periodo (lembrar que operação deve ser compativel com intervalos de operação dentro de um dia
        # portanto, dever se evitado que o mesmo dividendo seja contado multiplasvvezes se for feita mais de uma operação no dia
        # se possivel, no futuro, impementar data de corte)

        if (len(my_carteira.carteira()) > 0):

            my_carteira.carteira_update(dict_df)

        strategic_table = get_strategy_table.strategy_table(dict_df, my_carteira,
                                                            data_from, data_to, data_from_dividends, parameters=parameters)
        print(f'passo 3')
        operation_tables = my_carteira.operation_prepare_table(strategic_table, isbacktest=isbacktest,
                                                               percent_to_use_from_balance = percent_to_use_from_balance, sl_points=stop_loss*2, tp_points=stop_gain*2, deviation=0.2)
        print(f'passo 4')
        operation_tables = operation_tables.T.to_dict()
        print(f'passo 5')
        for tick in list(operation_tables.keys()):
            if isbacktest ==False:
                operation = ordens.open_trade(action=operation_tables[tick]['action'],
                                              symbol=operation_tables[tick]['symbol'],
                                              lot = operation_tables[tick]['lot'],
                                              sl_points=operation_tables[tick]['sl_points'],
                                              tp_points = operation_tables[tick]['tp_points'],
                                              deviation = operation_tables[tick]['deviation'],
                                              magic=operation_tables[tick]['magic'] )
                my_carteira.operation(my_request=operation_tables[tick],operation_type = 'open')

            else:
                my_carteira.operation(my_request=operation_tables[tick])
        print(f'passo 6')
        table_operations_open = my_carteira.get_operation_table(dict_df, isbacktast= isbacktest)
        print(f'passo 7')
        if len(table_operations_open) > 0:
            # print("aqui------------------------")
            pd.set_option('display.max_columns', 500)  # number of columns to be displayed
            pd.set_option('display.width', 1500)  # max table width to display
            # print(my_carteira.carteira())
            # print("aqui------------------------")
            print(table_operations_open)
            if datetime.datetime.now().hour < time_market_close.hour:
                table_operations_to_close = table_operations_open[((table_operations_open[
                                                                        'price_change'] >= stop_gain) & (
                                                                               table_operations_open[
                                                                                   'type'] == mt5.ORDER_TYPE_BUY)) |
                                                                  ((table_operations_open[
                                                                        'price_change'] <= stop_loss) & (
                                                                               table_operations_open[
                                                                                   'type'] == mt5.ORDER_TYPE_SELL))]
            else:
                table_operations_to_close = table_operations_open

            #table_operations_to_close = table_operations_to_close.drop(labels=['today_price', 'price_change'], axis=1)
            table_operations_to_close.index = table_operations_to_close['magic']
            table_operations_to_close = table_operations_to_close.T.to_dict()
            for magic in list(table_operations_to_close.keys()):
                if isbacktest == False:

                    ordens.close_trade(action=table_operations_to_close[magic]['type'],
                                              symbol=table_operations_to_close[magic]['symbol'],
                                              lot = table_operations_to_close[magic]['volume'],
                                            identifier=table_operations_to_close[magic]['identifier'],
                                              deviation = round(table_operations_to_close[magic]['price_open']*0.2, 2),
                                              magic=table_operations_to_close[magic]['magic'])

                    my_carteira.operation(my_request=table_operations_to_close[magic], operation_type='close')


                else:

                    my_carteira.operation(my_request=table_operations_to_close[magic], operation_type='close')

        print("hour end")
        time.sleep(3600*30/60)
