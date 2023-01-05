%% definizione dei segnali di test e dei campioni corrispondenti
% parametri generali
freq=5; % frequenza
k=8; % fattore moltiplicativo per Fs
Fs=k*freq; % frequenza di campionamento
N=16; % Numero di campioni nella FFT
t=(0:(N-1))/Fs; % intervallo temporale
df=Fs/N; % risoluzione in frequenza
f=(-N/2:(N/2-1))*df; % intervallo in frequenza

% definizione funzione seno
A0=1; % ampiezza dell'onda
phi0 = 30*pi/180; % fase dell'onda
x0=A0*sin(2*pi*freq*t+phi0); % funzione seno

% definizione onda quadra
A1=0.7;
phi1=90*pi/180; % fase dell'onda
x1=A1*square(2*pi*freq*t+phi1);

% definizione onda a dente di sega
A2=0.5;
x2=A2*sawtooth(2*pi*freq*t);

% definizione funzione porta
A3=1;
x3=zeros(1,N); x3(N/2-N/8:N/2+N/8)=1;
x3=A3*x3;

% definizione funzione Delta di Dirac
A4=1;
x4=zeros(1,N); x4(1)=1;
x4=A4*x4;

% definizione funzione Delta di Dirac
A5=1;
x5=zeros(1,N); x5(N/2-N/8)=1; x5(N/2+N/8)=-1;
x5=A5*x5;

% definizione funzione Delta di Dirac
A6=1;
x6=zeros(1,N); x6(N/2-N/8)=1; x6(N/2+N/8)=-1;
x6=A6*x6;

% definizione funzione sinusoide complessa
A7=1;
x7=A7*exp(1i*2*pi*freq*t);

x=[x0; x1; x2; x3; x4; x5; x6; x7]; % Matrice con i vari segnali
t0=["Onda sinusoidale", ...
    "Onda quadra", ...
    "Onda triangolare", ...
    "Funzione porta", ...
    "Funzione Delta di Dirac", ...
    "Funzione Delta di Dirac", ...
    "Funzione Delta di Dirac", ...
    "Onda sinusoidale complessa"];
t1=["FFT onda sinusoidale", ...
    "FFT onda quadra", ...
    "FFT onda triangolare", ...
    "FFT funzione porta", ...
    "FFT funzione Delta di Dirac", ...
    "FFT funzione Delta di Dirac", ...
    "FFT funzione Delta di Dirac", ...
    "FFT onda sinusoidale complessa"];

close all;
for i=0:1
    if i==0 figure(1); else figure(2); end 
    for j=0:3
        % FFT dei segnali
        X=fft(x(4*i+j+1,:),N); 
        % Normalizzo gli spettri per ottenere armoniche
        % con ampiezze congruenti con i segnali nel tempo
        if i~=1 || j~=0 X=X/N; end
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
        stem(f, abs(X));
        title(t1(4*i+j+1));
        legend("MATLAB", "FFT_1616.vhd");
        grid
    end
    sgtitle("Simulazione FFT (N=" + num2str(N) + ...
        ", Fs=" + num2str(k) + "*freq)");
end