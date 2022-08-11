import time

import pandas as pd, numpy as np, get_prices
import MetaTrader5 as mt5
from datetime import datetime

#se amount estiver dando negativo, ver balance

def get_magic_number():
    import random
    #str(datetime.now().year) +
    #str(datetime.now().month) +
    var = int(
              str(datetime.now().day) +
              str(datetime.now().hour) +
              str(datetime.now().minute) +
              str(datetime.now().second) +
              str(datetime.now().microsecond)+
              str(random.randint(0,9))+str(random.randint(0,9))+str(random.randint(0,9))+str(random.randint(0,9))+str(random.randint(0,9)))
    return var

class carteira:
    import pandas as pd, numpy as np
    import MetaTrader5 as mt5

    def __init__(self):

        self.my_stocks = pd.DataFrame()

        self.table_operations = pd.DataFrame()

        self.table_close_operations = pd.DataFrame()

        self.backtest_balance = 0
        self.backtest_balance_alavancada = self.backtest_balance

    def carteira(self):
        try:
            x =self.my_stocks

            return x
        except:
            self.my_stocks = pd.DataFrame()

            return self.my_stocks
    def carteira_value(self, isbacktest):
        if isbacktest == True:
            balance = self.backtest_balance
        else:
            carteira_info = self.carteira_info()
            balance = float(carteira_info.loc[10].at['value'])

        return self.carteira()['volume'].sum() + balance

    def operation(self, my_request, operation_type):
        my_request['today_price'] = my_request['price']

        my_request['price_change'] = (my_request['today_price'] - my_request['price']) / my_request['price']

        operatio = pd.Series(data=my_request, index=my_request.keys())
        operatio = pd.DataFrame(data=operatio)
        operatio = operatio.T
        if operation_type == "open":
            self.table_operations = self.operation_table_add(operatio)
        elif operation_type =='close':
            self.table_operations, self.table_close_operations = self.operation_table_close(operatio)

        self.backtest_balance = self.backtest_balance_update(option = my_request['action'], operation=my_request, operation_type = operation_type)

        if operatio.loc[0].at["action"] ==mt5.ORDER_TYPE_BUY:
            operatio = operatio.drop(labels = ['action', 'today_price', 'price_change'], axis=1)
            #self.my_stocks = self.add_to_carteira(operatio)
            #return self.remove_from_carteira(operatio)
            self.my_stocks = self.add_to_carteira(operatio)
            return self.my_stocks
        elif operatio.loc[0].at['action'] ==mt5.ORDER_TYPE_SELL:
            operatio = operatio.drop(labels=['action', 'today_price', 'price_change'], axis=1)
            operatio['lot'] = -1*operatio['lot']
            self.my_stocks = self.add_to_carteira(operatio)
            return self.my_stocks


    def add_to_carteira(self, operation ):
        #print(operation.loc[0].at['tick'])
        tick = operation.loc[0].at['symbol']
        if operation.loc[0].at['symbol'] in self.my_stocks.index:

            #self.my_stocks.loc[tick].at['lot'] = self.my_stocks.loc[tick].at['lot'] + operation.loc[0].at['lot']
            #self.my_stocks.loc[tick].at['price'] = operation.loc[0].at['price']
            #self.my_stocks.loc[tick].at['volume'] = self.my_stocks.loc[tick].at['lot']* self.my_stocks.loc[tick].at['price']
            ##self.my_stocks = pd.concat(self.my_stocks, operation)
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"] = self.my_stocks.loc[
                                                                              self.my_stocks['symbol'] == tick, "lot"] + \
                                                                          operation.loc[0].at['lot']
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, "price"] = operation.loc[0].at['price']

            #self.carteira()['volume'] = self.carteira()['lot'] * self.carteira()['price']
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, 'volume'] = self.my_stocks.loc[self.my_stocks[
                                                                                                'symbol'] == tick, "price"] * \
                                                                         self.my_stocks.loc[
                                                                             self.my_stocks['symbol'] == tick, "lot"]

            if self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"][0] == 0:
                print('mudar')
                #self.my_stocks = self.my_stocks.drop(labels=tick, axis=0)
            #elif self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"][0] < 0:

            #    print('''O PROGRAMA ACERTOU!!!
            #            OPERAÇÃO ABERTA COMO SELL
            #             Quantidade menor que 0
    
            #             ''')
        else:
            try:

                self.my_stocks = pd.concat([self.my_stocks, operation], axis = 0)
                self.my_stocks.loc[self.my_stocks['symbol'] == tick, 'volume'] = self.my_stocks.loc[self.my_stocks[
                                                                                                        'symbol'] == tick, "price"] * \
                                                                                 self.my_stocks.loc[
                                                                                     self.my_stocks[
                                                                                         'symbol'] == tick, "lot"]
                #self.my_stocks = self.my_stocks.assign(
                #    volume=(operation.loc[0].at['lot'] * operation.loc[0].at['price']))

            except:
                print('AQUIIIII')
                self.my_stocks = pd.DataFrame()
                self.my_stocks = pd.concat([self.my_stocks, operation], axis = 0)
                self.my_stocks = self.my_stocks
        #try:

            #self.my_stocks.append(stock)
        #except:

            #self.my_stocks = [stock]
        self.my_stocks.index= self.my_stocks['symbol']
        return self.my_stocks

    def remove_from_carteira(self, operation):

        tick = operation.loc[0].at['symbol']
        if tick in self.my_stocks.index:

            #self.my_stocks.loc[tick].at['lot'] = float(self.my_stocks.loc[tick].at['lot']) - float(operation.loc[0].at['lot'])
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"] = self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"] - operation.loc[0].at['lot']
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, "price"] = operation.loc[0].at['price']
            #self.my_stocks.loc[tick].at['price']= float(operation.loc[0].at['price'])
            #self.my_stocks['price'][self.my_stocks['symbol'] ==tick] = operation.loc[0].at['price']
            #self.my_stocks.loc[tick].at['volume'] = self.my_stocks.loc[tick].at['lot'] * self.my_stocks.loc[tick].at['price']
            #self.my_stocks.loc[self.my_stocks['symbol'] == tick, "price"]
            #self.my_stocks['volume'][self.my_stocks['symbol'] == tick] = self.my_stocks.loc[tick].at['lot'] * self.my_stocks.loc[tick].at['price']
            self.my_stocks.loc[self.my_stocks['symbol'] == tick, 'volume'] = self.my_stocks.loc[self.my_stocks['symbol'] == tick, "price"]*self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"]
            if self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"][0] == 0:
                print('mudar')
                #self.my_stocks = self.my_stocks.drop(labels= tick, axis = 0)
            #elif self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"][0] < 0:

           #     print('''O PROGRAMA ACERTOU!!!
           #             programa foi aberto com sell
           #             Quantidade menor que 0
           #
           #             ''')


        else:
            print("Tick is not in carteira")

        self.my_stocks.index = self.my_stocks['symbol']
        return self.my_stocks

    def get_closed_operation_table(self):
        return self.table_close_operations

    def get_operation_table(self,dict_df, isbacktast):
        if not isbacktast:
            positions = mt5.positions_get()
            df = pd.DataFrame(list(positions), columns=positions[0]._asdict().keys())
            df = df.assign(price_change = df['profit']/df['volume'])
            return df
        if(len(self.carteira())>0):
            self.table_operations = self.operation_table_update(dict_df)
        return self.table_operations

    def operation_table_add(self, operation):

        self.table_operations = pd.concat([self.table_operations, operation], axis=0)
        return self.table_operations

    def operation_table_close(self, operation):
        row_operation = self.table_operations[self.table_operations['magic']==int(operation['magic'])]
        if(len(row_operation)>1):
            return 'Programa Bugou'

        row_operation = row_operation.assign(price_close = operation['price'])
        row_operation = row_operation.assign(price_change=(row_operation['price_close'] - row_operation['price'])/row_operation['price'])
        row_operation = row_operation.assign(result=row_operation['price_change']*row_operation['lot'])
        #print(f'row_operation = {row_operation}')
        #row_operation['price close'] = operation['price']
        #row_operation['price_change'] = (row_operation['price close'] - row_operation['price'])/row_operation['price']
        #row_operation['result'] = row_operation['price_change']*row_operation['amount']
        self.table_close_operations = pd.concat([self.table_close_operations,
                                                 row_operation],axis=0)

        self.table_operations = self.table_operations[self.table_operations['magic']!=int(operation['magic'])]
        return self.table_operations, self.table_close_operations

    def operation_table_update(self,dict_df):

        #self.table_operations['today_price'] = [float(dict_df[tick].tail(1)['last']) for tick in self.carteira()['symbol'] ]
        #self.table_operations['today_price'] = [float(self.carteira().loc[tick].at['price'])for tick in self.table_operations['symbol']]
        #self.table_operations['today_price'] = [self.carteira().loc[self.carteira()['symbol'] == tick, "price"][0] for tick in
        #                                        self.table_operations['symbol']]
        self.table_operations['today_price'] = [float(dict_df[tick].tail(1)['last']) for
                                                tick in
                                                self.table_operations['symbol']]
        #self.table_operations['today_price'] = [self.carteira().loc[self.carteira()['symbol'] == tick, "price"] for
        #                                        tick in
        #                                        self.table_operations['symbol']]

        #self.table_operations = pd.concat([self.table_operations, operation], axis=0)
        self.table_operations['price_change'] = [ (self.table_operations.iloc[my_index].at['today_price'] -  self.table_operations.iloc[my_index].at['price'])/self.table_operations.iloc[my_index].at['price'] for my_index in range(len(self.table_operations))]
        #self.table_operations['price_change'] = self.table_operations['price_change'].astype(float)
        return self.table_operations

    def operation_prepare_table(self, strategy_table, isbacktest, percent_to_use_from_balance, sl_points, tp_points, deviation):
        strategy_table = strategy_table.rename(columns = {'last_price': 'price'})
        buy_table  = strategy_table[strategy_table['buy_or_sell_or_statusquo'].isin(['buy'])]
        sell_table = strategy_table[strategy_table['buy_or_sell_or_statusquo'].isin(['sell'])]
        operations_buy  = pd.DataFrame()
        operations_sell = pd.DataFrame()
        if isbacktest == True:
            balance = self.backtest_balance
        else:
            carteira_info = self.carteira_info()
            balance = float(carteira_info.loc[10].at['value'])

        if(balance< 0):
            balance = 0

        if len(buy_table) >0:
            percent_to_use_from_balance = percent_to_use_from_balance*(1-(1/(len(buy_table)+1)) ) #+1 para a porcentagem não ser zerada
            percent_to_use_from_balance =round(percent_to_use_from_balance, 2)

            order_amount_invert = (buy_table['near_desviation'].abs())**(-1)#para compra mais as ações que estão perto de seu valor normal
            #print(f'order_amount_invert = {order_amount_invert}')
            proportions = order_amount_invert/order_amount_invert.sum()

            amoun_to_buy = pd.DataFrame(proportions*(balance*percent_to_use_from_balance)/buy_table['price'], columns=['lot'])
            #print(f'amoun_to_buy = {amoun_to_buy}')
            operations_buy = pd.concat([operations_buy,buy_table['symbol'],amoun_to_buy.apply(np.floor).astype(float),
                                        pd.DataFrame([mt5.ORDER_TYPE_BUY for my_index in range(len(amoun_to_buy))], columns= ['action'], index=amoun_to_buy.index),
                                        buy_table['price'],
                                        pd.DataFrame([round(buy_table.iloc[my_index].at['price']*(1 - sl_points),2) for my_index in range(len(amoun_to_buy))], columns= ['sl_points'], index=amoun_to_buy.index),
                                        pd.DataFrame([round(buy_table.iloc[my_index].at['price']*(1 + tp_points),2) for my_index in range(len(amoun_to_buy))], columns= ['tp_points'], index=amoun_to_buy.index),
                                        pd.DataFrame([round(buy_table.iloc[my_index].at['price']*deviation)  for my_index in range(len(amoun_to_buy))], columns= ['deviation'], index=amoun_to_buy.index),
                                        pd.DataFrame([get_magic_number() for my_index in range(len(amoun_to_buy))], columns= ['magic'], index=amoun_to_buy.index)],axis=1)


        if len(sell_table) > 0:
            #order_amount = (sell_table['near_desviation'].abs())#para vender mais as ações que estão distantes de seu valor normal
            #proportions = order_amount/ order_amount.sum()
            #amount_to_sell = pd.DataFrame(proportions*(self.carteira()[self.carteira()['symbol'].isin(sell_table.index)]['lot']), columns=['lot'])
            percent_to_use_from_balance = (1 - percent_to_use_from_balance) * (
                        1 - (1 / (len(sell_table) + 1)))  # +1 para a porcentagem não ser zerada
            percent_to_use_from_balance = round(percent_to_use_from_balance, 2)

            order_amount_invert = (sell_table['near_desviation'].abs()) ** (-1)  # para compra mais as ações que estão perto de seu valor normal
            # print(f'order_amount_invert = {order_amount_invert}')
            proportions = order_amount_invert / order_amount_invert.sum()

            amount_to_sell = pd.DataFrame(proportions * (balance * percent_to_use_from_balance) / sell_table['price'],
                                        columns=['lot'])

            operations_sell = pd.concat([operations_sell,sell_table['symbol'], amount_to_sell.apply(np.floor).astype(float),
                                        pd.DataFrame([mt5.ORDER_TYPE_SELL for my_index in range(len(amount_to_sell))],
                                                     columns=['action'], index=amount_to_sell.index),
                                        sell_table['price'],
                                        pd.DataFrame([round(sell_table.iloc[my_index].at['price']*(1 - sl_points),2) for my_index in range(len(amount_to_sell))], columns= ['sl_points'], index=amount_to_sell.index),
                                        pd.DataFrame([round(sell_table.iloc[my_index].at['price']*(1 + tp_points),2) for my_index in range(len(amount_to_sell))], columns= ['tp_points'], index=amount_to_sell.index),
                                        pd.DataFrame([round(sell_table.iloc[my_index].at['price']*deviation) for my_index in range(len(amount_to_sell))], columns= ['deviation'], index=amount_to_sell.index),
                                        pd.DataFrame([get_magic_number() for my_index in range(len(amount_to_sell))], columns= ['magic'], index=amount_to_sell.index)], axis=1)

        return(pd.concat([operations_buy,operations_sell], axis=0))

    def position_table(self):

        positions_total = self.mt5.positions_get()

        # positions_total['time_update'] = pd.to_datetime(positions_total['time_update'], unit='s')
        # positions_total['time_update_msc=1656515860711'] = pd.to_datetime(positions_total['time_update_msc=1656515860711'], unit='s')
        if len(positions_total) > 0:

            df = pd.DataFrame(list(positions_total), columns=positions_total[0]._asdict().keys())
            # df.drop(['time_expiration','type_time','state','position_by_id','reason','volume_current','price_stoplimit','sl','tp'], axis=1, inplace=True)
            df['time'] = pd.to_datetime(df['time'], unit='s')
            # df['time_msc'] = pd.to_datetime(df['time_msc'], unit='s')
            df['time_update'] = pd.to_datetime(df['time_update'], unit='s')
            # df['time_update_msc'] = pd.to_datetime(df['time_update_msc'], unit='s')

            return(df)
        else:
            return("Positions not found")

    def get_deals(self):
        # get deals for symbols whose names contain neither "EUR" nor "GBP"
        from_date = datetime(1980, 1, 1)
        to_date = datetime.now()
        deals = self.mt5.history_deals_get(from_date, to_date)
        if deals == None:
            return("No deals, error code={}".format(mt5.last_error()))
        elif len(deals) > 0:
            # display these deals as a table using pandas.DataFrame
            df = pd.DataFrame(list(deals), columns=deals[0]._asdict().keys())
            df['time'] = pd.to_datetime(df['time'], unit='s')
            return(df)

    def carteira_info(self):

        #if isbacktest == True:
            #balance = self.backtest_balance
        #else:
            #carteira_info = self.carteira_info(isbacktest=isbacktest)
            #balance = 0#float(carteira_info.loc[10].at['value'])

        #deals = self.get_deals()

        #cash = round(deals[deals['type'] == 2]['profit'].sum(),2)
        #cash = round(deals['profit'].sum(),2)
        if(len(self.carteira())>0):
            volume = self.carteira()['lot'] *self.carteira()['price']
            #in_stock_value = round(volume.sum(),2) if "volume" in self.carteira().index else 0
            in_stock_value = round(volume.sum(),2)
        else:
            in_stock_value = 0

        account_info = mt5.account_info()
        if account_info != None:
            # display trading account data 'as is'

            # display trading account data in the form of a dictionary

            account_info_dict = mt5.account_info()._asdict()
            account_info_dict['in_stock_value'] = in_stock_value
            account_info_dict['total_value'] = account_info_dict['balance'] + account_info_dict['in_stock_value']


            # convert the dictionary into DataFrame and print
            df = pd.DataFrame(list(account_info_dict.items()), columns=['property', 'value'])

            return df

    def carteira_update(self, dict_df):

        self.carteira()['price'] = [float(dict_df[tick].tail(1)['last']) for tick in self.carteira()['symbol'] ]
        self.carteira()['volume'] = self.carteira()['lot'] *self.carteira()['price']
        return self.carteira()
    def backtest_balance(self):

        return self.backtest_balance

    def backtest_balance_update(self, option, operation = None, contribution = None, dividend = None, operation_type = None):

        if option == mt5.ORDER_TYPE_BUY:

            self.backtest_balance = self.backtest_balance - (operation['lot']*operation['price'])

        elif option == mt5.ORDER_TYPE_SELL:
            #if operation_type == 'open':
            #    self.backtest_balance = self.backtest_balance - (operation['lot'] * operation['price'])
            #elif operation_type == 'close':
            self.backtest_balance = self.backtest_balance +  (operation['lot']*operation['price'])



        elif  option == 'contribution':
            self.backtest_balance = self.backtest_balance + contribution

        elif option == 'dividend':
            self.backtest_balance = self.backtest_balance + dividend

        return self.backtest_balance

    def split_inplit(self, my_date):
        my_dict = get_prices.get_prices_yahoo(self.carteira()['symbol'])
        for symbol in self.carteira()['symbol']:
            date_splits_implits =my_dict[symbol]['Date'][my_dict[symbol]['Stock Splits'] > 0]
            if my_date in date_splits_implits:
                self.my_stocks.loc[self.my_stocks['symbol'] == tick, "lot"] = self.my_stocks.loc[
                    self.my_stocks['symbol'] == tick, "lot"]*date_splits_implits[date_splits_implits['Date']==my_date, 'Stock Splits']
            #vai dar problema na hora pois vai ter quantidades que vão virar float
            #ver se as datas serao compativeis para tertar se esta no dia
        return self.my_stocks()


