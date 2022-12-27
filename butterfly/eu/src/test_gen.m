% generazione di 10000 vettori di test, ciascuno 
% costituito da 6 valori rappresentati da interi
% su 16 bit, nel range +/- (2^15-1)
samples = randi([-(2^15-1), 2^15-1], 10000, 6, "int16");
% scrittura dei vettori di test su file
samplesfile = fopen("test_vectors.txt", "w");
fprintf(samplesfile, "%6d %6d %6d %6d %6d %6d\n", samples);
fclose(samplesfile);