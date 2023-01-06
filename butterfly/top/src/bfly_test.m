%% generazione di 10000 vettori di test, ciascuno 
%  costituito da 6 valori rappresentati da interi
%  su 16 bit, nel range +/- (2^15-1)
MAX=2^15-1;
randvect = randi([-MAX, MAX], 10000, 6, "int16");

%% definizione di vettori di test personali
custvect = zeros(8,6);
custvect(1,:) = MAX;
custvect(2,:) = -MAX;
custvect(3,:) = 0;
custvect(4,:) = MAX; custvect(4,6) = -MAX;
custvect(5,:) = MAX; custvect(5,4) = -MAX;
custvect(6,:) = MAX; custvect(6,3) = -MAX;
custvect(7,:) = MAX; custvect(7,3:4) = -MAX;
custvect(8,:) = MAX; custvect(8,2) = -MAX;

%% unione delle due matrici
allvect = [randvect;custvect];
nrows = size(allvect,1);

%% scrittura dei vettori di test su file
f = fopen("bfly_vectors.txt", "w");
for i = 1:nrows
    fprintf(f,"%6d ",allvect(i,:));
    if i~=nrows fprintf(f, "\n"); end
end
fclose(f);

%% esecuzione eseguibile di "tb_butterfly.vhd"
!tb_butterfly.exe &