if __name__ == '__main__':
    operation1 = {'symbol': "OIBR3",
                  'type': mt5.ORDER_TYPE_BUY,
                  'price': 0.5,
                  'lot': 100,
                  'magic': 1}
    operation2 = {'symbol': "CPLE3",
                  'type': mt5.ORDER_TYPE_BUY,
                  'price': 30,
                  'lot': 100,
                  'magic': 2}
    operation3 = {'symbol': "CPLE3",
                  'type': mt5.ORDER_TYPE_SELL,
                  'price': 31,
                  'lot': 100,
                  'magic': 2}
    pd.set_option('display.max_columns', 500) # number of columns to be displayed
    pd.set_option('display.width', 1500)
    if not mt5.initialize(login=404218, password="C2a5p27", server="OramaDTVM-Server" ):
        print("initialize() failed, error code =", mt5.last_error())
        quit()


    #print(operation1['price'])
    #operation1 = pd.Series(data = operation1, index= operation1.keys())
    #print(operation1['operation type'])
    test = carteira()
    print(f"balance = ",test.backtest_balance)
    test.backtest_balance_update(option = 'contribution', contribution= 10000)
    print(f"balance = ", test.backtest_balance)

    test.operation(my_request= operation1 , operation_type="open")
    test.backtest_balance_update(option=operation1['type'], operation=operation1)
    print(f"balance = ", test.backtest_balance)
    #print(f'carteira_value = {test.carteira_info(isbacktest=True)} ')
    print(f'carteira_value = {test.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    #print(test.stocks())
    test.operation(my_request=operation2, operation_type="open")
    test.backtest_balance_update(option=operation2['type'], operation=operation2)
    print(f"balance = ", test.backtest_balance)
    print(f'carteira_value = {test.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    #print(test.stocks())
    test.operation(my_request= operation1, operation_type="open")
    test.backtest_balance_update(option=operation2['type'], operation=operation1)
    print(f"balance = ", test.backtest_balance)
    print(f'carteira_value = {test.carteira_info(isbacktest=True).loc[29].at["value"]} ')
    #print(test.stocks())
    test.operation(my_request=operation3, operation_type="close")
    test.backtest_balance_update(option=operation3['type'], operation=operation3)
    print(f"balance = ", test.backtest_balance)

    #print(test.carteira())
    #print(test.carteira().index)
    #print(test.get_operation_table())

    #print(test.get_deals())

    #print(test.carteira_info())

    utc_from = pd.to_datetime(pd.DataFrame({'year': [2022], 'month': [3], 'day': [1]}))[0]
    utc_to = pd.to_datetime(pd.DataFrame({'year':[2022],'month':[6],'day':[25]}))[0]

    dict_df = get_prices.get_prices(['OIBR3', 'CPLE3'], utc_from, utc_to)
    print(f"carteira = \n{test.carteira()}")
    print('-----------------------------------')
    print(test.carteira_update(dict_df))
    print('-----------------------------------')
    print(test.get_operation_table())
    print('-----------------------------------')
    print(test.get_closed_operation_table())
    print(test.operation_table_update())
    #test.carteira_update(dict_df)
    #print(test.carteira())
    #print(test.carteira_info())



    print(get_magic_number())
    mt5.shutdown()






