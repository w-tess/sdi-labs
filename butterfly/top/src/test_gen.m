% generazione di 10000 vettori di test, ciascuno 
% costituito da 6 valori rappresentati da interi
% su 16 bit, nel range +/- (2^15-1)
randvect = randi([-(2^15-1), 2^15-1], 10000, 6, "int16");
% definizione di vettori di test personali
custvect = zeros(,6);
custvect(1,:) = 2^15-1;
custvect(2,:) = -2^15-1;
custvect(3,:) = 0;
custvect(4,:) = 2^15-1; custvect(4,6) = -2^15-1;
custvect(5,:) = 2^15-1; custvect(5,4) = -2^15-1;
custvect(6,:) = 

allvect = [randvect;custvect];
% scrittura dei vettori di test su file
f = fopen("test_vectors.txt", "w");
for i = 1:10000
    if i ~= 10000 
        fprintf(f,"%6d %6d %6d %6d %6d %6d\n",allvect(i,:));
    else
        fprintf(f,"%6d %6d %6d %6d %6d %6d",allvect(i,:));
    end
end
fclose(samplesfile);