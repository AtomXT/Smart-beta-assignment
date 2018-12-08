# -*- coding: utf-8 -*-
"""
Created on Sun Mar  x xx:xx:xx 2018

@author: 粉粉
"""
import baostock as bs
import pandas as pd

lg = bs.login()
rs = bs.query_hs300_stocks()
hs300_stocks = []
while (rs.error_code == '0') & rs.next():
    # 获取一条记录，将记录合并在一起
    hs300_stocks.append(rs.get_row_data())
result = pd.DataFrame(hs300_stocks, columns=rs.fields)
codes_index = result['code'].values
bs.logout()

for code_index in codes_index:
	lg = bs.login()
	rs = bs.query_history_k_data(str(code_index),
		"date,open,high,low,close,preclose,volume,amount,adjustflag,turn,tradestatus,pctChg,peTTM,pbMRQ,psTTM,pcfNcfTTM,isST",
		start_date='2006-01-01', end_date='2017-12-31',
		frequency="d", adjustflag="1")
	print('query_history_k_data respond error_code:'+rs.error_code)
	print('query_history_k_data respond  error_msg:'+rs.error_msg)

	data_list = []
	while (rs.error_code == '0') & rs.next():

		data_list.append(rs.get_row_data())
	result = pd.DataFrame(data_list, columns=rs.fields)

	filename = "%s%s" % (str(code_index), '.csv')
	result.to_csv(filename, index=False)
	bs.logout()
