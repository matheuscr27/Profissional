import MetaTrader5 as mt5
from datetime import datetime
# import pytz module for working with time zone
import pytz
import pandas as pd
import math, statistics, matplotlib.pyplot as plt, numpy as np
from scipy import stats
import linear_regression
import get_prices

def prepare_data(df_ticks, price_col_name, number_of_samples, sample_size, distance_to_zero_of_outlier_criter):
    nrow = len(df_ticks)
    # df_ticks['time'] = pd.Timestamp(pd.to_datetime(df_ticks['time'], unit ='s').dt.hour, "%Y-%m-%d %H:%M:%S").strftime("%H")
    df_hours = pd.to_datetime(df_ticks['time'], unit='s').dt.hour

    df_ticks = df_ticks[(df_hours >= 10) & (df_hours <= 18)]

    # print((df_hours > 10) & (df_hours<18))
    # df_ticks['time'].dt.h
    # print(df_ticks['time'])
    # df_ticks = df_ticks[(my_times>=10) and (my_times<=18)]
    df_ticks = df_ticks[df_ticks[price_col_name] > 0]
    df_ticks = df_ticks[df_ticks[price_col_name] <=df_ticks[price_col_name].describe()['75%']*1000  ]
    # descatar os numeros que são inferiores à multiplicação por mil do numero que está em torno dos 75%, terceiro quartil, dos dados
    price_mean = df_ticks[price_col_name].mean()
    sample_mean = []
    for my_index in range(0, number_of_samples):
        my_sample_positions = np.random.choice(df_ticks[price_col_name].index,
                                               sample_size)  # escolhe entre o indix de data_past

        sample_mean.append(df_ticks[price_col_name][my_sample_positions].mean())

    df_samples_nomalized = pd.DataFrame(np.round(sample_mean, decimals=5)) - price_mean
    freq = df_samples_nomalized.value_counts(sort=False)
    my_sd = float(np.std(df_samples_nomalized))
    dist_from_zero = (df_ticks[price_col_name] - price_mean) / my_sd

    df_ticks = df_ticks[(dist_from_zero <= distance_to_zero_of_outlier_criter) &
                        (dist_from_zero >= ((-1) * distance_to_zero_of_outlier_criter))]


    return df_ticks


def central_limit_theory(df_ticks, price_col_name, number_of_samples, sample_size,  break_data_from_now_to, set_initial_data_from_now):
    nrow = len(df_ticks)
    if set_initial_data_from_now > (nrow-1):
        set_initial_data_from_now = (nrow-1)
    if break_data_from_now_to >(nrow - 1):
        break_data_from_now_to = round((nrow - 1)*0.5)

    data_past = df_ticks[price_col_name][nrow-1 - set_initial_data_from_now:nrow-1 - break_data_from_now_to]
    data_past = data_past[data_past>0]
    data_now  = df_ticks[price_col_name][nrow - 1- break_data_from_now_to: nrow -1]
    #data_past.plot()
    #plt.show()

    nrow_past = len(data_past)
    price_mean = data_past.mean()
    sample_mean  = []
    for my_index in range (0, number_of_samples):
        my_sample_positions = np.random.choice(data_past.index, sample_size) # escolhe entre o indix de data_past

        sample_mean.append(data_past[my_sample_positions].mean())


    df_samples_nomalized =pd.DataFrame(np.round(sample_mean, decimals=3))-price_mean
    #freq = df_samples_nomalized.value_counts(sort = False)

    #pd.DataFrame(freq).plot()
    #plt.show()

    #my_sd = np.std(df_samples_nomalized)
    my_sd = np.std(sample_mean)

    my_test_value = (data_now.mean() - price_mean)/my_sd
    return({'my_test_value':my_test_value, 'sd': my_sd})



#print( pytz.all_timezones)

#set tima zone
#timezone = pytz.timezone('America/Sao_Paulo')
# create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset
#utc_from = datetime(2022, 3, 1, tzinfo=timezone )
#utc_to = datetime(2022, 6, 24, tzinfo=timezone)

#list_ticks = ['OIBR3','PETR4','SULA4','BBSE3']
#my_dict_prices = get_prices.get_prices(list_ticks,utc_from, utc_to)

#my_sample_length = 5000

#number_of_samples = 50000
#sample_size = 5
#break_data_from_now_to = 1000
#set_initial_data_from_now = 10000
#price_col_name = 'last'
#near_distance= 10000
#middle_distance = 100000
#far_distance = 1000000
def statistic_table(my_dict_prices, price_col_name, number_of_samples,sample_size,
                    break_data_from_now_to,near_distance,middle_distance,far_distance):
    div = pd.DataFrame()
    for tick in my_dict_prices.keys():
        #df_ticks = my_dict_prices[tick]

        # create DataFrame out of the obtained data


        my_dict_prices[tick] = prepare_data(my_dict_prices[tick],
                                   price_col_name,
                                   number_of_samples,
                                   sample_size,
                                   distance_to_zero_of_outlier_criter = 10000)

        near_desviation = central_limit_theory(my_dict_prices[tick],
                                   price_col_name,
                                   number_of_samples,
                                   sample_size,
                                   break_data_from_now_to,
                                    near_distance)
        middle_desviation = central_limit_theory(my_dict_prices[tick],
                                   price_col_name,
                                   number_of_samples,
                                   sample_size,
                                   break_data_from_now_to,
                                    middle_distance)
        far_desviation = central_limit_theory(my_dict_prices[tick],
                                   price_col_name,
                                   number_of_samples,
                                   sample_size,
                                   break_data_from_now_to,
                                    far_distance)

        lr_day_trade = linear_regression.my_linear_regression(x_axis= my_dict_prices[tick]['time'].tail(near_distance), y_axis= my_dict_prices[tick][price_col_name].tail(near_distance),pred_distance=near_distance)
        lr_swing_trade = linear_regression.my_linear_regression(x_axis= my_dict_prices[tick]['time'].tail(middle_distance), y_axis= my_dict_prices[tick][price_col_name].tail(middle_distance), pred_distance=near_distance)
        lr_total = linear_regression.my_linear_regression(x_axis= my_dict_prices[tick]['time'], y_axis= my_dict_prices[tick][price_col_name], pred_distance=near_distance)
        my_dict_statistics ={
        'near_desviation':near_desviation['my_test_value'],
        'middle_desviation':middle_desviation['my_test_value'],
        'far_desviation':far_desviation['my_test_value'],
        'near_slope':lr_day_trade[1][0],
        'middle_slope':lr_swing_trade[1][0],
        'far_slope'  :lr_total[1][0],
        'near_pred_price':round(lr_day_trade[0][0],2),
        'middle_pred_price': round(lr_swing_trade[0][0],2),
        'far_pred_price': round(lr_total[0][0],2)
        }
        my_row = pd.Series(data=my_dict_statistics, index=my_dict_statistics.keys())
        my_row.columns = tick
        div = pd.concat([div, pd.Series(data=my_row, index=my_row.keys())], axis=1)
    div.columns = my_dict_prices.keys()
    return my_dict_prices, div.T

#print(statistic_table(my_dict_prices, price_col_name, number_of_samples,
#                    break_data_from_now_to,near_distance,middle_distance,far_distance))

