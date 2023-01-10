
close all;

G = 20*log10(3);
fc = 4000;
Fs = 32000;
Q = 1;


type = 'Base_Shelf';
[b, a] = shelving(G, fc, Fs, Q, type);


type = 'Treble_Shelf';
[d, c] = shelving(G, fc, Fs, Q, type);

t = 0:1/Fs:1-1/Fs;
x = 0.5*sin(2*pi*4000*t+pi/2);
y = filter(b,a, x);
z = filter(d,c, x);

figure(1);
plot(t, x, t, y, t, z)
legend('x', 'y', 'z');

% evoluzione operatori interni al filtro A(z) nel tempo
[S0,S1,S2,S3,M0,M1,M2,M3,M4,R0,R1]=deal(zeros(1,length(t)));
for i=1:length(t)
    M1(i)=R0(i)*c(2);
    M2(i)=R0(i)*d(2);
    M3(i)=R1(i)*c(3);
    M4(i)=R1(i)*d(3);

    S2(i)=M1(i)+M3(i);
    S3(i)=M2(i)+M4(i);
    S0(i)= x(i)-S2(i);
    M0(i)=S0(i)*d(1) ;
    S1(i)=M0(i)+S3(i);

    if i~=length(t) 
        R1(i+1)=R0(i); 
        R0(i+1)=S0(i);
    end
end

% grafico evoluzioni per verificare massimi e minimi valori
figure(2);
plot(t,x,t,S0,t,S1,t,S2,t,S3,t,M0,t,M1,t,M2,t,M3,t,M4,t,R0,t,R1);
legend('x','s0','s1','s2','s3','m0','m1','m2','m3','m4','r0','r1');
