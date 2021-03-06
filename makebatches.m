% Version 1.000
%
% Code provided by Ruslan Salakhutdinov and Geoff Hinton
%
% Permission is granted for anyone to copy, use, modify, or distribute this
% program and accompanying programs and documents for any purpose, provided
% this copyright notice is retained and prominently displayed, along with
% a note saying that the original programs are available from our
% web page.
% The programs and documents are distributed without any warranty, express or
% implied.  As the programs were written for research purposes only, they have
% not been tested to the degree that would be advisable in any important
% application.  All use of these programs is entirely at the user's own risk.

fg = conf();
digitdata=[];
clean_digitdata=[];
env = fg.env;
fprintf('load mctrain and clean now...\n'); 
flist = fopen(fg.train_list);
flist_clean = fopen(fg.clean_list); 
filename = fgetl(flist);
filename_clean = fgetl(flist_clean);
index=0
while ischar(filename)
    load([fg.train_dir, env,filename,'.mat']);
    f=fopen([fg.features_input_dir, filename_clean],'r');
    nSamples = fread(f,1,'int','b');
    fclose(f);
    E=D(1:nSamples-8,:);
    digitdata = [digitdata; E];
    load([fg.train_clean_dir,filename_clean,'.mat']);
    clean_digitdata = [clean_digitdata; D];
    filename=fgetl(flist);
    filename_clean = fgetl(flist_clean);
    index=index+1;
    if (mod(index,100) == 0)
        fprintf('\n %d ', index);
    end
    fprintf('.');
end
fclose(flist);
fclose(flist_clean);
fprintf('\n');

totnum=size(digitdata,1);
fprintf(1, 'Size of the mctrain dataset= %5d \n', totnum);

rand('state',0); %so we know the permutation of the training data
randomorder=randperm(totnum);

batchsize = 256;
numbatches=totnum/batchsize;
numdims  =  size(digitdata,2);
disp(numdims);
batchdata = zeros(batchsize, numdims, numbatches);

for b=1:numbatches
    batchdata(:,:,b) = digitdata(randomorder(1+(b-1)*batchsize:b*batchsize), :);
end;

fprintf('save mctrain batchdata now...\n');
save(fg.batchdata, 'batchdata', '-v7.3');

clear digitdata;
clear batchdata;

totnum=size(clean_digitdata,1);
fprintf(1, 'Size of the clean dataset= %5d \n', totnum);

rand('state',0); %so we know the permutation of the training data
randomorder=randperm(totnum);

numbatches=totnum/batchsize;
numdims  =  size(clean_digitdata,2);
disp(numdims);
clean_batchdata = zeros(batchsize, numdims, numbatches);

for b=1:numbatches
    clean_batchdata(:,:,b) = clean_digitdata(randomorder(1+(b-1)*batchsize:b*batchsize), :);
end;

fprintf('save clean digitdata and batchdata now...\n');
save(fg.clean_batchdata, 'clean_batchdata', '-v7.3');

clear clean_digitdata; 
clear clean_digitdata;

%%% Reset random seeds 
rand('state',sum(100*clock)); 
randn('state',sum(100*clock));
