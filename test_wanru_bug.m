figure;
n_waves = size(a2fReducedWaves, 1); 

% Assuming 'data' is your (n, 1) array
unique_elements = unique(aiReducedSpikeAssociation);

% Generate equally spaced colors
num_unique = length(unique_elements);
colors = jet(num_unique); % Using 'jet' colormap, you can change it to 'hsv' or others

% Function to assign color
assignColor = @(x) colors(find(unique_elements == x), :);

% Create cell array with colors
color_labels = arrayfun(assignColor, aiReducedSpikeAssociation, 'UniformOutput', false);


hold on
for i = 1:n_waves
    plot(a2fReducedWaves(i, :), 'Color', color_labels{i});
end



