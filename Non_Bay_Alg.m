clc;
clear;
close all;

%% creating the reference symbols QAM symbols
M = 8; % Modulation order
N = 15; %Number of metasurfaces
NE = 4; %Number of eavsdroppers
Symbol_M = zeros(M,N); % To repeat the symbols

S = zeros(M,N,NE); % The combination of Metasurface responses and symbols 
l = zeros(M,M,NE); % Conditional probability distribution
MS = zeros(NE,N); % Response of the metasurfaces for each eavesdropper

% Create the symbols matrix
% xref = qammod([0:M-1],M,'UnitAveragePower',true);
% sigpower = pow2db(mean(abs(symbols).^2));
% xref = xref*exp(1j*pi/4);
symbol(1) = 1*exp(1j*0);
symbol(2) = 1*exp(1j*pi/2);
symbol(3) = 1*exp(1j*pi);
symbol(4) = 1*exp(1j*wrapTo2Pi(3*pi/2));

symbol = [symbol*exp(1j*pi/4),symbol];
% s= polarscatter((angle(symbol)),abs(symbol),'filled','b')
% rticks([0 1])
% s.SizeData = 100
% set(gca,'FontSize',18);


rad2deg(wrapTo2Pi(angle(symbol)))



% Create the Metasurfaces response for each eavesdropper
MS(1,:) = [pi/4,3*pi/4,5*pi/4,7*pi/4,0,pi/2,pi,3*pi/2,3*pi/2,3*pi/2,pi/4,3*pi/2,3*pi/2,3*pi/2,pi/4];
MS(2,:) = [pi,pi/2,pi/4,3*pi/4,7*pi/4,0,3*pi/2,5*pi/4,0,pi/2,pi/2,5*pi/4,0,pi/2,pi/2];
MS(3,:) = [pi/2,pi/2,pi/4,3*pi/4,7*pi/4,0,0,5*pi/4,0,3*pi/2,pi/2,5*pi/4,0,7*pi/4,pi/4];
MS(4,:) = [pi/4,pi/2,pi/4,7*pi/4,0,0,0,5*pi/4,0,3*pi/2,3*pi/2,7*pi/4,0,7*pi/4,pi/4];
% The combination of Metasurface responses and symbols 
for e=1:NE
S(:,:,e) = symbol'.* 1*exp(1j*MS(e,:));
end
S(find(round(rad2deg(wrapTo2Pi(angle(S)))) == 360)) = 1*exp(1j*0);
% Sdemod = qamdemod(S,M);
% S_real =  interp1(real(symbol), real(symbol), real(S), 'nearest','extrap');
% S_imag =  interp1(imag(symbol), imag(symbol), imag(S), 'nearest','extrap');
% 
% S_temp = S_real + S_imag*1i;

rad2deg(wrapTo2Pi(angle(S)))



% The distribution for each eavesdropper l( . |theta)
l=zeros(M,M,NE);
for e=1:NE
for i=1:M
    for k=1:M
       % x = imag((S(i,:,e))) == imag(symbol(k)) & real((S(i,:,e))) == real();
        x= round(rad2deg(wrapTo2Pi(angle(S(i,:,e))))) == round(rad2deg(wrapTo2Pi(angle(symbol(k)))));
        l(i,k,e) = sum(x,'all')/N;
        
    end
end
end

% Px = zeros(M,M,NE);
% Px(1,:,1) = [0.5,0.5,0,0]
% px(2,:,1) = [0,0.5,0.5,0]
% px(3,:,1) = [0,0,0.5,0.5]
% px(4,:,1) = [0.5,0,0,0.5]

%Weights matrix A of fully connected network
A = 1/NE * ones(NE,NE);

Beta = 1; %Every agent observes new informtion at every iteration

%Update parameter
delta=0.9;


%%
MaxIt = 300;
mu = zeros(NE,MaxIt,M); % Matrix of beliefs for all eavesdroppers as function of time
mu(:,1,:) = 1/M;
so = zeros(1,MaxIt); %observation of eavesdroppers for each time
z=zeros(NE,MaxIt);
% tempso= zeros(1,MaxIt);
%The belifes calculations for one symbol theta

theta_star = 2;

so = zeros(NE,MaxIt);
    for it=2:MaxIt

        if it == 50
            theta_star = 3;
        end

         if it == 140
            theta_star = 6;
         end

           if it == 200
            theta_star = 4;
        end

        tempso= randperm(numel(S(1,:,1)));%or just select an indicies

        for e=1:NE
        %so(e,it) =  randsample(S(theta,:,e),1); % Observation that eavesdropper e sees at time it
       
        so(e,it) = find(round(rad2deg(wrapTo2Pi(angle(symbol)))) == round(rad2deg(wrapTo2Pi(angle(S(theta_star,tempso(1),e))))));
        
        for p=1:M
            temp(p) = prod((mu(:,it-1,p).^(1*(1-delta)/NE)*l(so(e,it),p,e).^(1-delta)));
        end
        
        z(e,it) = sum(temp);
        
       for theta=1:M 
        mu(e,it,theta) = (1/z(e,it)) * prod( (mu(:,it-1,theta).^(1*(1-delta)/NE))* l(so(e,it),theta,e).^(1-delta));
        
        
       end        
        end
    end

    %% Results and plots
    %Plotting the beliefs as function of time
figure
plot(1:MaxIt,mu(:,1:MaxIt,2),'Linewidth',2.4)
hold on
xline(100)
ylabel('\mu(X)')
xlabel('iteration number')
set(gca,'FontSize',21);
grid on
legend("Eve1","Eve2","Eve3","Eve4")


figure
for pe=2:2:6
plot(1:MaxIt,mu(1,1:end,pe),'Linewidth',2.4)
hold on
end
xline(100)
ylabel('\mu(X)')
xlabel('iteration number')
set(gca,'FontSize',21);
grid on
legend ("X_2","X_4","X_6")%,"X_3","X_4","X_5","X_6","X_7","X_8")




% plotting the conditional probability distributions

% ylabel('\mu(X)')
% xlabel('iteration number')
% X = categorical({'X_1','X_2','X_3','X_4','X_5','X_6','X_7','X_8'});
% X = reordercats(X,{'X_1','X_2','X_3','X_4','X_5','X_6','X_7','X_8'});
% bar(X,[l(3,:,1);l(3,:,2);l(3,:,3)]')
% ylim([0, 0.5])
% set(gca,'FontSize',21);
% legend ("l^{1}(.|X_{3})","l^{2}(.|X_{3})","l^{3}(.|X_{3})")

