function compute_flow(batch_id)
%==============================================================================
%
% Computes optical flow for ucf101 video dataset.
%
%==============================================================================
addpath('/projectnb/cbsmav/shugao/projects/deepnet/external');
frame_path = '/net/ivcfs1/mnt/ivcfs/action_features/thumos2015/thumos15_validation_frames';
flow_path = '/net/ivcfs1/mnt/ivcfs/action_features/thumos2015/thumos15_validation_flow';

batch_size = 106;
vid1 = (batch_id - 1) * batch_size + 1;
vid2 = vid1 + batch_size - 1;
load('thumos2015_val_data.mat');
for i = vid1 : vid2
    frame_dir = [frame_path filesep val_video_list(i).vname];
    if ~exist(frame_dir, 'dir')
        fprintf('Video %d: frames file does not exist.', i);
        continue;
    end
    frame_list = dir([frame_dir filesep '*.jpg']);
    nfms = length(frame_list);

    flow_dir = [flow_path filesep val_video_list(i).vname];
    if exist(flow_dir, 'dir')
        flowimg_list = dir([flow_dir filesep '*.jpg']);
        if length(flowimg_list) >= (2 * (ceil(nfms/2) - 1))
            fprintf('Video %d: flow already computed.', i);
            continue;
        else
            delete([flow_dir filesep '*.jpg']);
        end
    else
        mkdir(flow_dir);
    end
  
    fprintf('Video %d: compute flow...', i);
   
    K = 100;
    ind = 1;
    for k = 1:ceil(nfms / K)
        if k == 1
            imgs = read_frames(frame_dir, 'jpg', 1, K, 2);
        else
            imgs = read_frames(frame_dir, 'jpg', (k-1) * K - 1, min(k * K, nfms), 2);
        end
        flow = broxflow(imgs, 'ransac');
        im_uv = flow2img(flow.u, flow.v);
        im_huhv = flow2img(flow.hu, flow.hv);
        for h = 1:size(im_uv, 4)
            flow_name = sprintf('%06d', ind);
            imwrite(im_uv(:,:,:,h), [flow_dir filesep flow_name ...
                '_flow.jpg'], 'jpg', 'Quality', 80);
            imwrite(im_huhv(:,:,:,h), [flow_dir filesep flow_name ...
                '_stable_flow.jpg'], 'jpg', 'Quality', 80);
            ind = ind + 1;
        end
    end
    fprintf('finished\n');
end

end
