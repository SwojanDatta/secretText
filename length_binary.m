function l_binary = length_binary(message)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    out = [0,0,0,0,0];
    l = length(message);
    
    b = de2bi(l,'left-msb');
    
    out = [out b];
    
    l_binary = out(1,length(out)-5:end)


end

