


import get_prices, get_dividends, statistic_analysis, tick_info, carteira
import datetime
import pytz
import pandas as pd

def strategy_table(my_dict, my_carteira, data_from, data_to, data_from_dividends, parameters):

    my_dict_prepared, statistic_table = statistic_analysis.statistic_table(my_dict, parameters['price_col_name'],
                                                         parameters['number_of_samples'],
                                                         parameters['sample_size'],
                                                         parameters['break_data_from_now_to'],
                                                         parameters['near_distance'], parameters['middle_distance'],
                                                         parameters['far_distance'])

    dividends_yield_table = get_dividends.dividend_analysis(my_dict_prepared,parameters['price_col_name'], data_from_dividends, data_to)


    tick_info_table = tick_info.get_info_table(my_dict_prepared.keys())
    #tick_info_table = tick_info_table[['ebitdaMargins', 'profitMargins',]]

    my_table = pd.concat([dividends_yield_table, statistic_table], axis = 1)
    my_table['symbol']= my_table.index

    #pd.set_option('display.max_columns', 500) # number of columns to be displayed
    #pd.set_option('display.width', 1500)      # max table width to display
    #my_table['buy_or_sell_or_statusquo'] = ['buy' if ((my_table.loc[my_index].at['near_slope']>0)&(my_table.loc[my_index].at['middle_slope']>0)) else
           #'sell'if (((my_table.loc[my_index].at['near_slope']<0)&(my_table.loc[my_index].at['middle_slope']<0)&(my_table.loc[my_index].at['symbol'] in my_carteira.carteira().index)) if len(my_carteira.carteira()) != 0 else
           # None) else
           #None
           #for my_index in my_table.index]
    my_table['buy_or_sell_or_statusquo'] = [
        'buy' if ((my_table.loc[my_index].at['near_slope'] > 0) & (my_table.loc[my_index].at['middle_slope'] > 0)) else
        'sell' if((my_table.loc[my_index].at['near_slope'] < 0) & (my_table.loc[my_index].at['middle_slope'] < 0)) else
        None
        for my_index in my_table.index]

    #my_table['buy_or_sell_or_statusquo'] = ['buy', 'sell','buy','buy', 'buy']

    return my_table
my_carteira = carteira.carteira()

if __name__ == '__main__':
    import MetaTrader5 as mt5
    if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ):
        print("initialize() failed, error code =", mt5.last_error())
        quit()
    parameters = {'number_of_samples': 50000,
    'sample_size' : 5,
    'break_data_from_now_to': 1000,
    'price_col_name': 'last',
    'near_distance': 10000,
    'middle_distance' : 100000,
    'far_distance' : 1000000}

    timezone = pytz.timezone('America/Sao_Paulo')
    # create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset

    data_from =pd.to_datetime(pd.DataFrame({'year':[2022],'month':[3],'day':[25]}))[0]
    data_to = pd.to_datetime(pd.DataFrame({'year':[2022],'month':[6],'day':[27]}))[0]
    data_from_dividends =pd.to_datetime(pd.DataFrame({'year':[2000],'month':[1],'day':[1]}))[0]

    ticks = ['OIBR3','CPLE3','CMIG4','SULA4','BBDC3']#,'BBAS3','BBSE3','ITSA4','REDE3','PETR4' ]
    my_dict = get_prices.get_prices(ticks,data_from, data_to)

    pd.set_option('display.max_columns', 500) # number of columns to be displayed
    pd.set_option('display.width', 1500)      # max table width to display
    strat = strategy_table(my_dict, my_carteira, data_from, data_to, data_from_dividends, parameters)
    #print(strat)
    #print(strat['last_price'])
    #print(len(my_carteira.carteira()))
    operation1 = {'symbol':"OIBR3",
                      'type': mt5.ORDER_TYPE_BUY,
                        'price':0.5,
                        'lot':100,
                        'magic': 1}
    operation2 = {'symbol':"CPLE3",
                      'type': mt5.ORDER_TYPE_BUY,
                        'price':30,
                        'lot':100,
                        'magic':2}
    operation3 = {'symbol': "CPLE3",
                  'type': mt5.ORDER_TYPE_SELL,
                  'price': 31,
                  'lot': 100,
                  'magic':2}

    my_carteira.backtest_balance_update(option="contribution", contribution=10000)
    my_carteira.operation(my_request= operation1, operation_type='open')

    print(f'carteira_value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    my_carteira.operation(my_request=operation2, operation_type='open')
    print(f'carteira_value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    my_carteira.operation(my_request=operation3, operation_type='close')
    print(f'carteira_value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    #print(my_carteira.carteira())
    print(f'carteira_value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    table = my_carteira.operation_prepare_table(strat, isbacktest=True, percent_to_use_from_balance= 0.8, sl_points=1, tp_points=2, deviation=3)
    #print(table)
    test =table.T.to_dict()

    my_carteira.carteira_update(my_dict)
    my_carteira.operation_table_update()
    my_carteira.get_operation_table()
    my_carteira.get_closed_operation_table()
    print(my_carteira.carteira())
    print(my_carteira.backtest_balance)
    print(f'carteira_value = {my_carteira.carteira_info(isbacktest=True).loc[29].at["value"]} ')