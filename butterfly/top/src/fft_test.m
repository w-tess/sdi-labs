%% definizione dei segnali di test per la FFT
%% parametri generali
freq=5; % frequenza
k=8; % fattore moltiplicativo per Fs
Fs=k*freq; % frequenza di campionamento
L=16; % Numero di campioni nella FFT
t=(0:(L-1))/Fs; % intervallo temporale
df=Fs/L; % risoluzione in frequenza
f=(-L/2:(L/2-1))*df; % intervallo in frequenza
MAX=2^15-1;
% nomi da fornire ai grafici
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

%% generazione dei twiddle factor per la FFT 16x16
% definizione dei due vettori per i coefficienti
% reali e immaginari
W = zeros(8,2);
nrows = size(W,1);

for i = 0:nrows-1
    W(i+1,1) = round(cos(2*pi*i/L)*MAX);
    W(i+1,2) = round(-sin(2*pi*i/L)*MAX);
end

%% definizione funzione seno
phi0 = 30*pi/180; % fase dell'onda
x0=sin(2*pi*freq*t+phi0); % funzione seno

%% definizione onda quadra
phi1=90*pi/180; % fase dell'onda
x1=square(2*pi*freq*t+phi1);

%% definizione onda a dente di sega
x2=sawtooth(2*pi*freq*t);

%% definizione funzione porta
x3=zeros(1,L); x3(1:L*5/16)=1;

%% definizione funzione Delta di Dirac
x4=zeros(1,L); x4(1)=1;

%% definizione funzione Delta di Dirac 2
x5=zeros(1,L); x5(L/2-L/8)=1; x5(L/2+L/8)=-1;

%% definizione funzione sinusoide complessa
x6=exp(1i*2*pi*freq*t);

%% definizione funzione sinusoidale complessa rumorosa
A7=0.25;
x7=A7*exp(1i*2*pi*freq*t) + A7*exp(-1i*2*pi*3/2*freq*t);
x7=x7 + (0.18)*(1+1i)*randn(size(t));

%% matrice con i vari segnali
x=[x0; x1; x2; x3; x4; x5; x6; x7];

%% stampa dei campioni di test su file
if L==16
    samplesf=fopen("fft_vectors.txt", "w");
    for i=1:size(x,1)
        fprintf(samplesf, "%6d ", round(real(x(i,:))*MAX));
        fprintf(samplesf, "\n");
        fprintf(samplesf, "%6d ", round(imag(x(i,:))*MAX));
        if i~=size(x,1) fprintf(samplesf, "\n"); end
    end
    fclose(samplesf);
end

%% esecuzione eseguibile di "tb_fft_1616.vhd"
if L==16
    system("tb_fft_1616.exe");
end
%% lettura dei campioni generati dalla FFT
if L==16
    resultsf="fft_results.txt";
    Y=readmatrix(resultsf);
    Y=Y/MAX;
    for i=0:7
        for j=1:16
            Y(i+1,j)=Y(2*i+1,j) + Y(2*i+2,j)*1i;
        end
    end
end
%% calcolo FFT di confronto
close all;
% calcolo la fft su MATLAB
X=fft(x,L,2);
% traslo la componente DC dei due spettri
% al centro del range di interesse
X=fftshift(X,2);
if L==16 Y=fftshift(Y,2); end
%% generazione dei grafici
for i=0:1
    if i==0 figure(1); else figure(2); end
    for j=0:3
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
        stem(f, abs(X(4*i+j+1,:)));
        if L==16 stem(f, abs(Y(4*i+j+1,:))); end
        hold off;
        title(t1(4*i+j+1));
        legend("MATLAB", "FFT\_1616");
        grid
    end
    sgtitle("Simulazione FFT (N=" + num2str(L) + ...
            ", Freq=" + num2str(freq) + ...
            "Hz, Fs="   + num2str(k) + "*freq)");
end
