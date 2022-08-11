import yfinance as yf
import pandas as pd
#from https://stackoverflow.com/questions/64814357/dividend-rates-and-dates-for-multiple-stocks-at-once-using-python
#from https://pypi.org/project/yfinance/

start = '2022-1-1'
end = '2022-06-23'

def get_info_table(stock_list):
    stock_list2 = [stock.replace(stock, stock+".SA") for stock in stock_list]

    data = pd.DataFrame()
    for i in stock_list2:
        series = yf.Ticker(i).info #dividends.loc[start:end]
        df = pd.DataFrame(list(series.items()), columns=['property', 'value'])
        df.index = df['property']
        data = pd.concat([data, df['value']], axis=1)

    data.columns = stock_list
    return(data.T)

#my_stocks = ['MXRF11', 'KISU11','HCTR11',"CPLE3"]
#pd.set_option('display.max_columns', 500) # number of columns to be displayed
#pd.set_option('display.width', 1500)      # max table width to display
#print(get_info_table(my_stocks,start, end))