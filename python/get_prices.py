import MetaTrader5 as mt5
import pytz
import pandas as pd
from datetime import datetime
import numpy as np
import yfinance as yf
#falta arranjar forma de estocar os preços em sql
# logo, por enquanto utilizar datas curtas, para que ao tentar importa os dados, não tenha eles mais de 10 milhões de linhas
def get_prices(list_symbols,utc_from, utc_to ):
    import MetaTrader5 as mt5
    import pytz
    import pandas as pd
    from datetime import datetime
    import numpy as np

    dict_df = {}

#    if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ):
#        print("initialize() failed, error code =", mt5.last_error())
#        quit()

    for symbol in list_symbols:
        #print(symbol)
        symbol_info = mt5.symbol_info(str(symbol))

        if symbol_info is None:
            print(symbol, "not found, can not call order_check()")
            mt5.shutdown()
            quit()

        # if the symbol is unavailable in MarketWatch, add it
     #   if not symbol_info.visible:
     #       print(symbol, "is not visible, trying to switch on")
     #       if not mt5.symbol_select(symbol, True):
     #           print("symbol_select({}}) failed, exit", symbol)
     #           mt5.shutdown()
     #           quit()


        ticks = mt5.copy_ticks_range(symbol, utc_from, utc_to, mt5.COPY_TICKS_ALL)
        #nrow = len(ticks)

        # create DataFrame out of the obtained data
        df_ticks = pd.DataFrame(ticks)

        # convert time in seconds into the datetime format
        df_ticks['time'] = pd.to_datetime(df_ticks['time'], unit='s' )
        df_ticks['bid'] = df_ticks['bid'].round(2)
        df_ticks['ask'] = df_ticks['ask'].round(2)
        df_ticks['last'] = df_ticks['last'].round(2)
        dict_df[symbol] = df_ticks.dropna()

    #mt5.shutdown()
    return(dict_df)

def get_prices_filter_by_date(dict_df, date_from, date_to):

    dict_df_filtered = {}
    for symbol in dict_df.keys():
        dict_df_filtered[symbol] = dict_df[symbol][(dict_df[symbol]['time']>date_from)&(dict_df[symbol]['time']<date_to)]

    return dict_df_filtered

def get_prices_yahoo(list_symbols):
    list_symbols2 = [stock.replace(stock, stock + ".SA") for stock in list_symbols]
    dict_df_yahoo = {}
    for my_index in range(len(list_symbols2)):
        dict_df_yahoo[list_symbols[my_index]] =yf.Ticker(list_symbols2[my_index]).history(period = 'max')



    return dict_df_yahoo
#timezone = pytz.timezone('America/Sao_Paulo')
#= create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset
#utc_from = datetime(2022, 1, 1, tzinfo=timezone )
#utc_to = datetime(2022, 6, 24, tzinfo=timezone)
utc_from =pd.to_datetime(pd.DataFrame({'year':[2019],'month':[12],'day':[11]}))[0]
test =pd.to_datetime(pd.DataFrame({'year':[2002],'month':[6],'day':[23]}))[0]
utc_to = pd.to_datetime(pd.DataFrame({'year':[2019],'month':[12],'day':[25]}))[0]
if __name__ == '__main__':
    import MetaTrader5 as mt5
    if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ):

        print("initialize() failed, error code =", mt5.last_error())
        quit()

    my_dict = get_prices(['OIBR3', 'CPLE3'],datetime.now() - 3*pd.tseries.offsets.Day(), datetime.now())
    #my_filter_dict = get_prices_filter_by_date(my_dict,test,utc_to )
    pd.set_option('display.max_columns', 500) # number of columns to be displayed
    pd.set_option('display.width', 1500)      # max table width to display
    #my_dict = get_prices_yahoo(['OIBR3', 'CPLE3'])
    #print(my_dict['CPLE3']['Stock Splits'][my_dict['CPLE3']['Stock Splits']>0])
    #print('-----------------------------')
    #print(my_filter_dict['OIBR3'].tail())
#print(my_dict)