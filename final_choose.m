function earning = trading(start_date,end_date,freq)
%start_date 开始交易的日期
%end_date 交易结束的日期
%freq 交易间隔

filePath = 'PE06-18.csv';
%   获取股票代码
%     fileID = fopen(filePath);
%         C = textscan(fileID, strcat('%*s', repmat('%s',1,147)),1, 'delimiter', ',');
%     fclose(fileID);
%     stocks = cellfun(@(x) x,C(:));
fileID = fopen(filePath);
    C1 = textscan(fileID, strcat('%*s', repmat('%s',1,147)),'Headerlines',1, 'delimiter', ',');
fclose(fileID);

%获取价格并计算波动率
    filename = 'close_price.mat';
    read_data = load(filename);
    data = read_data.data;

Total = 100000;%初始资金
idd = 0;%持仓情况 0为空仓 1为持仓 
buy = [];sell=[];%买入以及卖出的日期
profit = [];%每次交易盈利
earning_rate = [0];%收益率
old_prices=[];new_prices=[];%用于记录上次所选股票的价格以及本次所选股票的价格
%% 第一次交易
[~,old_prices] = final_choose(start_date,30,C1,data);%在交易开始日选择10支股票记录价格
buy = [buy, start_date];%在第一次交易日买入，记录买入点
% disp('买入股票价格为：')
% old_prices(start_date,:)
number = floor(Total/10./(100*old_prices(start_date,:)));%判断每只股票可以买入多少手，向下取整
Total = Total - 1.003*100*old_prices(start_date,:)*number'; %买入股票，总手续费千分之3
%%
for date=start_date+freq:freq:end_date %date 交易时间
        sell = [sell, date];%交易日首先卖出原有股票
        price_change = (old_prices(sell(end),:) - old_prices(buy(end),:))./old_prices(buy(end),:);
        flag1 =  min(price_change > 0.05 , price_change < -0.05);%判断涨跌幅是否达到卖出条件
        temp_profit = 100*number*0.997*(old_prices(sell(end),:).*flag1 - old_prices(buy(end),:).*flag1)';%计算达到条件的股票卖出所得收益,手续费千分之3
        profit = [profit, temp_profit];%储存本次盈利
        hold_value = old_prices(sell(end),:)*(1-flag1)';%未卖出股票的价值
        Total = Total + 100*number*0.997*(old_prices(sell(end),:).*flag1)'+hold_value;%更新当前总资金
        earning_rate = [earning_rate,(Total-100000)/100000];
        holding_number = 10 - sum(flag1);%手里还持有多少股票没有卖出。
        if(date<end_date)%判断是否到达交易结束日
            [~,new_prices] = final_choose(date,30,C1,data);%获取当前交易日的新选股票
            buy = [buy, date];%记录买入点
            number = floor(Total/10./(100*new_prices(buy(end),:)));%判断每只股票可以买入多少手，向下取整
            Total = Total - 1.003*100*number*new_prices(date,:)';%买入后剩余资金
            old_prices = new_prices;
    end
end
earning = Total;


%指数收益率
filePath2 = '沪深300 06-18.csv' ;
fileID2 = fopen(filePath2);
    C2 = textscan(fileID2, '%*s%*s%*s%s%*s%*s%*s%*s%*s%*s%*s%*s','Headerlines',1, 'delimiter', ',');
fclose(fileID2);

for i=start_date:end_date
    temp1 = cellfun(@(x) str2double(x),C2{1,1}(i));
    index(i) = temp1;
end

index_start = index(start_date);

index_rate=[];
for i=start_date:freq:end_date
    j=(i-start_date)/freq+1;
    index_rate(j) = index(i)/index_start-1;
end

index_rate= index_rate.';

plot(index_rate,'b')
hold on
%title('收益率')
plot(earning_rate,'r')
%蓝色曲线为指数收益率，红色曲线为我方策略收益率
end
