clc;
close all;
clear all;
load handel.mat





[ stego_stereoY , stego_Fs ] = audioread('output.wav');
monoY = stego_stereoY(:,1);
y= monoY;
y= y/max(y);
%n=input('Enter n value for n-bit PCM system :  ');
n = 8;
sound(stego_stereoY, stego_Fs)
Total_Sample_Count = length(y);
Audio_Sampling_Rate = stego_Fs ;

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

%% declaring pos
if (n==8)
    pos = n-2;
elseif (n==16)
    pos = n-12;
end


%% taking length

message_len = code(10:15, pos);
message_length = msg_len(message_len);
%% taking pattern matching

pattern_matrix = code(16:16+n*2-1, pos);
pattern_matrix = num2str(reshape( pattern_matrix,[1,2*n]));
pattern_matrix = erase(pattern_matrix," ");

%% Taking message bits

received_bin = code(50:50+n*2*message_length-1, pos);


%% pattern matching
characters = char(zeros([message_length, 2]));
%ei m lagbe amr msg er every char characters matrix e indexing er jonno
m = 1;

for i = 1:2*n:length(received_bin)
    
    temp = received_bin(i:i+2*n-1,1); %jei binary paisi tar majhe 2*n sonkok nicchi 
                                      %karon n bit hole akta char 2*n e
                                      %convert hoy. 
    %temp
    split_temp = zeros([(n/4),4]);    % jei 2*n nisi oigulare akhn 4 by 4 e vangte hobe
    k = 1;
    for j = 1:4:length(temp)
    
        split_temp(k, :) = temp(j:j+3,1);   %2*n ke venge split temp e rakhtsi
        k=k+1;
        
        
    end
    
   indexing = zeros([(n/4),1]);           %oi j vanglam raw te
                                      %akta raw & 4 ta column theke 1ta num/index generate korbo oi index ke pore pattern e khujte hobe 
   k = 1;
   for i = 1:(n/2)
         %ekhane  oi 4 ta value ke merge kortesi jeno bin2text value te
         %nite pari pore
        x = (split_temp(i,:));      
        x = num2str(reshape( x,[1,4]));
        x = erase(x," ");
        
        indexing(k,:) = string(x);
        k = k+1;
        
   end
   
   %ekhane  je value gula paisi divide kore oigula ke dec e nitesi 
   %getting decimal value
   index_dec = zeros([4,1]);
   for i = 1:(n/2)
    index_dec(i) = bin2dec(string(indexing(i)));    
   
   end
   
   %retriving original binary
   %ekhane oi decimal gulake pattern er sathe match kore original binary
   %banaitesi
   %ei prapto value gula te asole oi pattern matrix er index khujbo
   %oi index e corresponding 2 ta bit nibo
   
   original_binary = strings([(n/4),1]);

   for i = 1:(n/2)
      
       k = (index_dec(i));
       original_binary(i,1) = string(pattern_matrix(1, k:k+1 ));
 
   end
   %check
   %p=i
   
   
   %index theke khuje sb original msg er binary original_binary vector e
   %niye nilam
   %ei vector to (n/4)by1 mane raw vector
   %eke ak raw te ene msg retrive korte hobe   
   original_binray = reshape(original_binary, [1, (n/2)] );
   
   final = strings(); %ekhon amader bin2text kintu string ney
   %so akta char ber hobe original_binary vector theke
   %oi akta char rakhar jonno final string nilam
   
   for i = 1:(n/2)
       
      final = strcat(final, original_binary(i)) ; %final e oi original_binary binary er
                                                  %every binary jura ditesi
                                                  %akta single string
                                                  %bananor jonno cz
                                                  %original_binary er kintu
                                                  %vector
   end
   
   
    characters(m,:) = bin2text(char(final));    %oi string theke akhon akta char pelar
    m = m+1;
    
end


original_message = strings(); % pura msg aksathe dekhate akta string nilam

%akhon every char aksathe jura dibo
for i = 1:length(characters)
       
      original_message = strcat(original_message, characters(i)) ;
end

%origianl msg e final
%shundorer jonno characters name arekta fresh single matrix e rakhlam

characters = reshape(characters(:,2), [1, length(characters)])

