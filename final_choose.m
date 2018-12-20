function [target_stocks,price] = final_choose(date,period,stock_PE,data,n)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

%     filePath = 'PE06-18.csv';
%     %   获取股票代码
%     %     fileID = fopen(filePath);
%     %         C = textscan(fileID, strcat('%*s', repmat('%s',1,147)),1, 'delimiter', ',');
%     %     fclose(fileID);
%     %     stocks = cellfun(@(x) x,C(:));
%     fileID = fopen(filePath);
%         C1 = textscan(fileID, strcat('%*s', repmat('%s',1,147)),'Headerlines',1, 'delimiter', ',');
%     fclose(fileID);
   

    stock_list = find(stock_PE(date,:)<18);%选出市盈率小于18的股票
    %stock_list = sort(stock_list,'descend');
    
    
%   返回最大的几个值的位置
%     [~,i] = sort(stock_PE);
%     stock_list = i(138:147);

%获取价格并计算波动率
%     filename = 'close_price.mat';
%     read_data = load(filename);
%     data = read_data.data;
    k = length(stock_list);
    V = zeros(1,k);
    for i=1:k
        price0 = data(1:date,stock_list(i));
        logreturns = diff(log(price0));
        V(i) = std(logreturns(end-period+2:end))/mean(logreturns(end-period+2:end));
        V(i) = V(i) / sqrt(1/period);
    end
    
    %获取最终股票位置
    [~,i] = sort(V);
    target_stocks = sort(i(1:n));
    
      %输出价格：
   price = zeros(2939,n);
   for i = 1:n
       price(:,i) = data(1:2939,target_stocks(i));
   end
    
end
