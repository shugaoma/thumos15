function [hu hv] = dense_stablize_flow(u, v, min_res, verbose)
delta = min_res * min_res;
[rows cols] = size(u);
[X,Y] = meshgrid(1:cols,1:rows);
N = numel(X);
coord = [X(:),Y(:)]';
seeds = min(1000, N / 4);
f = [u(:),v(:)]';
D = zeros(2*seeds,6);
bestA = ones(2, 3);
bestScore = 0;
for i = 1:30
    if verbose > 0
        fprintf('computing stablized flow, iter: %d\n',i);
    end
    ind = randsample(N, seeds);
    [py px] = ind2sub([rows cols], ind);
    D(1:seeds,1:3) = [px,py,ones(size(px))];
    D(seeds+1:end,4:6) = [px,py,ones(size(px))];
    rhs = [px+u(ind);py+v(ind)];
    r = pinv(D)*rhs;
    A = [r(1:2)';r(4:5)'];
    b = r([3,6]);
    residual = A*coord+repmat(b,1,N)-coord-f;
    error = sum(residual.*residual,1);
    fitted = error < delta;
    fitted_ind = find(fitted)';
    numPts = length(fitted_ind);
    if numPts < max(30, bestScore)
        continue;
    end
    [py2 px2] = ind2sub([rows, cols], fitted_ind);
    N1 = length(px2);
    D2 = zeros(2*N1,6);
    D2(1:N1,1:3) = [px2,py2,ones(size(px2))];
    D2(N1+1:end,4:6) = [px2,py2,ones(size(px2))];
    rhs = [px2+u(fitted_ind);py2+v(fitted_ind)];
    r = pinv(D2)*rhs;
    A = [r(1:2)';r(4:5)'];
    b = r([3,6]);
    residual = A*coord+repmat(b,1,N)-coord-f;
    error = sum(residual.*residual,1);
    numPts = sum(error<delta);
    if bestScore<numPts,
        bestScore=numPts;
        bestA = [A,b];
        if verbose > 0
            fprintf('best fitted points:%d,%.2f\n',numPts,numPts/N);
        end
    end
end

residual = f - (bestA(:,1:2)*coord+repmat(bestA(:,3),1,N)-coord);
hu = reshape(residual(1,:)', rows, cols);
hv = reshape(residual(2,:)', rows, cols);
end
