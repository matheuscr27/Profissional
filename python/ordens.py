import MetaTrader5 as mt5
#from https://stackoverflow.com/questions/60971841/how-close-an-mt5-order-from-python

ea_magic_number = 9986989 # if you want to give every bot a unique identifier

def get_info(symbol):
    '''https://www.mql5.com/en/docs/integration/python_metatrader5/mt5symbolinfo_py
    '''
    # get symbol properties
    info=mt5.symbol_info(symbol)
    return info

def open_trade(action, symbol, lot, sl_points, tp_points, deviation, magic):
    #https://www.mql5.com/en/docs/integration/python_metatrader5/mt5ordersend_py
    # prepare the buy request structure
    #symbol_info = get_info(symbol)

    if action == 0: #buy
    #    trade_type = mt5.ORDER_TYPE_BUY
        #print(f'symbol = {symbol + "F"}')
        try:
            price = mt5.symbol_info_tick(symbol + 'F').ask
            #print(f'price ask= {mt5.symbol_info_tick(symbol + "F").ask}')
        except:
            print('tick not match')
            return None

    elif action == 1:#sell
        #print(f'symbol = {symbol + "F"}')
        try:
            price = mt5.symbol_info_tick(symbol + 'F').bid
        except:
            print('tick not match')
            return None

     #   trade_type = mt5.ORDER_TYPE_SELL

    point = mt5.symbol_info(symbol).point


    open_request = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": symbol + 'F',
        "volume": lot,
        "type": action,
        "price": price,
        "sl": sl_points,
        "tp": tp_points,
        "deviation": deviation,
        "magic": magic,
        "comment": "sent by python",
        "type_time": mt5.ORDER_TIME_GTC, # good till cancelled
        "type_filling": mt5.ORDER_FILLING_RETURN,
    }
    print(open_request)
    # send a trading request
    result = mt5.order_send(open_request)

    return open_request

def close_trade(action, symbol, lot, identifier, deviation, magic):
    #'''https://www.mql5.com/en/docs/integration/python_metatrader5/mt5ordersend_py
    #my_stocks.loc[tick].at['amount']'''
    # create a close request
    #symbol = deals_table.loc[row_position].at['symbol']
    if action == 1: #if operation was sell them buy
        trade_type = mt5.ORDER_TYPE_BUY
        price = mt5.symbol_info_tick(symbol).ask
    elif action == 0: #if operation was buy them sell
        trade_type = mt5.ORDER_TYPE_SELL
        price = mt5.symbol_info_tick(symbol).bid

    #position_id=deals_table.loc[row_position].at['order']
    #lot = deals_table.loc[row_position].at['volume']

    close_request={
        "action": trade_type,
        "symbol": symbol + 'F',
        "volume": lot,
        "type": trade_type,
        "position": identifier,
        "price": price,
        "deviation": deviation,
        "magic": magic,
        "comment": "python script close",
        "type_time": mt5.ORDER_TIME_GTC, # good till cancelled
        "type_filling": mt5.ORDER_FILLING_RETURN,
    }
    # send a close request
    result=mt5.order_send(close_request)
    print(result)
    if result.retcode != mt5.TRADE_RETCODE_DONE:
        print("2. order_send failed, retcode={}".format(result.retcode))
    return close_request


