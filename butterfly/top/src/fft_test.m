%% definizione dei segnali di test per la FFT
%% parametri generali
freq=5; % frequenza
k=8; % fattore moltiplicativo per Fs
Fs=k*freq; % frequenza di campionamento
N=16; % Numero di campioni nella FFT
t=(0:(N-1))/Fs; % intervallo temporale
df=Fs/N; % risoluzione in frequenza
f=(-N/2:(N/2-1))*df; % intervallo in frequenza
MAX=2^15-1;
% Nomi da fornire ai grafici
t0=["Onda sinusoidale", "Onda quadra", ...
    "Onda triangolare", "Funzione porta", ...
    "Funzione Delta di Dirac", ...
    "Funzione Delta di Dirac 2", ...
    "Onda sinusoidale complessa", ...
    "Onda sinusoidale complessa rumorosa"];
t1=["FFT onda sinusoidale", "FFT onda quadra", ...
    "FFT onda triangolare", "FFT funzione porta", ...
    "FFT funzione Delta di Dirac", ...
    "FFT funzione Delta di Dirac 2", ...
    "FFT onda sinusoidale complessa", ...
    "FFT onda sinusoidale complessa rumorosa"];

%% definizione funzione seno
phi0 = 30*pi/180; % fase dell'onda
x0=sin(2*pi*freq*t+phi0); % funzione seno

%% definizione onda quadra
phi1=90*pi/180; % fase dell'onda
x1=square(2*pi*freq*t+phi1);

%% definizione onda a dente di sega
x2=sawtooth(2*pi*freq*t);

%% definizione funzione porta
x3=zeros(1,N); x3(1:N*5/16)=1;

%% definizione funzione Delta di Dirac
x4=zeros(1,N); x4(1)=1;

%% definizione funzione Delta di Dirac 2
x5=zeros(1,N); x5(N/2-N/8)=1; x5(N/2+N/8)=-1;

%% definizione funzione sinusoide complessa
x6=exp(1i*2*pi*freq*t);

%% definizione funzione sinusoidale complessa rumorosa
A7=0.25;
x7=A7*exp(1i*2*pi*freq*t) + A7*exp(-1i*2*pi*3/2*freq*t);
x7=x7 + (0.15)*(1+1i)*randn(size(t));

%% Matrice con i vari segnali
x=[x0; x1; x2; x3; x4; x5; x6; x7];

%% Stampa dei campioni di test su file
samplesf=fopen("fft_vectors.txt", "w");
for i=1:size(x,1)
    fprintf(samplesf, "%6d ", round(real(x(i,:))*MAX));
    fprintf(samplesf, "\n");
    fprintf(samplesf, "%6d ", round(imag(x(i,:))*MAX));
    if i~=size(x,1) fprintf(samplesf, "\n"); end
end
fclose(samplesf);

%% Lettura dei campioni generati dalla FFT
resultsf="fft_results.txt";
Y=readmatrix(resultsf);
Y=Y/MAX;

%% Generazione dei grafici
close all;
for i=0:1
    if i==0 figure(1); else figure(2); end 
    for j=0:3
        % FFT dei segnali
        X=fft(x(4*i+j+1,:),N); 
        % traslo i vettori affinché le componenti 
        % DC si trovino al centro dello spettro
        X=fftshift(X);
        % grafico del segnale nel tempo
        subplot(4,2,2*j+1);
        hold on;
        stem(t, real(x(4*i+j+1,:)));
        stem(t, imag(x(4*i+j+1,:)));
        hold off;
        title(t0(4*i+j+1));
        legend("Re(x)", "Im(x)");
        grid
        % grafico dello spettro in frequenza
        subplot(4,2,2*j+2); 
        hold on;
        stem(f, abs(X));
        stem(f, abs(Y(4*i+j+1,:)));
        hold off;
        title(t1(4*i+j+1));
        legend("MATLAB", "FFT\_1616");
        grid
    end
    sgtitle("Simulazione FFT (N=" + num2str(N) + ...
            ", Fs=" + num2str(k) + "*freq)");
end