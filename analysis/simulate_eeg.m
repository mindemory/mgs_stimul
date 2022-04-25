clear; close all; clc;
srate=1000;

time=(0:1/srate:10);

data = generate_data(time);

% morlet wavelet convolution (more on this in later chapters)
num_frex = 40;
min_freq =  1;
max_freq = 40;

Ldata  = length(data);
Ltapr  = length(data);
Lconv1 = Ldata+Ltapr-1;
Lconv  = pow2(nextpow2(Lconv1));

frex=logspace(log10(min_freq),log10(max_freq),num_frex);

% initialize
tf=zeros(num_frex,length(data));
datspctra = fft(data,Lconv);

s=4./(2*pi.*frex);
t=-((length(data)-1)/2)/srate:1/srate:((length(data)-2)/2)/srate+1/srate;

for fi=1:length(frex)
    
    wavelet=exp(2*1i*pi*frex(fi).*t).*exp(-t.^2./(2*s(fi)^2));
    
    m = ifft(datspctra.*fft(wavelet,Lconv),Lconv);
    m = m(1:Lconv1);
    m = m(floor((Ltapr-1)/2):end-1-ceil((Ltapr-1)/2));
    
    tf(fi,:) = abs(m).^2;
end
figure
imagesc(1:length(data),[],tf);
set(gca,'xlim',[1 8]*1000,'ydir','normal', ...
    'ytick',1:8:num_frex,'yticklabel',round(frex(1:8:end)), ...
    'xtick',0:1000:10000,'xticklabel',0:10)
title('Time-frequency representation', fontsize = 20)
xlabel('Time (s)', fontsize = 15)
ylabel('Frequency (Hz)', fontsize = 15)
%%
% figure
% 
% subplot(221)
% plot(a)
% set(gca,'xlim',[1 8]*1000,'ylim',[-1 1],'xtick',0:1000:10000,'xticklabel',0:10);
% title('10 Hz signal, DC=0')
% 
% subplot(222)
% plot(b)
% set(gca,'xlim',[1 8]*1000,'ylim',[-1 1],'xtick',0:1000:10000,'xticklabel',0:10);
% title([ '.3 Hz signal, DC=' num2str(DCoffset) ])
% 
% subplot(223)
% plot(data)
% set(gca,'xlim',[1 8]*1000,'ylim',[-1 1],'xtick',0:1000:10000,'xticklabel',0:10);
% title('Time-domain signal')
% 
% subplot(224)
% imagesc(1:length(data),[],tf);
% set(gca,'xlim',[1 8]*1000,'ydir','normal','ytick',1:8:num_frex,'yticklabel',round(frex(1:8:end)),'xtick',0:1000:10000,'xticklabel',0:10)
% title('Time-frequency representation')
