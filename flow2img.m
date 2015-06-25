function im = flow2img(u, v)
    nfms = size(u, 3);
    im = zeros(size(u, 1), size(u, 2), 3, nfms, 'uint8');
    im(:,:,1,:) = uint8(max(0, min(255, floor(u) + 127)));
    im(:,:,2,:) = uint8(max(0, min(255, floor(v) + 127)));
    u_frac = floor((u - floor(u)) * 10);
    v_frac = floor((v - floor(v)) * 10);
    im(:,:,3,:) = uint8(u_frac * 10 + v_frac);
end
