import datetime

import yfinance as yf
import pandas as pd
#import datetime
#from datetime import datetime
import pytz
import get_prices
#import MetaTrader5 as mt5
import numpy as np
#from https://stackoverflow.com/questions/64814357/dividend-rates-and-dates-for-multiple-stocks-at-once-using-python
#from https://pypi.org/project/yfinance/
#stock_list = ['MXRF11', 'KISU11','HCTR11',"CPLE3","OIBR3",'PETR4']

#start = '2000-1-1'
#end = '2022-06-23'
def get_dividends_table(stock_list, start, end):
    data = pd.DataFrame()
    stock_list2 = [stock.replace(stock, stock+".SA") for stock in stock_list]
    for i in stock_list2:

        series = yf.Ticker(i).dividends.loc[start:end]
        data = pd.concat([data, series], axis=1)


    data.columns = stock_list
    return(data)

#timezone = pytz.timezone('America/Sao_Paulo')
# create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset

#utc_from =pd.to_datetime(pd.DataFrame({'year':[2021],'month':[6],'day':[1]}))[0]
#utc_to = pd.to_datetime(pd.DataFrame({'year':[2022],'month':[6],'day':[25]}))[0]

#my_dict = get_prices.get_prices(['CPLE3','CMIG4','SULA4','BBDC3','OIBR3','BBAS3','BBSE3','ITSA4','REDE3','PETR4' ],utc_from, utc_to)

def dividend_analysis(list_df_ticks_prices, which_price, start, end):
    div = pd.DataFrame()
    df_dividends = get_dividends_table(list_df_ticks_prices.keys() ,start, end)
    dividends_yealds = []

    for tick in list_df_ticks_prices.keys():
        tick_prices = list_df_ticks_prices[tick]
        tick_dividends = df_dividends[tick].dropna()
        last_price = tick_prices.tail(1)
        last_dividend_date = pd.to_datetime(tick_dividends.index)

        if(len(last_dividend_date)>0):

            tick_prices_filtered = tick_prices[(tick_prices['time'] > last_dividend_date[-1]) & (
                        tick_prices['time'] < last_dividend_date[-1] + pd.tseries.offsets.Day())]

            mean_price_in_dividend_data = pd.DataFrame.mean(tick_prices_filtered[which_price])
            sum_one_year_dividend = pd.DataFrame.sum(
                tick_dividends.loc[(tick_dividends.index >= (datetime.datetime.today() - 365 * pd.tseries.offsets.Day()))&(tick_dividends.index <= datetime.datetime.today())])

            like_unit_dividend_yeald = float(tick_dividends.tail(1)[0]/last_price[which_price])
            last_unit_dividend_yeald = float(tick_dividends.tail(1)[0]/mean_price_in_dividend_data)
            like_year_dividend_yeald = float(sum_one_year_dividend/last_price[which_price])
            my_row ={'last_price': float(last_price[which_price]),
                    'like_unit_dividend_yeald':like_unit_dividend_yeald,
                     'last_unit_dividend_yeald':last_unit_dividend_yeald,
                     'like_year_dividend_yeald':like_year_dividend_yeald}

        else:
            my_row = {'last_price': float(last_price[which_price]),
                    'like_unit_dividend_yeald': 0,
                      'last_unit_dividend_yeald': 0,
                      'like_year_dividend_yeald': 0}

        my_row2 = pd.Series(data=my_row, index=my_row.keys())
        my_row2.columns = tick
        div = pd.concat([div,pd.Series(data= my_row2, index= my_row.keys())], axis=1 )

    div.columns = list_df_ticks_prices.keys()
    return div.T

#test = dividend_analysis(my_dict,'last', utc_from, utc_to)
#pd.set_option('display.max_columns', 500) # number of columns to be displayed
#pd.set_option('display.width', 1500)      # max table width to display
