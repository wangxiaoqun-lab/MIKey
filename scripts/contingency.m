%% Contingency Matrix
function cont = contingency(labels1, labels2)
    u1 = unique(labels1);
    u2 = unique(labels2);
    cont = zeros(length(u1), length(u2));
    for i = 1:length(u1)
        for j = 1:length(u2)
            cont(i,j) = sum(labels1 == u1(i) & labels2 == u2(j));
        end
    end
end