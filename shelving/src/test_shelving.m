%% script per la simulazione dell'audio processor
%% definizione dei parametri per i filtri
close all;
V0=2; % amplificazione/attenuazione
G = 20*log10(V0); % guadagno in dB
fc = 4000; % frequenza di taglio
Fs = 32000; % frequenza di campionamento
f = 2000; % frequenza dell'onda
Q = 1; % fattore di qualita'
N = 1000; % numero di campioni
SW = 3; % modalita' operativa
t = 0:1/Fs:(N-1)/Fs; % campioni temporali

%% definizione campioni
x = 0.5*sin(2*pi*f*t+pi/2);

%% definizione dei coefficienti per i filtri
type = 'Base_Shelf';
[bl, al] = shelving(G, fc, Fs, Q, type);

type = 'Treble_Shelf';
[bh, ah] = shelving(G, fc, Fs, Q, type);

%% stampa dei coefficienti su file
coeff = [al(2:end) bl ah(2:end) bh];
coefff = fopen("shelving_coefficients.txt", "w");
for i=1:size(coeff,2)
    fprintf(coefff, "%d ", round(coeff(i)*(2^11-1)/8));
    if i==size(coeff,2) fprintf(coefff, "\n"); end
end
% stampa della modalita' operativa
fprintf(coefff, "%d", SW);
fclose(coefff);

%% stampa campioni su file
samplesf = fopen("shelving_samples.txt", "w");
for i=1:size(x,2)
    fprintf(samplesf, "%d", round(x(i)*(2^7-1)*2));
    if i~=size(x,2) fprintf(samplesf, "\n"); end
end
fclose(samplesf);

%% esecuzione eseguibile di "tb_audio_proc.vhd"
system("tb_audio_proc.exe");

%% lettura risultati da file
resultsf = fopen("shelving_results.txt", "r");
y1 = fscanf(resultsf, "%d ", [1 size(x,2)]);
% normalizzo i risultati ottenuti
if SW==2 || SW==3 
    y1 = y1/(2^(8-3));
else 
    y1=y1/((2^7-1)*2);
end
fclose(resultsf);

%% generazione risultati del filtro su MATLAB
if SW==2
    y0 = filter(bl,al, x);
elseif SW==3
    y0 = filter(bh,ah, x);
end

%% generazione grafici con i risultati ottenuti
figure(1);
hold on
plot(t, x);
plot(t, y1);
if SW==2 || SW==3 plot(t, y0); end
hold off
legend('x', 'audio\_proc', 'MATLAB');
title("Simulazione audio\_proc: " + ...
      "f=" + num2str(f) + ...
      "Hz, fc=" + num2str(fc) + ...
      "Hz, fs=" + num2str(Fs) + ...
      "Hz, V0=" + num2str(V0) + ...
      ", SW=" + num2str(SW))

%% SEZIONE PER TEST SU VIRTLAB 
% rappresentazione primi 10 campioni in esadecimale
% insieme ai primi 10 campioni dei filtri
x_hex = dec2hex(round(x(1:9)*(2^7-1)*2));
if SW==2 || SW==3
    y0_hex = dec2hex(round(y0(1:9)*(2^(8-3))));
end