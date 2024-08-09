function cross_correlation_results = compute_cross_correlation(signal1, signal2, signal3)
    % Check if input signals are continuous series
    if ~isvector(signal1) || ~isvector(signal2) || ~isvector(signal3)
        error('Input signals must be vectors representing continuous series.');
    end
    
    % Compute cross-correlation between signals received by three receivers
    
    % Compute cross-correlation between signal1 and signal2
    cross_corr_12 = sum(signal1 .* signal2);
    
    % Compute cross-correlation between signal1 and signal3
    cross_corr_13 = sum(signal1 .* signal3);
    
    % Compute cross-correlation between signal2 and signal3
    cross_corr_23 = sum(signal2 .* signal3);
    
    % Combine cross-correlation results
    cross_correlation_results = [cross_corr_12, cross_corr_13, cross_corr_23];
end

function TDOA_measurements = generate_TDOA_measurements(cross_correlation_results, sampling_frequency)
    % Check if input cross-correlation results is a vector
    if ~isvector(cross_correlation_results)
        error('Cross-correlation results must be a vector.');
    end
    
    % Find the peak index in the cross-correlation results
    [~, peak_index] = max(cross_correlation_results);

    % Calculate TDOA measurements based on the peak index and sampling frequency
    TDOA_measurements = peak_index / sampling_frequency;
end

function transmitter_positions = calculate_transmitter_positions()
    % Define transmitter positions
    transmitter1_position = [1, 1];  % Transmitter 1 position (x, y) in meters
    transmitter2_position = [5, 1];  % Transmitter 2 position (x, y) in meters
    transmitter3_position = [1, 5];  % Transmitter 3 position (x, y) in meters
    
    % Store transmitter positions in a matrix
    transmitter_positions = [transmitter1_position; transmitter2_position; transmitter3_position];
    
    % Check if any transmitter position is [0, 0]
    if any(all(transmitter_positions == 0, 2))
        error('Error: Transmitter positions include a flat 0 line.');
    end
end

function estimated_position = otdoa_algorithm(TDOA_measurements, receiver_positions, speed_of_light)
    % Check if input TDOA_measurements is a vector
    if ~isvector(TDOA_measurements)
        error('TDOA measurements must be a vector.');
    end
    
    % Number of receivers
    num_receivers = size(receiver_positions, 1);

    % Initialize estimated position
    estimated_position = zeros(1, 2); % Adjusted for 2D positions

    % Check if TDOA_measurements has at least two elements
    if numel(TDOA_measurements) >= 2
        % Initialize accumulator for estimated positions
        accumulated_position = zeros(1, 2);

        % Iterate through receiver pairs to find intersection points
        for i = 1:num_receivers-1
            for j = i+1:num_receivers
                % Calculate distance difference between receiver pairs
                delta_dist = (TDOA_measurements(j) - TDOA_measurements(i)) * speed_of_light;

                % Calculate vector between receiver positions
                vec_ij = receiver_positions(j, :) - receiver_positions(i, :);
                dist_ij = norm(vec_ij);
                
                % Check if the distance between receivers is not too small
                if dist_ij > 0.001 % Adjust this threshold as needed
                    % Calculate unit vector
                    unit_vec_ij = vec_ij / dist_ij;

                    % Calculate intersection point
                    intersection_point = receiver_positions(i, :) + (delta_dist / 2) * unit_vec_ij;

                    % Accumulate intersection points
                    accumulated_position = accumulated_position + intersection_point;
                end
            end
        end

        % Calculate average estimated position
        estimated_position = accumulated_position / (num_receivers * (num_receivers - 1) / 2);
    else
        % Return the estimated position based on the single TDOA measurement
        estimated_position = receiver_positions(1, :);
    end
end

function ground_truth_position = generate_ground_truth_position()
    % Generate ground truth position
    
    % Example: Generating random x and y coordinates within a predefined range
    min_range = -100; % Minimum value for position coordinates
    max_range = 100;  % Maximum value for position coordinates
    
    % Generate random x and y coordinates within the range
    x = min_range + (max_range - min_range) * rand();
    y = min_range + (max_range - min_range) * rand();
    
    % Construct ground truth position vector
    ground_truth_position = [x, y];
end

function estimated_error = calculate_error(estimated_position, ground_truth_position)
    % Check if inputs are row vectors of the same length
    if ~isvector(estimated_position) || ~isvector(ground_truth_position) || numel(estimated_position) ~= numel(ground_truth_position)
        error('Input positions must be row vectors of the same length.');
    end
    
    % Calculate the error between estimated position and ground truth position
    % Compute error vector
    error_vector = estimated_position - ground_truth_position;
    
    % Calculate Euclidean distance (magnitude) of the error vector
    estimated_error = norm(error_vector);
end
