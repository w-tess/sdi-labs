% generazione di 10000 vettori di test, ciascuno 
% costituito da 6 valori rappresentati da interi
% su 16 bit, nel range +/- (2^15-1)
randvect = randi([-(2^15-1), 2^15-1], 10000, 6, "int16");
% definizione di vettori di test personali
custvect = zeros(8,6);
custvect(1,:) = 2^15-1;
custvect(2,:) = -(2^15-1);
custvect(3,:) = 0;
custvect(4,:) = 2^15-1; custvect(4,6) = -(2^15-1);
custvect(5,:) = 2^15-1; custvect(5,4) = -(2^15-1);
custvect(6,:) = 2^15-1; custvect(6,3) = -(2^15-1);
custvect(7,:) = 2^15-1; custvect(7,3:4) = -(2^15-1);
custvect(8,:) = 2^15-1; custvect(8,2) = -(2^15-1);
% unione delle due matrici
allvect = [randvect;custvect];
nrows = size(allvect,1);
% scrittura dei vettori di test su file
f = fopen("bfly_vectors.txt", "w");
for i = 1:nrows
    if i ~= nrows
        fprintf(f,"%6d %6d %6d %6d %6d %6d\n",allvect(i,:));
    else
        fprintf(f,"%6d %6d %6d %6d %6d %6d",allvect(i,:));
    end
end
fclose(f);