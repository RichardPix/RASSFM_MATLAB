function [Sim] = BandCombine(Sim1, Sim2, S2, gap)

[H, W, B] = size(S2);

h = H/gap; w = W/gap;
Sim1_LR = imresize(imresize(Sim1, [h w], 'box'), [H W], 'bicubic');
Sim2_LR = imresize(imresize(Sim2, [h w], 'box'), [H W], 'bicubic');

Sim = zeros(H, W, B);

for i=1:B
    CCMat1 = corrcoef(Sim1_LR(:,:,i), S2(:,:,i));
    CCMat2 = corrcoef(Sim2_LR(:,:,i), S2(:,:,i));

    [~, max_id] = max([CCMat1(2,1) CCMat2(2,1)]);
    if max_id == 1
        Sim(:,:,i) = Sim1(:,:,i);
    elseif max_id == 2
        Sim(:,:,i) = Sim2(:,:,i);
    end
end

end