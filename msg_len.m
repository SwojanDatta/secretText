function length_msg = msg_len(binary_data)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


    data = num2str(reshape(binary_data, [1,6]));
    
    data = erase(data," ");
    length_msg = bin2dec(data);

end

