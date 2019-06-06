%% Posner Cueing Simulator
% Warish Orko, 6/3/19
% This program simulates the Posner Cueing method of investigating human
% attention (1984). The user is asked to fixate their gaze on the center of
% the window and react to the presence of a red target that appears
% randomly on-screen. Each grid square may also glow to highlight attention
% towards that area. If the cue is in the same grid as the target, it is a
% valid cue. This program carries out a Posner Cueing experiment of 120
% trials and investigates the relation between experimental variables and
% the reaction times of the user.

%% Set up the display

f = figure('Position',[400 400 500 500]); % Creating a 500x500 figure at position (400,400)
for i = 0:3
    for ii = 0:3
        rectangle('Position', [125*i 125*ii 125 125] ); % Divide it into a grid
    end
end
hold on

%% Initialize test

m = msgbox('Please fixate your eyes on the center of the screen for the duration of the trial. Press a button when you see the red X. Press return to start.');
uiwait(m);

%% Tests
 
[X, Y] = meshgrid(1:4,1:4); % Create the necessary arrays to select from during random trials
X = (X-1)*125+62.5;
Y = X(1,:);
X = [0 125*(1:3)];

for i = 1:120 % Total number of trials is set here to 120
    x_i = randi(4,1); % Indices for x
    y_i = randi(4,1); % Indices for y
    x = Y(1,x_i); % Retrieve x coordinate of target
    y = Y(1,y_i); % Retrieve y coordinate of target
    T(i,1) = x; % Record x coord
    T(i,2) = y; % Record y coord
    if randi(2,1) > 1 % A valid cue, 50% chance of occuring
        r = rectangle('Position',[X(1,x_i) X(1,x_i) 125 125],'FaceColor','c'); % Draw the cue in the same grid position as the target
        T(i,5) = 1; % Record that this trial was a valid cue, represented by the number 1
        T(i,6) = x; % Record x coord of target
        T(i,7) = y; % Record y coord of target
    else % Invalid cue
        x_ii = X(1,randi(4,1)); % Generate a random position for the cue 
        y_ii = X(1,randi(4,1));
        r = rectangle('Position',[x_ii y_ii 125 125], 'FaceColor', 'c'); % Draw the cue
        T(i,5) = 0; % Record that this trial was an invalid cue, represented by the number 0
        T(i,6) = x_ii; % Record x coord of target
        T(i,7) = y_ii; % Record y coord of target
    end    
    if randi(2,1) > 1 % Long delay, 50% chance
        pause(0.3) % Delay of 0.3 seconds before showing the target
        T(i,4) = 0.3; % Record the delay
        delete(r); % Remove the cue
    else % Short delay
        pause(0.1) % Delay of 0.1 seconds
        T(i,4) = 0.1;
        delete(r);
    end
    
    S = scatter(x,y,'x','r'); % Draw the target
    tic; % Start measuring time
    k = waitforbuttonpress; % Await user input
    T(i,3) = toc; % Record the time taken to react to the target
    delete(S); % Remove the target
    
end

close all

%% Statistical Analysis

% Is there a significant effect of the cue being valid/invalid on reaction
% times?

T_valid = T((T(:,5)>0),:); % Retrieve the valid trials only
T_invalid = T((T(:,5)==0),:); % Retrieve the invalid trials only
[h, p, ~, ~] = ttest2(T_valid(:,3),T_invalid(:,3),'Vartype','unequal'); % Perform Welch's t-test to determine if the samples are of the same mean

if h == 0 % If the null hypothesis (the valid and invalid reaction time data are of the same mean) is not rejected
    disp('There is no statistically significant difference between the mean reaction times based on the validity of the cue.')
    disp(['The p value is ' num2str(p) ])
else % If the null hypothesis is rejected
    disp('There is a statistically significant difference between the validity of the cue and the reaction time.')
    disp(['The p value is ' num2str(p) ])
end

boxplot([T_valid(:,3) , T_invalid(:,3)], 'Labels', {'Valid' 'Invalid'}, 'Notch', 'on' )
xlabel('Cue Type')
ylabel('Reaction Time (s)')
title('Effect of Cue Type on Reaction Time in Posner Cueing')

% Is there a significant effect of the cue delay on reaction times?

T_short = T((T(:,4) == 0.1),:); % Retrieve the data for 0.1s delay
T_long = T((T(:,4) == 0.3),:); % Retrieve the data for 0.3s delay

[h, p, ~, ~] = ttest2(T_short(:,3),T_long(:,3),'Vartype','unequal');

if h == 0
    disp('There is no statistically significant difference between the mean reaction times based on the cue delay.')
    disp(['The p value is ' num2str(p) ])
else
    disp('There is a statistically significant difference between the mean reaction times based on the cue delay.')
    disp(['The p value is ' num2str(p) ])
end

figure
boxplot([T_short(:,3);T_long(:,3)], [repmat( {'0.1'}, length(T_short), 1) ; repmat( {'0.3'}, length(T_long), 1) ] , 'Notch', 'on')
xlabel('Cue Delay (s)')
ylabel('Reaction Time (s)')
title('Effect of Cue Delay on Reaction Time in Posner Cueing')

% Is there a significant effect of the distance between cue and target on
% reaction times?

figure
A = ((T_invalid(:,1)-T_invalid(:,6)).^2 + (T_invalid(:,2)-T_invalid(:,7)).^2) .^0.5; % Use cartesian distance formula to find distance between the targets and cues
scatter(A,T_invalid(:,3)) % Scatter plot of distances and reaction times
f = fit(A,T_invalid(:,3),'poly1'); % Use a model of y = x*p1 + p2 to fit the data
p = plot(f,A,T_invalid(:,3)); % Plot the linear fit
set(p(1),'MarkerSize',15)
legend('off')
xlabel('Distance between target and cue (pixels)')
ylabel('Reaction time (s)')
title('Effect of Target-Cue Distance on Reaction Time in Posner Cueing')

[R, P] = corrcoef(A,T_invalid(:,3)); % Finding correlation coefficients for the data

if R(1,2) > 0 && P(1,2) < 0.05
    disp('There is a statistically significant positive correlation between target-cue distance and reaction time.')
elseif  R(1,2) < 0 && P(1,2) < 0.05
    disp('There is a statistically significant negative correlation between target-cue distance and reaction time.')
else
    disp('There is no statistically significant correlation between target-cue distance and reaction time.')
end