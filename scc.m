% segment consistency check (SCC)
% Segmentation (by Mean Shift) Plus Mode Area Algorithm

 % INPUT
 %   I the Reference Image
 %   D initial disparity map
 %   hs - spatial bandwith for mean shift analysis
 %   hr - range bandwidth for mean shift analysis
 %   M  - minimum size of final output regions for mean shift
 %   moda_thresh - threshold [(moda-moda_thresh), moda, (moda+moda_tresh)]
 %   gammas = gamma_c - a constant of color similarity for bilateral filter
 %   and
 %   gamma_p a constant of proximity similarity for bilateral filter
 %   dim_x window size in X for bilateral filter
 %   dim_y window size in Y for bilateral filter
 %
 % OUTPUT
 %   D_out disparity values
 %
 
 % Reference:
 %
 % [1] Gabriel Vieira, F. A. A. M. N. Soares, G. T. Laureano, R. T. Parreira 
 % and J. C. Ferreira, "A Segmented Consistency Check Approach to Disparity 
 % Map Refinement," in Canadian Journal of Electrical and Computer Engineering, 
 % vol. 41, no. 4, pp. 218-223, Fall 2018, doi: 10.1109/CJECE.2019.2890986.
 %
 % [2] G. d. S. Vieira, F. A. A. M. N. Soares, G. T. Laureano, 
 % R. T. Parreira, J. C. Ferreira and R. Salvini, 
 % "Disparity Map Adjustment: a Post-Processing Technique," 2018 IEEE 
 % Symposium on Computers and Communications (ISCC), 2018, pp. 00580-00585, 
 % doi: 10.1109/ISCC.2018.8538562.
 
 % D. Comaniciu and P. Meer, Mean shift: A robust approach toward feature space analysis
 % IEEE Transactions on Pattern Analysis and Machine Intelligence, 24:603–619, 2002
 %
 % [3] EDISON code
    %  http://www.caip.rutgers.edu/riul/research/code/EDISON/index.html
 % [4] Shai's mex wrapper code
    %  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html
 
 % Example
 % with bilateral filter
 % I1 = imread('scene1.row3.col3.ppm');
 % D1 = imread('raw_map_1x1.png');
 % [D_out1, D_out_holes1] = scc(I1,D1,7,7,5,1,[23,14],39,39);
 % figure; imshowpair(D1,D_out1, 'montage')
 %
 % with bilateral filter no spatial
 % I1 = imread('scene1.row3.col3.ppm');
 % D2 = imread('raw_map_3x3.png');
 % [D_out2, D_out_holes2] = scc(I1,D2,7,7,5,1,[23],39,39);
 % figure; imshowpair(D2,D_out2, 'montage')
 %
 
 % Prepared by: Gabriel da Silva Vieira, Brazil (Jan 2018)

function [D_out, D_holes] = scc(I, D, hs, hr, M,...
    moda_thresh, gammas, dim_x, dim_y)

I = double(I);
D = double(D);

big_number = 1000;

% Mean-shift segmentation algorithm
[~, L_I1_2] = mex_shawn(I,hs,hr,M);

% For each segment we put the best disparity
D(isnan(D)) = 0;
D_out = zeros(size(I,1),size(I,2));
segments_id = unique(L_I1_2);
labels = double(L_I1_2);
d_segments = D;
for i=1:length(segments_id)
    % select a segment one by one
    labels(labels ~= segments_id(i)) = NaN;
    % remove those segments which are not considered
    d_segments(isnan(labels)) = NaN;
    % it avoids that the mode == 0;
        d_segments_2 = d_segments;
        d_segments_2(d_segments_2 == 0) = NaN;
        segment_mode = mode(d_segments_2(:));
    % put the mode to the segment
    
    d_segments((d_segments > segment_mode+moda_thresh | d_segments < segment_mode-moda_thresh) & ~isnan(d_segments)) = big_number;
    d_segments((d_segments <= segment_mode+moda_thresh & d_segments >= segment_mode-moda_thresh) & ~isnan(d_segments)) = segment_mode;
    % prepare to make the composite, it is necessary because NaN + Int == NaN
    d_segments(isnan(d_segments)) = 0;
    % the segments composite
    D_out = D_out + d_segments;
    
    labels = double(L_I1_2);
    d_segments = D;
end

D_out(D_out >= big_number) = NaN;
D_out(D_out == 0) = NaN;

D_holes = D_out;

% Fill in holes;
if size(gammas,2) == 1
    D_out = weight_disp_bl_no_spatial_v2(I,D_out,gammas(1),dim_x,dim_y); 
elseif size(gammas,2) == 2
    D_out = weight_disp_bl_v2(I,D_out,gamma(1),gammas(2),dim_x,dim_y); 
end

end
