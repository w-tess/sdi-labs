% generazione di 10000 vettori di test, ciascuno 
% costituito da 6 valori rappresentati da interi
% su 16 bit, nel range +/- (2^15-1)
samples = randi([-(2^15-1), 2^15-1], 10000, 6, "int16");
% scrittura dei vettori di test su file
samplesfile = fopen("test_vectors.txt", "w");
for i = 1:10000
    if i ~= 10000 
        fprintf(samplesfile, "%6d %6d %6d %6d %6d %6d\n", samples(i, :));
    else
        fprintf(samplesfile, "%6d %6d %6d %6d %6d %6d", samples(i,:));
    end
end
fclose(samplesfile);