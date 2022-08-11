import MetaTrader5 as mt5
from datetime import datetime
# import pytz module for working with time zone
import pytz
import pandas as pd
import linear_regression
#print( pytz.all_timezones)
if not mt5.initialize(login=90404218, password="MThs@&04@@", server="OramaDTVM-Server" ):
#if not mt5.initialize(login=404218, password="C2a5p27", server="OramaDTVM-Server" ):
    print("initialize() failed, error code =", mt5.last_error())
    quit()


pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500)      # max table width to display
print(f'price = {mt5.symbol_info("GEPA4F")}')
request = {'action': mt5.TRADE_ACTION_DEAL, 'symbol': 'CPLE3F', 'volume': 1848.00,
           'type': mt5.ORDER_TYPE_BUY, 'price': 6.62, 'sl': 6.42, 'tp': 7.02,
           'deviation': 10, 'magic': 814495841500382457,
           'comment': 'sent by python', 'type_time': mt5.ORDER_TIME_GTC, 'type_filling': mt5.ORDER_FILLING_RETURN,}
#result = mt5.order_send(request)
# check the execution result
#print("1. order_send(): by {} {} lots at {} with deviation={} points".format(symbol, lot, price, deviation));
print(f'result = {result}')
if result.retcode != mt5.TRADE_RETCODE_DONE:
    print("2. order_send failed, retcode={}".format(result.retcode))
    # request the result as a dictionary and display it element by element
    result_dict = result._asdict()
    for field in result_dict.keys():
        print("   {}={}".format(field, result_dict[field]))
        # if this is a trading request structure, display it element by element as well
        if field == "request":
            traderequest_dict = result_dict[field]._asdict()
            for tradereq_filed in traderequest_dict:
                print("       traderequest: {}={}".format(tradereq_filed, traderequest_dict[tradereq_filed]))
    print("shutdown() and quit")
    mt5.shutdown()
    quit()

print("2. order_send done, ", result)
print("   opened position with POSITION_TICKET={}".format(result.order))
print("   sleep 2 seconds before closing position #{}".format(result.order))

#shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
