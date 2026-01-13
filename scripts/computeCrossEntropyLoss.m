function loss = computeCrossEntropyLoss(Y_true, scores, numClasses)
    % 确保 Y_true 是一个分类向量
    % scores 应该是模型输出的预测概率，大小为 [numSamples, numClasses]
    % numClasses 是类别的数量

    % 防止对数计算中的数学错误
    epsilon = 1e-15;
    
    % 计算交叉熵损失
    % 使用 max 函数避免对数为负无穷大的情况
    loss = -sum(Y_true .* log(max(scores, epsilon))) / numel(Y_true);
end