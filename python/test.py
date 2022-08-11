import datetime
import holidays
#https://towardsdatascience.com/the-easiest-way-to-identify-holidays-in-python-58333176af4f
#from workalendar.s
print()
for holiday in holidays.Brazil(years=list(range (1900,datetime.datetime.now().year+1)), subdiv= "SP").items():
    print(holiday)

brazil_holidays = holidays.Brazil(years=list(range (1900,datetime.datetime.now().year+1))).items()
sp_holidays =  holidays.Brazil(years=list(range (1900,datetime.datetime.now().year+1)), subdiv= "SP").items()
for holiday in holidays(years=list(range (1900,datetime.datetime.now().year+1))).items():
    print(holiday)