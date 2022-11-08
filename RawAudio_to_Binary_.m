clc;
close all;
clear all;
load handel.mat


[ stereoY , Fs ] = audioread('havana.wav');
monoY = stereoY(:,1);
y= monoY;
y= y/max(y);
n=input('Enter n value for n-bit PCM system :  ');

% sound(stereoY, Fs)
Total_Sample_Count = length(y);
Audio_Sampling_Rate = Fs ;

L=2^n-1;
vmax=max(y);
vmin=min(y);
del=(vmax-vmin)/L;
part=vmin:del:vmax;                                  
code=vmin-(del/2):del:vmax+(del/2);         
[ind,q, mser]=quantiz(y,part,code);                     
l1=length(ind);
l2=length(q);
 
% for i=1:l1
%    if(ind(i)~=0)                                           
%    end 
%    i=i+1;
% end   
 for i=1:l2
    if(q(i)==vmin-(del/2))                         
        q(i)=vmin+(del/2);
    end
 end

code=de2bi(ind,'left-msb');             
k=1;
for i=1:l1
    for j=1:n
        coded(k)=code(i,j);             
        j=j+1;
        k=k+1;
    end
    i=i+1;
end




%%
%PCM = coded 
%%%%% plotting all quantized data %%%%%%%%%%%%
% figure(1) 
% subplot(2,1,1)
% plot(stereoY); grid on;                                       
% title('Raw Audio Signal');
% ylabel('Amplitude--->');
% xlabel('Time--->');
%  
% subplot(2,1,2)
% plot(y); grid on;                                       
% title('One channel of Raw Audio Signal');
% ylabel('Amplitude--->');
% xlabel('Time--->');
% 
% figure(2)
% subplot(2,1,1)
% stem(q);grid on;                                       
% title('Quantized Signal');
% ylabel('Amplitude--->');
% xlabel('Time--->');
%   
% subplot(2,1,2); 
% grid on;
% stairs(coded);       
% title('Encoded Signal');
% ylabel('Amplitude--->');
% xlabel('Time--->');
 

%%
%% For checking audio graph%%%%%%%%%%%%%%%%%

figure(3)
qunt=reshape(coded,n,length(coded)/n);
index=bi2de(qunt','left-msb');       % Getback the index in decimal form
q=del*index+vmin+(del/2);            % getback Quantized values
subplot(2,1,1); grid on;
plot(q);    % Plot Demodulated signal
disp(max(q))
title('Demodulated original Signal');
ylabel('Amplitude--->');
xlabel('Time--->');


% %%%%%%%%%%for checking audio sound%%%%%%%%%%%
% data = uint8(bin2dec( char( reshape( coded, 8,[]).'+'0')));
% audiowrite('output.wav',data, 44100)



%% Taking Secret Message
secret_message = input('Enter Your Secret Message :  ', 's');  %taking secret message as string
%always taking input as string and dont evaluate            
%spliting message into characters and getting binary of ever values
secret_binary = zeros([length( secret_message ), n], 'int8');

%making every char to binary
for i = 1:length( secret_message )
    secret_binary(i, :) = text2bin( (secret_message(i)),n ); %converting string message to binary

end
%disp(secret_binary);



%% Encription

pattern_matrix = code(1:2, :);
pattern_matrix_copy = reshape( pattern_matrix, [1, 2*n]);
pattern_matrix = num2str(reshape( pattern_matrix,[1,2*n]));
pattern_matrix = erase(pattern_matrix," ");


%% storing genaralised message binary

gen_binary_message = [];


%% pattern matching

for i = 1:length( secret_message )
    
    temp = secret_binary( i, : ); %loading binary of each char to match pattern and getting index 
    splited_char = zeros( [n/2, 2] );
    
    k = 1;
    for j = 1:2:length(temp)-1
        splited_char(k, :) = temp(j:j+1); % loading splited binary of 2 bit for each char
        k = k+1;
    end
    
    
    splited_char_index = zeros( [n/2, 1] );
    for i = 1:n/2
        temp = num2str( splited_char(i,:));
        temp = erase(temp," ");
        index = strfind(pattern_matrix, temp);
        
        splited_char_index(i) = index(1,1);
    end
    
    
    % converting each index to binary
    %and adding to vector
    %for n char vector size n*16
    for i = 1:n/2
        
        temp = dec2bin( splited_char_index(i,1), 4 )-'0'; %converting each index 4 bit binray and getting integer 0/1
        gen_binary_message = [gen_binary_message temp]; %adding up to one vector of size n*16
    
    end

end


%% Adding final index_binary to LSB of audio
% first 2 rows are for pattern matching
% next 20 rows are for message info
check = [];
generated_code = code;

info_binary = length_binary(secret_message); %length binary 6 bit binary dibe length er
                                             %so msg length 2^6=64 hoite parbe
                                             
                                             
for i = 1:length(info_binary)
    
    if (n==8)
        generated_code(i+9, n-2) = info_binary(i);
    end
    if (n==16)
        generated_code(i+9, n-12) = info_binary(i);
    end
    %6th column e dhukaistesi
    %10-15 row te msg length info dhukaisi
      
end


% pattern rakhbo 16-31 porjnto
% 16 bit e pattern rakhbo 16 theke 47 porjnto

for i = 1:length(pattern_matrix)
    
    if (n==8)
        generated_code(i+15, n-2) = (pattern_matrix_copy(i));
    end
    if (n==16)
        generated_code(i+15, n-12) = (pattern_matrix_copy(i));
    end
    
      
end

%msg rakhbo 50 row theke 
for i = 1:length(gen_binary_message)
    
        
    %check = code(i+22, n-2);
    if (n==8)
        generated_code(i+49, n-2) = gen_binary_message(i); %steg binary code
    end
    if (n==16)
        generated_code(i+49, n-12) = gen_binary_message(i); %steg binary code
    end
        %this have to convert to audio    
    
end


%% Generating audio file 

%%%%%%%%%%%% For checking audio graph%%%%%%%%%%%%%%%%%

regenerated_code = reshape(generated_code, [1, height(generated_code)*width(generated_code)] );

 %Demodulation Of PCM signal
 %qunt=reshape(regenerated_code, n, length(regenerated_code)/n);
 
 
 %Generating de-quantized modified binary
 index = bi2de(generated_code,'left-msb');       % Getback the index in decimal form
 final_output = del*index+vmin+(del/2);            % getback Quantized values
 subplot(2,1,2); grid on;
 plot(final_output);                             % Plot Demodulated signal
 disp(max(final_output))
 title('Demodulated Regenerated Signal');
 ylabel('Amplitude--->');
 xlabel('Time--->');


%%%%%%%%%%% for checking audio sound %%%%%%%%%%%
% data = double(bin2dec( char( reshape( regenerated_code, 8,[]).'+'0')));
% dataa = zeros([401520,2]);


%Checking sound
%sound( q, Fs)


%% Making Dual Channel Aduio
dual_channel_data(:, 1) = final_output;
dual_channel_data(:, 2) = stereoY(:, 2); 

% figure(4);
% plot(dual_channel_data(:,1));
% figure(5);
% plot(monoY);
% 
% figure(6)
% subplot(211), plot(stereoY)
% subplot(212), plot(dual_channel_data)


audiowrite('output.wav',dual_channel_data, Fs)
secret_message

% data = uint8(bin2dec( char( reshape( generated_code, 8,[]).'+'0')));
% dataa(:,1) = data;
% dataa(:,2) = data;
% audiowrite('output.wav',dataa, Fs)