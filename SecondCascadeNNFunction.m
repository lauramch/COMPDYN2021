function [y1] = myNeuralNetworkFunction(x1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 29-Mar-2021 15:15:44.
%
% [y1] = myNeuralNetworkFunction(x1) takes these arguments:
%   x = 6xQ matrix, input #1
% and returns:
%   y = 3xQ matrix, output #1
% where Q is the number of samples.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [2;3.05;0;0.002;0.025;5.5];
x1_step1.gain = [0.0336134453781513;0.125391849529781;0.0455580865603645;20.8333333333333;1.1142061281337;0.689655172413793];
x1_step1.ymin = -1;

% Layer 1
b1 = [2.3912388513114160027;1.3607679944611925649;1.4047119662541545093;1.3388055840195240975;-0.14679191952645290198;-0.45961058956253175722;1.1764084291863603493;1.6837164019926762482;1.7933919689399588915;1.4907640893530658133];
IW1_1 = [-1.8300142932790577355 2.9981967005164076312 0.54213746511856808485 0.35327502562371615458 1.048639227496478199 -0.70648932937500863449;-0.093876821204444571567 -0.3339231690263060881 -1.6275947386598890176 1.1451940206371118425 -1.4330383781312590052 0.72905924869534333155;-0.18871345404342002028 1.7576769323131502532 0.94307615511299380806 1.5766754749075384545 -1.7982985165414533402 0.26566314435379223546;-2.2069416268161079486 -1.1570839977375895202 -0.37174938080490121939 -0.93048101683758588365 0.61920245400502471611 1.0834004898484113077;4.2236476657817068059 -0.86580590256278222583 1.4996625791782658421 -0.066912457082509715911 0.81104565612352419457 4.1136239573680875026;0.45136865736858533538 -1.1488706620332600483 0.84746950691195199745 0.71119954501310167494 1.0305666529574253332 -0.60428919145038439975;3.0526513404941306717 1.3276701606421166257 -2.4173384031463034383 -0.97996646928913422325 -0.064287055440664653272 -3.8318997461496131507;0.3322874962773254004 1.3939777050532582425 -0.52723119433674092704 -0.6319403965278073132 3.1549538299539805486 -0.17281525877460476859;0.29121405039952608096 0.50409811747434163376 0.65808384594888713615 -1.1047061145350141054 1.0778524858280775778 1.7954360176059107612;0.85839098048765927196 1.5969398475744092103 -0.61878977908106913564 0.93133441218697710084 -0.28941348166120411944 1.3763308446808644181];

% Layer 2
b2 = [0.32573423002089163525;-0.67194609137442296021;0.65156132802286814698];
LW2_1 = [-2.3271916592840748983 -0.067600593600838518316 0.94544175006909636494 1.6663345346706297523 3.5704088475706012851 0.05680792395958725316 2.8709822744006232575 0.58197154663912054051 0.3346760537208391395 0.39682908337224231943;0.56467008951156238972 -1.0852905177795397762 -0.43022462458838856003 1.0042297776524431452 -1.0247683480848968074 -0.74223312492904458537 -0.59105909480698826108 -1.1868021701791720002 -1.9588512870485781381 1.3921865901511254471;-0.63834840749719778952 0.9455021757542955152 -0.98970529406174623244 -2.6194545229425583166 -2.9669904407535345747 0.39877479029698165158 -2.440733911379416643 -0.20158042276188001263 0.16594182546220953567 -0.93529744427706307253];

% ===== SIMULATION ========

% Dimensions
Q = size(x1,2); % samples

% Input 1
xp1 = mapminmax_apply(x1,x1_step1);

% Layer 1
a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*xp1);

% Layer 2
a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);

% Output 1
y1 = a2;
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n,~)
if isa(n,'gpuArray')
    a = iSoftmaxApplyGPU(n);
else
    a = iSoftmaxApplyCPU(n);
end
end
function a = iSoftmaxApplyCPU(n)
nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);
numerator = exp(n);
denominator = sum(numerator,1);
denominator(denominator == 0) = 1;
a = bsxfun(@rdivide,numerator,denominator);
end
function a = iSoftmaxApplyGPU(n)
nmax = max(n,[],1);
numerator = arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
denominator = sum(numerator,1);
a = arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
end
function numerator = iSoftmaxApplyGPUHelper1(n,nmax)
numerator = exp(n - nmax);
end
function a = iSoftmaxApplyGPUHelper2(numerator,denominator)
if (denominator == 0)
    a = numerator;
else
    a = numerator ./ denominator;
end
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end
