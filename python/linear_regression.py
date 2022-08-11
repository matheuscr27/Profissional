import numpy as np
from sklearn.linear_model import LinearRegression
#from https://realpython.com/linear-regression-in-python/

x = np.array([5, 15, 25, 35, 45, 55]).reshape((-1, 1))
y = np.array([5, 20, 35, 50, 65, 80])
def my_linear_regression(x_axis, y_axis, pred_distance):
    x_axis = np.array(x_axis).reshape((-1, 1))
    x_axis = x_axis.astype(np.int)
    y_axis = np.array(y_axis)
    model  = LinearRegression(n_jobs= -1).fit(x_axis,y_axis)


    #R²
    r_sq = model.score(x, y)
    #print(f"coefficient of determination: {r_sq}")

    #print(f"intercept: {model.intercept_}")

    #print(f"slope: {model.coef_}")

    y_pred = model.predict([x_axis[len(x_axis)-1] +  pred_distance])
    #print(f"predicted response:\n{np.round(y_pred,2)}")
    return y_pred, model.coef_