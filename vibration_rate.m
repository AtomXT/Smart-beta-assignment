function V = vibration_rate(price,period)
    logreturns = diff(log(price));
    V = std(logreturns(end-period+2:end))/mean(logreturns(end-period+2:end));
    V = V / sqrt(1/period);
end
