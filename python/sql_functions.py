
import pandas as pd
#from pandasql import sqldf

import mysql.connector
from mysql.connector import Error
from sqlalchemy import create_engine
import get_prices, initialize_mt
import datetime
import holidays
#https://www.freecodecamp.org/portuguese/news/como-criar-e-manipular-bancos-de-dados-sql-com-python/
#pip install mysql-connector-python

def create_server_connection(host_name, user_name, user_password):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password
        )
        print("MySQL Database connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection
def create_server_connection_form_sqlalchemy(host_name, user_name, user_password):
    connection = None
    sqlEngine = create_engine(f'mysql://{user_name}:{user_password}@{host_name}:3306/metatrader')


    try:
        connection = sqlEngine.connect()#https://docs.sqlalchemy.org/en/14/core/engines.html

        print("MySQL Database connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection

def create_database(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        print("Database created successfully")
    except Error as err:
        print(f"Error: '{err}'")

def create_db_connection(host_name, user_name, user_password, db_name):

    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("MySQL Database connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection

def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        #print("Query successful")
    except Error as err:
        print(f"Error: '{err}'")


def read_query(connection, query):
    connection.reconnect()
    cursor = connection.cursor()

    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except Error as err:
        print(f"Error: '{err}'")

def get_col_values(connection,query):
    results = read_query(connection, query)
    from_db = []
    for result in results:
        result = result
        from_db.append(result[0])
    return from_db

def get_table_as_pandas_df(connection,query, colnames):
    results = read_query(connection, query)
    from_db = []
    for result in results:
        result = list(result)
        from_db.append(result)
    df = pd.DataFrame(from_db, columns = colnames)
    return df

create_price_table = """
CREATE TABLE price (
price_id INT PRIMARY KEY,
price FLOAT
);
"""
create_symbol_table = """
CREATE TABLE symbol(
symbol_id INT PRIMARY KEY,
symbol VARCHAR(40)
);
"""
create_volume_table = """
CREATE TABLE volume(
volume_id INT PRIMARY KEY,
volume INT 
);
"""
create_time_table = """
CREATE TABLE time(
time_id INT PRIMARY KEY,
time TIMESTAMP
);
"""
create_flags_table = """
CREATE TABLE flags(
flags_id INT PRIMARY KEY,
flags INT
);
"""
create_time_msc_table = """
CREATE TABLE time_msc(
time_msc_id INT PRIMARY KEY,
time_msc VARCHAR(40)
);
"""
create_ticks_table = """
CREATE TABLE ticks (
tick_id INT PRIMARY KEY,
symbol INT,
time INT,
bid INT,
ask INT,
last INT,
volume INT,
time_msc INT,
flags INT,
volume_real INT
);
"""
create_temp_ticks_table = """
CREATE TABLE temp_ticks (
time TIMESTAMP,
bid FLOAT,
ask FLOAT,
last FLOAT,
volume mediumint,
time_msc VARCHAR(40),
flags mediumint,
volume_real mediumint
);
"""

drop_temp_ticks_table = """DROP TABLE temp_ticks;"""

def relacionamentos (table, foreign_col, ref_col):
    my_text = falter_participant = f"""
ALTER TABLE {table}
ADD FOREIGN KEY({foreign_col})
REFERENCES {ref_col}({ref_col}_id)
ON DELETE SET NULL;
"""
    return my_text

def get_id(connection, my_object, table_name):

    my_list = get_col_values(connection, 'SELECT '+table_name+' FROM '+ table_name )

    if my_object in my_list:
        tick_id = my_list.index(my_object) +1

    else:
        tick_id = len(my_list) + 1
        execute_query(connection, f'INSERT INTO {table_name} Values ({tick_id}, "{my_object}")')#ATENCAO AQUI PODE DAR BUG
    return tick_id


def update_index(connection,my_df, my_col, my_mysql_base):
    my_sub_df = get_table_as_pandas_df(connection, f"""
        SELECT * FROM metatrader.{my_mysql_base};""", colnames=[my_mysql_base + "_id", my_mysql_base])

    vector_filtered = pd.unique(
        my_df[my_col][(my_df[my_col + '_id'].isnull()) & (~my_df[my_col].isin(my_sub_df[my_mysql_base]))])

    if len(vector_filtered) > 0:
        my_tick_table_len = len(get_col_values(connection, f'SELECT * FROM metatrader.{my_mysql_base}'))
        # print(range(len(vector_filtered)))
        new_vector = ["('" + str(x + my_tick_table_len + 1) + "', '" + str(vector_filtered[x]) + "')" for x in
                      range(len(vector_filtered))]
        # new_vector = [str(my_text) for my_text in vector_filtered ]

        execute_query(connection, f'''INSERT INTO metatrader.{my_mysql_base} VALUES {", ".join(new_vector)};''')


def update_metatredar_table(connection,symbols,look, sp_holidays, host_name, user_name, user_password, db_name):
    initialize_mt.initialize_mt5()
    for symbol in symbols:

            #symbol_id = get_id(connection,symbol,'symbol')
            if look == 'forward':
                utc_from = read_query(connection, f"""SELECT MAX(metatrader.time.time)
                            FROM metatrader.ticks AS df
                            LEFT JOIN metatrader.symbol ON metatrader.symbol.symbol_id =df.symbol
                            LEFT JOIN metatrader.time ON metatrader.time.time_id =df.time
                            WHERE metatrader.symbol.symbol = '{symbol}'; """)[0][0]
                if utc_from == None:
                    utc_from = datetime.datetime.now() - pd.tseries.offsets.Day()

                utc_from = utc_from + pd.tseries.offsets.Second()
                utc_to = utc_from + pd.tseries.offsets.Day()

                while (utc_to.day_name() in ['Saturday', 'Sunday']) or (utc_to in sp_holidays):
                    utc_to = utc_to + pd.tseries.offsets.Day()

                if utc_to > datetime.datetime.now():
                    utc_to = datetime.datetime.now().today()


            elif look == 'backward':

                utc_to = read_query(connection, f"""SELECT MIN(metatrader.time.time)
                            FROM metatrader.ticks AS df
                            LEFT JOIN metatrader.symbol ON metatrader.symbol.symbol_id =df.symbol
                            LEFT JOIN metatrader.time ON metatrader.time.time_id =df.time
                            WHERE metatrader.symbol.symbol = '{symbol}'; """)[0][0]

                if utc_to == None:

                    utc_to = datetime.datetime.now()

                utc_to = utc_to - pd.tseries.offsets.Second()
                utc_from = utc_to - pd.tseries.offsets.Day()
                while (utc_from.day_name() in ['Saturday', 'Sunday']) or (utc_from in sp_holidays):
                    utc_from = utc_from - pd.tseries.offsets.Day()


            #print(f"symbol = {symbol}")
            #print(f'utc_from = {utc_from}')
            #print(f'utc_to = {utc_to}')
            my_prices = get_prices.get_prices([symbol], utc_from, utc_to)

            if  (look == 'backward') and (len(my_prices[symbol]) == 0):
                while len(my_prices[symbol]) == 0:
                    utc_from = utc_from - pd.tseries.offsets.Day()
                    my_prices = get_prices.get_prices([symbol], utc_from, utc_to)
            #execute_query(connection, create_temp_ticks_table)

            my_prices[symbol]['volume'] = my_prices[symbol]['volume'].astype('uint32')
            my_prices[symbol]['volume_real'] = my_prices[symbol]['volume_real'].astype('uint32')
            my_prices[symbol]['flags'] = my_prices[symbol]['flags'].astype('uint32')

            connection_sqlalchemy = create_server_connection_form_sqlalchemy(host_name, user_name, user_password)

            my_prices[symbol].to_sql("temp_ticks", connection_sqlalchemy)
            connection_sqlalchemy.close()

            connection = create_db_connection(host_name, user_name, user_password, db_name)
            colnames = ['symbol', 'symbol_id','time', 'time_id', 'bid','bid_id', 'ask', 'ask_id', 'last', 'last_id',
                                          'volume', 'volume_id', 'time_msc', 'time_msc_id', 'flags','flags_id', 'volume_real','volume_real_id']

            table_with_index = get_table_as_pandas_df(connection, f"""
                SELECT distinct 
                "{symbol}", metatrader.symbol.symbol_id,
                temp_df.time, metatrader.time.time_id,
                ROUND(temp_df.bid, 2), bid.price_id,
                ROUND(temp_df.ask, 2), ask.price_id,
                ROUND(temp_df.last, 2), last.price_id,
                temp_df.volume, volume.volume_id,
                temp_df.time_msc, metatrader.time_msc.time_msc_id,
                temp_df.flags, metatrader.flags.flags_id,
                temp_df.volume_real, volume_real.volume_id
                 FROM metatrader.temp_ticks  AS temp_df
                 LEFT JOIN metatrader.symbol ON metatrader.symbol.symbol IN ("{symbol}")
                 LEFT JOIN metatrader.time ON metatrader.time.time  IN (temp_df.time)
                 LEFT JOIN metatrader.price as bid ON ROUND(bid.price, 2) IN(temp_df.bid)
                 LEFT JOIN metatrader.price as ask ON ROUND(ask.price, 2) IN(temp_df.ask)
                 LEFT JOIN metatrader.price as last ON ROUND(last.price, 2) IN(temp_df.last)
                 LEFT JOIN metatrader.volume as volume ON volume.volume IN(temp_df.volume)
                 LEFT JOIN metatrader.time_msc ON metatrader.time_msc.time_msc IN(temp_df.time_msc)
                 LEFT JOIN metatrader.flags ON metatrader.flags.flags IN(temp_df.flags)
                 LEFT JOIN metatrader.volume as volume_real ON volume_real.volume IN (temp_df.volume_real);
                """, colnames = colnames)

            update_index(connection,table_with_index, 'symbol', 'symbol')
            update_index(connection,table_with_index, 'time', 'time')
            update_index(connection,table_with_index, 'bid', 'price')
            update_index(connection,table_with_index, 'ask', 'price')
            update_index(connection,table_with_index, 'last', 'price')
            update_index(connection,table_with_index, 'volume', 'volume')
            update_index(connection,table_with_index, 'time_msc', 'time_msc')
            update_index(connection,table_with_index, 'flags', 'flags')
            update_index(connection,table_with_index, 'volume_real', 'volume')

            table_with_news_index = get_table_as_pandas_df(connection, f"""
                            SELECT distinct 
                            "{symbol}", metatrader.symbol.symbol_id,
                            temp_df.time, metatrader.time.time_id,
                            temp_df.bid, bid.price_id,
                            temp_df.ask, ask.price_id,
                            temp_df.last, last.price_id,
                            temp_df.volume, volume.volume_id,
                            temp_df.time_msc, metatrader.time_msc.time_msc_id,
                            temp_df.flags, metatrader.flags.flags_id,
                            temp_df.volume_real, volume_real.volume_id
                             FROM metatrader.temp_ticks  AS temp_df
                             LEFT JOIN metatrader.symbol ON metatrader.symbol.symbol IN ("{symbol}")
                             LEFT JOIN metatrader.time ON metatrader.time.time  IN (temp_df.time)
                             LEFT JOIN metatrader.price as bid ON ROUND(bid.price, 2) IN(temp_df.bid)
                             LEFT JOIN metatrader.price as ask ON ROUND(ask.price, 2) IN(temp_df.ask)
                             LEFT JOIN metatrader.price as last ON ROUND(last.price, 2) IN(temp_df.last)
                             LEFT JOIN metatrader.volume as volume ON volume.volume IN(temp_df.volume)
                             LEFT JOIN metatrader.time_msc ON metatrader.time_msc.time_msc IN(temp_df.time_msc)
                             LEFT JOIN metatrader.flags ON metatrader.flags.flags IN(temp_df.flags)
                             LEFT JOIN metatrader.volume as volume_real ON volume_real.volume IN (temp_df.volume_real);
                            """, colnames = colnames)

            nrow = read_query(connection, "SELECT COUNT(*) FROM metatrader.ticks;")

            new_vector = ["('" + str(nrow[0][0] + x +1) + "', '"+ str(table_with_news_index.loc[x].at['symbol_id']) + "', '" + str(table_with_news_index.loc[x].at['time_id']) +"', '"+str(table_with_news_index.loc[x].at['bid_id']) + "', '"+
                          str(table_with_news_index.loc[x].at['ask_id'])+ "', '"+str(table_with_news_index.loc[x].at['last_id']) + "', '"+str(table_with_news_index.loc[x].at['volume_id']) + "', '"+
                          str(table_with_news_index.loc[x].at['time_msc_id']) + "', '"+str(table_with_news_index.loc[x].at['flags_id']) + "', '" + str(table_with_news_index.loc[x].at['volume_real_id'])+"')" for x in
                          range(len(table_with_news_index))]
            execute_query(connection, f'''INSERT INTO ticks VALUES {", ".join(new_vector)};''')

            read_query(connection, drop_temp_ticks_table)

def get_prices_from_mysql(connection,symbols, first_date, last_date):
    colnames = ['symbol', 'time',  'bid', 'ask','last',
                'volume', 'time_msc', 'flags', 'volume_real']
    dict_df = {}
    for symbol in symbols:
        #print(symbol)
        my_table = get_table_as_pandas_df(connection, f"""
            SELECT metatrader.symbol.symbol,  metatrader.time.time, 
            bid.price as bid, ask.price as ask, last.price as last,
            volume.volume as volume, metatrader.time_msc.time_msc, metatrader.flags.flags,
            volume_real.volume as volume_real
             FROM metatrader.ticks AS df
             LEFT JOIN metatrader.symbol ON metatrader.symbol.symbol_id =df.symbol
             LEFT JOIN metatrader.time ON metatrader.time.time_id =df.time
             LEFT JOIN metatrader.price as bid ON bid.price_id =df.bid
             LEFT JOIN metatrader.price as ask ON ask.price_id =df.ask
             LEFT JOIN metatrader.price as last ON last.price_id =df.last
             LEFT JOIN metatrader.volume as volume ON volume.volume_id =df.volume
             LEFT JOIN metatrader.time_msc ON metatrader.time_msc.time_msc_id =df.time_msc
             LEFT JOIN metatrader.flags ON metatrader.flags.flags_id =df.flags
             LEFT JOIN metatrader.volume as volume_real ON volume_real.volume_id =df.volume_real
             WHERE metatrader.symbol.symbol ='{symbol}'
             #AND metatrader.time.time > '{first_date}'
             #AND metatrader.time.time < '{last_date}'
            ORDER BY metatrader.time.time;
            #LIMIT 50;
            """, colnames = colnames)
        dict_df[symbol] = my_table

    return dict_df

if __name__ == '__main__':
    pd.set_option('display.max_columns', 500)  # number of columns to be displayed
    pd.set_option('display.width', 1500)  # max table width to display
    host_name = 'localhost'
    user_name = 'root'
    password = 'ojDPr&0AGZPmnrV'

    # connection = create_server_connection(host_name,user_name, password)
    db_name = 'MetaTrader'
    # create_database_query = "CREATE DATABASE "+db_name
    # create_database(connection, create_database_query)
    connection = create_db_connection(host_name, user_name, password, db_name)
    # execute_query(connection, create_price_table)
    # execute_query(connection, create_symbol_table)
    # execute_query(connection, create_volume_table)
    # execute_query(connection, create_time_table)
    # execute_query(connection, create_flags_table)
    # execute_query(connection, create_time_msc_table)
    # execute_query(connection, create_ticks_table)

    # execute_query(connection, relacionamentos("ticks","symbol","symbol" ))
    # execute_query(connection, relacionamentos("ticks",'time',"time" ))
    # execute_query(connection, relacionamentos("ticks",'bid',"price" ))
    # execute_query(connection, relacionamentos("ticks",'ask',"price" ))
    # execute_query(connection, relacionamentos("ticks",'last',"price" ))
    # execute_query(connection, relacionamentos("ticks",'volume',"volume" ))
    # execute_query(connection, relacionamentos("ticks","time_msc","time_msc" ))
    # execute_query(connection, relacionamentos("ticks","flags",'flags' ))
    # execute_query(connection, relacionamentos("ticks",'volume_real',"volume" ))

    # utc_from =pd.to_datetime(pd.DataFrame({'year':[2019],'month':[12],'day':[11]}))[0]
    # test =pd.to_datetime(pd.DataFrame({'year':[2002],'month':[6],'day':[23]}))[0]
    # utc_to = pd.to_datetime(pd.DataFrame({'year':[2019],'month':[12],'day':[11]}))[0]
    # symbols = ['OIBR3', 'CPLE3']

    sp_holidays =  holidays.Brazil(years=list(range (1900,datetime.datetime.now().year+1)), subdiv= "SP").items()
    tickers = ['ABEV3','VALE3']
    #tickers = list(get_table_as_pandas_df(connection,'''SELECT metatrader.symbol.symbol FROM metatrader.symbol;''', colnames=['symbols'])['symbols'])
    hour_beginner = datetime.datetime.now().hour
    #while hour_beginner + 2 <= datetime.datetime.now().hour:
    #    update_metatredar_table(connection,tickers,'backward', sp_holidays)


    update_metatredar_table(connection, tickers, 'forward', sp_holidays)
    #print(get_prices_from_mysql(connection, tickers,first_date= datetime.datetime.today()- 3*pd.tseries.offsets.Day(),
    #                            last_date=datetime.datetime.today())["CMIG4"].tail())
    connection.close()
