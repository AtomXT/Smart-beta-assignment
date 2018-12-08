function target_stocks = final_choose(date,period)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

    filePath = 'hz_市盈率06-18.csv';
    %   获取股票代码
    %     fileID = fopen(filePath);
    %         C = textscan(fileID, strcat('%*s', repmat('%s',1,147)),1, 'delimiter', ',');
    %     fclose(fileID);
    %     stocks = cellfun(@(x) x,C(:));
    fileID = fopen(filePath);
        C1 = textscan(fileID, strcat('%*s', repmat('%s',1,147)),'Headerlines',1, 'delimiter', ',');
    fclose(fileID);
   
    stock_PE = zeros(1,147);%date天的所有股票的市盈率
    for i=1:147
        temp = cellfun(@(x) str2double(x),C1{i}(date));
        stock_PE(i) = temp;
    end
    stock_list = find(stock_PE<18);%选出市盈率小于18的股票
%   返回最大的几个值的位置
%     [~,i] = sort(stock_PE);
%     stock_list = i(138:147);

%获取价格并计算波动率
    filename = 'close_price.csv';
    data = csvread(filename);
    k = length(stock_list);
    V = zeros(1,k);
    for i=1:k
        price = data(1:date,stock_list(i));
        logreturns = diff(log(price));
        V(i) = std(logreturns(end-period+2:end))/mean(logreturns(end-period+2:end));
        V(i) = V(i) / sqrt(1/period);
    end
    
    %获取最终股票位置
    [~,i] = sort(V);
    target_stocks = i(1:10);
    
end
