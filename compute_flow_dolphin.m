%==============================================================================
%
% Computes optical flow for ucf101 video dataset.
%
%==============================================================================
addpath('/home/grad2/shugaoma/local/broxflow');
frame_path = '/research/action_features/thumos2015/thumos15_validation_frames';
flow_path = '/research/action_features/thumos2015/thumos15_validation_flow';

load('thumos2015_val_data.mat');
for i = vid1 : vid2
    try
    frame_dir = [frame_path filesep val_video_list(i).vname];
    if ~exist(frame_dir, 'dir')
        fprintf('Video %d: frames file does not exist.', i);
        continue;
    end
    frame_list = dir([frame_dir filesep '*.jpg']);
    nfms = ceil(length(frame_list) / 2);

    flow_dir = [flow_path filesep val_video_list(i).vname];
    if exist(flow_dir, 'dir')
        flowimg_list = dir([flow_dir filesep '*.jpg']);
        if length(flowimg_list) >= (2 * (nfms - 1))
            fprintf('Video %d: flow already computed.', i);
            continue;
        else
            delete([flow_dir filesep '*.jpg']);
        end
    else
        mkdir(flow_dir);
    end
  
    fprintf('Video %d: compute flow...', i);
    imgs = read_frames(frame_dir, 'jpg');
    imgs = imgs(:,:,:,1:2:end);
    K = 50;
    for k = 1:ceil(nfms / K)
        fprintf('k = %d\n', k);
        if k == 1
            imgs2 = imgs(:,:,:,1:K);
        else
            imgs2 = imgs(:,:,:,(k-1) * K : min(k * K, nfms));
        end
        flow = broxflow(imgs2, 'ransac');
        im_uv = flow2img(flow.u, flow.v);
        im_huhv = flow2img(flow.hu, flow.hv);
        for h = 1:size(im_uv, 4)
            if k == 1
                flow_name = sprintf('%06d', h);
            else
                flow_name = sprintf('%06d', (k-1) * K + h - 1);
            end
            imwrite(im_uv(:,:,:,h), [flow_dir filesep flow_name ...
                '_flow.jpg'], 'jpg', 'Quality', 80);
            imwrite(im_huhv(:,:,:,h), [flow_dir filesep flow_name ...
                '_stable_flow.jpg'], 'jpg', 'Quality', 80);
        end
    end
  
    catch exception
        getReport(exception)
        continue;
    end
    fprintf('finished\n');
end

