function [earning,f,ar,sr,mdr,fr,PE,period,sp,sl]=parameter_tuning_trading(PE,period,sp,sl)
% f 目标函数的值。
% ar 年化收益率
% sr 夏普比率
% mdr 最大回撤率
% fr 波动率
% PE 市盈率
% period 调仓周期
% sp 止盈
% sl 止损
start_date = 30;
end_date = 280;
freq = period;

%获取市盈率
filePath = 'stock_PE.mat';
stock_PE = load(filePath);
stock_PE = stock_PE.stock_PE;
%获取价格
filename = 'close_price.mat';
read_data = load(filename);
data = read_data.data;

Total = 1000000;%初始资金
Assets = 1000000;
% idd = 0;%持仓情况 0为空仓 1为持仓
buy = ones(2,10); sell=[];%买入以及卖出的日期
profit = [];%每次交易盈利
earning_rate = [];%收益率
old_prices=[];new_prices=[];%用于记录上次所选股票的价格以及本次所选股票的价格
stocks = []; %记录持有的股票序号
price_change = zeros(1,10); %单次涨跌幅比较
temp_profit0 = zeros(1,10); 
%% 第一次交易
[stocks,old_prices] = final_choose_tuning(start_date,30,stock_PE,data,10,PE);%在交易开始日选择10支股票记录价格
buy = buy.*start_date;%在第一次交易日买入，记录买入点
% disp('买入股票价格为：')
% old_prices(start_date,:)
number = floor(80000./(100*old_prices(start_date,:)));%判断每只股票可以买入多少手，向下取整
Total = Total - 1.006*100*old_prices(start_date,:)*number'; %买入股票,总手续费千分之3,现金流
Assets = 1000000 - 0.006*100*old_prices(start_date,:)*number';%总资产是减少手续费部分

%% 交易
for date=start_date+freq:freq:end_date %date 每次交易时间
    used_data = data; %在交易时暂时删去之前交易用过的股票数据，所以设置一个used开头的变量
    used_stock_PE = stock_PE;
    sell = [sell, date];%交易日首先卖出原有股票，记录卖出日期
%     price_change = (old_prices(sell(end),:) - old_prices(buy(end),:))./old_prices(buy(end),:);

%分别计算单次涨跌幅
    for i = 1:10
        price_change(i) = (old_prices(sell(end),i) - old_prices(buy(2,i),i))./old_prices(buy(2,i),i);        
    end
    flag1 =  max(price_change > sp , price_change < sl);%判断涨跌幅是否达到卖出条件
    
%分别计算单次收益
    for i = 1:10
        if flag1(i) == 1
           temp_profit0(i) = (old_prices(sell(end),i)*0.994 - old_prices(buy(2,i),i)*1.006)*100*number(i);
        else
           temp_profit0(i) = 0;
        end
    end
    temp_profit = sum(temp_profit0); %单次交易总收益
%    temp_profit = 100.*0.997.*number*(old_prices(sell(end),:).*flag1)' - 100.*1.003.*number*(old_prices(buy(end),:).*flag1)';%计算达到条件的股票卖出所得收益,手续费千分之3
    profit = [profit, temp_profit];%储存本次盈利
    %hold_value = 100.*number.*old_prices(sell(end),:)*(1-flag1)'; %未卖出股票的价值
    Total = Total + 100*0.994*number*(old_prices(sell(end),:).*flag1)';%更新当前现金
    Assets = [Assets, Assets(end) + temp_profit]; %更新当前总资产
    
    holding_number = 10 - sum(flag1);%手里还持有多少股票没有卖出。
   
    if (date<=end_date-freq && Total >= 80)%判断是否到达交易结束日
            %删除上次使用的股票数据
            for i = 1:10
                used_data(:,stocks(i)) = [];
                used_stock_PE(:,stocks(i)) = [];
                %stocks(i) = 0;
            end
            %         stocks(stocks==0)=[];
            %         used_data(used_data==0)=[];
            %         used_stock_PE(used_stock_PE==0)=[];
            
            n = 10 - holding_number; %交易日需要买进的股票支数
            [stocks_new,new_prices] = final_choose_tuning(date,30,used_stock_PE,used_data,n,PE);%获取当前交易日的新选股票
            %             stocks = [stocks, stocks_new];
            buy(2,:) = date*ones(1,10).*flag1 + buy(1,:).*(1-flag1);%更新现有股票的买入点
            new_number = floor(80000./(100*1.006*new_prices(date,:)));%判断新买的股票每只可以买入多少手，向下取整
            Total = Total - 1.006*100*new_number*new_prices(date,:)';%买入后剩余资金
            Assets(end) = Assets(end) - 0.006*100*new_number*new_prices(date,:)';
            %更新价格、持有股票代码、每只股票持有数量
            index = find(flag1==1); %卖出股票的位置
            for i = 1:length(index) %把新的信息填到已卖出的股票那里
                old_prices(:,index(i)) = new_prices(:,i);
                stocks(index(i)) = stocks_new(i);
                number(index(i)) = new_number(i);
            end
            earning_rate = [earning_rate,(Assets(end)-1000000)/1000000];
    else
%      temp_profit = 100.*0.997.*number*(old_prices(sell(end),:).*(1-flag1))' - 100.*1.003.*number*(old_prices(buy(end),:).*(1-flag1))'; %到期全部抛售  
       for i=1:10
           temp_profit0(i) = (old_prices(sell(end),i)*0.994 - old_prices(buy(2,i),i)*1.006).*100.*number(i);
       end
       temp_profit = sum(temp_profit0);
       Assets(end) = Assets(end) + temp_profit;
       earning_rate = [earning_rate,(Assets(end)-1000000)/1000000];
       earning = Assets(end);
    end
end
InitialValue = 1000000;
ar = (Assets(end)/InitialValue-1)/length(profit)*250;
sr = ar/std(profit/InitialValue)/sqrt(250);
HighValue = zeros(1,length(Assets));
for i = 1:length(Assets)
    HighValue(i) = max(Assets(1:i));
end
mdr = max(1-Assets./HighValue);
fr = std(profit/InitialValue);
f = sr/mdr;
earning = Assets(end);
end
