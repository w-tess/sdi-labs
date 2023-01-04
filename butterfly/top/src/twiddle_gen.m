% generazione dei twiddle factor per la FFT 16x16
% definizione dei due vettori per i coefficienti
% reali e immaginari
W = zeros(8,2);
nrows = size(W,1);
% numero di campioni
N = 16;
% massimo valore assoluto intero
MAX = 2^15-1;

for i = 0:nrows-1
    W(i+1,1) = round(cos(2*pi*i/N)*MAX);
    W(i+1,2) = round(-sin(2*pi*i/N)*MAX);
end
