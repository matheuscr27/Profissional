import MetaTrader5 as mt5
import time
from time import localtime, strftime
from datetime import datetime
# import pytz module for working with time zone
import pytz
import pandas as pd
import linear_regression
#about magic number https://www.mql5.com/en/articles/1359

#if not mt5.initialize(login=90404218, password="MThs@&04@@", server="mt5.orama.com.br:443" ):
if not mt5.initialize(login=404218, password="C2a5p27", server="mt5.orama.com.br:443" ):
    print("initialize() failed, error code =", mt5.last_error())
    quit()

symbol = "OIBR3"
symbol_info = mt5.symbol_info(symbol)

if symbol_info is None:
    print(symbol, "not found, can not call order_check()")
    mt5.shutdown()
    quit()

# if the symbol is unavailable in MarketWatch, add it
if not symbol_info.visible:
    print(symbol, "is not visible, trying to switch on")
    if not mt5.symbol_select(symbol, True):
        print("symbol_select({}}) failed, exit", symbol)
        mt5.shutdown()
        quit()

lot = 200.0
point = mt5.symbol_info(symbol).point
price = mt5.symbol_info_tick(symbol).last
deviation = 20

time_market_open = pd.Timestamp(datetime.today().strftime("%Y-%m-%d")+ "-10:10:00")
time_market_close = pd.Timestamp(datetime.today().strftime("%Y-%m-%d")+ "-17:30:00")

program_work = True
while program_work == True:
    now_time = datetime.now()

    in_market_time = now_time > time_market_open and now_time < time_market_close

    if not in_market_time:

        program_work = False

    if mt5.symbol_info(symbol).last >=0.70 and program_work == True:

        print(f"Sell for  {price}")

        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": lot,
            "type": mt5.ORDER_TYPE_SELL,
            "price": price,
            #'"sl": round(price * 0.7, 2),
            #'"tp": round(price * 1.3, 2),
            "deviation": deviation,
            "magic": 234000,
            "comment": "python script close",
            "type_time": mt5.ORDER_TIME_GTC,
            "type_filling": mt5.ORDER_FILLING_RETURN,
        }

        # send a trading request
        result = mt5.order_send(request)
        print(result)
        # check the execution result
        if result.retcode != mt5.TRADE_RETCODE_DONE:
            print("4. order_send failed, retcode={}".format(result.retcode))
            print("   result", result)
        else:
            #print("4. position #{} closed, {}".format(position_id, result))
            # request the result as a dictionary and display it element by element
            result_dict = result._asdict()
            for field in result_dict.keys():
                print("   {}={}".format(field, result_dict[field]))
                # if this is a trading request structure, display it element by element as well
                if field == "request":
                    traderequest_dict = result_dict[field]._asdict()
                    for tradereq_filed in traderequest_dict:
                        print("       traderequest: {}={}".format(tradereq_filed, traderequest_dict[tradereq_filed]))
        program_work = False
    time.sleep(10)

mt5.shutdown()
