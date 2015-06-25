function imgs = read_frames(dirname, fmt, start_frame, end_frame, step)
% Reads video frames that have been written as images.
% fmt: 'png', 'jpg'

d = dir([dirname filesep '*.' fmt]);
if isempty(d) || length(d) <= 0
    fprintf('Read 0 frames.\n');
    keyboard;
    return;
end
img = imread([dirname filesep d(1).name]);
fprintf('frame size: ');
size(img)
fprintf('frame num: %d\n', length(d)); 

if ~exist('start_frame', 'var')
    start_frame = 1;
end

if ~exist('end_frame', 'var')
    end_frame = length(d);
end

if ~exist('step', 'var')
    step = 1;
end

fprintf('Read frame: start = %d, end = %d, step = %d\n', ...
    start_frame, end_frame, step);
frame_idx = start_frame:step:end_frame;
n = length(frame_idx);
imgs = zeros(size(img, 1), size(img, 2), 3, n, 'uint8');
for i = 1:n
    imgs(:,:,:,i) = imread([dirname filesep d(frame_idx(i)).name]);
end
fprintf('Read %d frames.\n', size(imgs, 4));
end
