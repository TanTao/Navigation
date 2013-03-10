close all, clear all;
fprefix = 'data\car4\';
fannote = 'car4.txt';
fext = 'bmp';
s_annotation = strcat(fprefix, fannote);
start_frame = 1;
nframes = 659;

n_row = 3;
n_col = 3;

t_row = 60;
t_col = 75;

patch_row = ceil(t_row / n_row);
patch_col = ceil(t_col / n_col);

hog_bin_size = 5;
hog_n_orient = 9;
hog_index = 1;

particle_num = 200;
particles = zeros(particle_num, 4);
sigma_px = 2;
sigma_py = 2;
sigma_pw = 1;
sigma_ph = 1;

s_frames = cell(nframes, 1);
for i=1:nframes
    image_no = start_frame + i - 1;
    fid = sprintf('%d', image_no);
    s_frames{i} = strcat(fprefix, fid, '.', fext);
end

%for the 1st frame, get the true object
truth = load(s_annotation);
first_loc = truth(1,:);
image_gray = imread(s_frames{1});
if(size(image_gray,3) ~= 1)
    image_gray = rgb2gray(image_gray);
end
[image_h image_w] = size(image_gray);
col_begin = first_loc(1);
row_begin = first_loc(2);
col_width = first_loc(3);
row_height = first_loc(4);
col_end = col_begin + first_loc(3);
row_end = row_begin + first_loc(4);
object = image_gray(row_begin:row_end, col_begin:col_end);
object = imresize(object, [t_row t_col]);
object_patches = im_get_patches(object, n_row, n_col);
hog_row = ceil(t_row/n_row)/hog_bin_size;
hog_col = ceil(t_col/n_col)/hog_bin_size;
hog_feature_len = hog_row*hog_col*hog_n_orient;
HT = zeros(n_row*n_col, 11+hog_feature_len, hog_feature_len);
for i=1:n_row*n_col
    HT(i, 1, :) = my_hog(object_patches(i, :, :), hog_bin_size, hog_n_orient, hog_index);
end
% trival templates
for i=1:n_row*n_col
    HT(i, 12:end, :) = eye(hog_feature_len);
end

State = [col_begin, row_begin, col_width, row_height];
particles(:,1) = State(1) + fix(sigma_px*randn(1,particle_num));
particles(:,2) = State(2) + fix(sigma_py*randn(1,particle_num));
particles(:,3) = State(3) + fix(sigma_pw*randn(1,particle_num));
particles(:,4) = State(4) + fix(sigma_ph*randn(1,particle_num));

for i=2:nframes
    image_gray = imread(s_frames{i});
    if(size(image_gray,3) ~= 1)
        image_gray = rgb2gray(image_gray);
    end
    for j=1:particle_num
        pcol_begin = particles(j,1);
        pcol_end = pcol_begin + particles(j,3);
        prow_begin = particles(j,2);
        prow_begin = prow_begin + particles(j,4);
        object_candidate = image_gray(prow_begin:prow_end, pcol_begin:pcol_end);
        object_candidate = imresize(object_candidate, [t_row t_col]);
        candidate_patches =  im_get_patches(object_candidate, n_row, n_col);
        for k=1:n_row*n_col
            candidate_feature = my_hog(candidate_patches(k,:,:),hog_bin_size, hog_n_orient, hog_index);
            
        end
    end
end