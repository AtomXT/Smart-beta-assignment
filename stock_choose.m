function stock_list = stock_choose(date)
    filePath = 'E:\华东师范大学\大三上\金融建模与计算\大作业\选股\PE06-18.csv';
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
%     stock_list = i(138,147);
end
