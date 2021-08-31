
% It is an example of using the code

addpath(genpath('edison_matlab_interface'));

I1 = imread('scene1.row3.col3.ppm');
D_before = imread('raw_map_3x3.png');
[D_after, D_after_with_holes] = scc(I1,D_before,7,7,5,1,[23],39,39);

figure; imagesc(D_after_with_holes); colormap gray
figure; imshowpair(D_before, D_after, 'montage')