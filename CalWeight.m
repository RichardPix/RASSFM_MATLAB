function [VecPred] = CalWeight(VecCent, VecSimilar, VecSource, tol, similar_num)
% Calculate the weight of each similar neighbor and predict the target image patch.

dist = dist2(VecCent',VecSimilar');
[~,neighborhood] = sort(dist);

z = VecSimilar(:,neighborhood) - repmat(VecCent,1,similar_num); % Calculate differences.
Cov = z'*z; % Local covariance.
if trace(Cov)==0
    Cov = Cov + eye(similar_num,similar_num)*tol; % Regularlization
else
    Cov = Cov + eye(similar_num,similar_num)*tol*trace(Cov);
end
Wt = Cov\ones(similar_num,1); % Solve C*Wt=1

% Using positive weights for fusion.
Ind = find(Wt > 0);
neighborhood_pos = neighborhood(Ind);
Wt_pos = Wt(Ind,1);
Wt_pos = Wt_pos/sum(Wt_pos); % Enforce sum(Wt_pos)=1

% Target prediction.
VecPred = VecSource(:,neighborhood_pos) * Wt_pos;

end
