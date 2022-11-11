% Draw Figures - Chapter 3
%
% This script generates all of the figures that appear in
% Chapter 3 of the textbook.
%
% Nicholas O'Donoughue
% 25 May 2021

% Clear Figures
close all;

% Set up directory and filename for figures
dirNm = fullfile(pwd,'figures','practical_geo');
if ~exist(dirNm,'dir')
    mkdir(dirNm);
end
prefix = fullfile(dirNm,'fig3_');

% Initialize Plot Preference
doFullColor=true;
utils.initPlotSettings;

% Reset the random number generator, to ensure reproducability
rng('default') ; 

%% Figure 1, TDOA Geometry -- non-redundant set

x_source = [2; 3];
x_sensor = [0, -1, 0, 1;
            0, -.5, 1, -.5];

% Plot sensor/source positions
fig1 = figure();
plot(x_source(1), x_source(2), '^', 'DisplayName','Source');
hold on;
plot(x_sensor(1,:), x_sensor(2,:), 'o', 'DisplayName','Sensor');

% Generate Isochrones
ref_idx = 1;
x_ref = x_sensor(:,ref_idx);
isochrone_label = 'Isochrones';
for test_idx = 2:4
    x_test = x_sensor(:,test_idx);
    rdiff = utils.rngDiff(x_source, x_ref, x_test);
    xy_iso = tdoa.drawIsochrone(x_ref, x_test, rdiff, 10000, 5);
    
    hdl=plot(xy_iso(1, :), xy_iso(2, :), '--', 'DisplayName',isochrone_label);
    if test_idx > 2
        utils.excludeFromLegend(hdl);
    end
end

xlim([-1 3]);
ylim([-1 3]);

legend('Location','NorthWest');
utils.setPlotStyle(gca,{'clean','tight'});
utils.exportPlot(fig1,[prefix '1']);

%% Figure 2, TDOA Geometry -- full set

x_source = [2; 3];
x_sensor = [0, -1, 0, 1;
            0, -.5, 1, -.5];

% Plot sensor/source positions
fig2 = figure();
plot(x_source(1), x_source(2), '^', 'DisplayName','Source');
hold on;
plot(x_sensor(1,:), x_sensor(2,:), 'o', 'DisplayName','Sensor');

% Generate Isochrones
isochrone_label = 'Isochrones';
for ref_idx = 1:3
    x_ref = x_sensor(:,ref_idx);

    for test_idx = ref_idx+1:4
        x_test = x_sensor(:,test_idx);
        rdiff = utils.rngDiff(x_source, x_ref, x_test);
        xy_iso = tdoa.drawIsochrone(x_ref, x_test, rdiff, 10000, 5);

        hdl=plot(xy_iso(1, :), xy_iso(2, :), '--', 'DisplayName',isochrone_label);
        if ref_idx > 1 || test_idx > 2
            utils.excludeFromLegend(hdl);
        end
    end
end
xlim([-1 3]);
ylim([-1 3]);
legend('Location','NorthWest');
utils.setPlotStyle(gca,{'clean','tight'});
utils.exportPlot(fig2,[prefix '2']);


%% Figures 3 a, b, c
% Figures generated by Example 3.1

figs = book2_ex3_1();

for idx = 1:numel(figs)
    figure(figs(idx));
    
    grid off;
    utils.exportPlot(figs(idx), [prefix '3' char('a' + idx-1)]);
end

%% Figures 4, and 5abcde

figs = book2_ex3_2();

figure(figs(1));
utils.setPlotStyle(gca,{'widescreen','equal','tight'});
utils.exportPlot(figs(1), [prefix, '4']);
for idx = 2:numel(figs)
    utils.exportPlot(figs(idx), [prefix '5' char('a' + idx-2)]);
end

%% Figures 6 and 7abc

figs = book2_ex3_3();

figure(figs(1));
utils.setPlotStyle(gca,{'widescreen','equal','tight'});
utils.exportPlot(figs(1), [prefix, '6']);
for idx = 2:numel(figs)
    utils.exportPlot(figs(idx), [prefix '7' char('a' + idx-2)]);
end

%% Figures 8a and 8b
if force_recalc
    figs = book2_ex3_4();
    
    for idx = 1:numel(figs)
        figure(figs(idx));
        utils.setPlotStyle(gca,{'widescreen','tight'});
        utils.exportPlot(figs(idx), [prefix '8' char('a' + idx-1)]);
    end
    
    xlim([1600,4400]);
    ylim([3200,4800]);
    utils.exportPlot(figs(end), [prefix '8b_zoom']);
end

%% Cleanup

% Restore plot settings
utils.resetPlotSettings;