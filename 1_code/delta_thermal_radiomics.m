%% FILENAME :         deltarad_figures.m
%
% DESCRIPTION : Matlab script to analyze outputs from 3DSlicer pyradiomics
% calculations for radiomics of segmented thermograms. The xlxs spreadsheet
% consists of 2 worksheets for the image biomarkers, before and after
% milking. 
%        
%
% NOTES :
%
% AUTHOR :  (c) Parminder S. Basran       START DATE :    6-Oct-2021
%           psb92@cornell.edu
%           Cornell University - Collge of Veterinary Medicine
%
% CHANGES :
%
% REF NO  VERSION   DATE            DETAIL
% V1.0             24-Jan-2022     Published version   
%
%% Set paths, defaults and other settings here
clearvars;
% Location of CSV files for processing

% edit the path where the files are located
xlsflnm = '../0_data/TestData/delta_thermo_radiomics.xlsx'; 

%% Load before and after radiomics data

[NUMb,TXTb,~]=xlsread(xlsflnm,'before');
[NUMa,TXTa,~]=xlsread(xlsflnm,'after');

% parse out the feature names from the TXT data
for i = 24 : 874
    
    featnames{i-23} = strcat(TXTa{i,1},'_',TXTa{i,2},'_',TXTa{i,3});
    
end

% Parse pre/post milking features from the NUM data
PRE = NUMb(12:862,:)';
PST = NUMa(12:862,:)';

% Clean up a bit
clear NUMb NUMa TXTa TXTb i

%% Compute some statistics / analyze this data

% Compute t-scores

[h, p] = ttest2(PRE,PST);

% find significant p ... < 0.01
t_sig = find(p<0.01);


% Check Cohens d-score, w/ small sample correction
d = ( ( mean(PRE) - mean(PST) ) ./ std([PRE; PST]) ) * (18 - 3) * sqrt((18 -2)/20) / (18 - 2.25);
% find large effect size d > 0.8
d_sig = find(abs(d) > 0.8);

% 1-2nd order features are up to 107, all = 851
t_sig_n = t_sig(t_sig < 851);
d_sig_n = d_sig(d_sig < 851);

% Find features that interset both p<0.01 and d > 0.8
com_feat = intersect(t_sig_n, d_sig_n);

% print it out 
for i = 1 : length(com_feat)
    
    fprintf('\n%s: p = %f, d = %f',featnames{com_feat(i)},p(com_feat(i)),d(com_feat(i)));

end

fprintf('\n');

%% Compute correlation map
diff = abs(PRE-PST);
cdiff= corr(diff(:,1:109));
imagesc(cdiff); colorbar
% 25 is mean
figure(2);
plot(cdiff(:,25));

%featnames{[29 44 47 76] }
%   'original_firstorder_Skewness' 
%   'original_glcm_Idmn'
%   'original_glcm_Imc2'
%   'original_glrlm_LongRunHighGrayLevelEmphasis'
% featnames{18} = first order entropy


