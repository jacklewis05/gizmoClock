% =========================================================================
% Stepper Motor Number Drawing Simulator
% =========================================================================
% Simulates the XY plotter drawing numbers 0-9 based on the Arduino C++
% source code (Numbers.cpp).
%
% Coordinate system matches the firmware exactly:
%   - Top-left  = (X=0,   Y=100)
%   - Top-right = (X=100, Y=100)
%   - Bot-left  = (X=0,   Y=0  )
%   - Y decreases downward  (firmware convention, no flipping)
%   - Arc angles: 0deg = rightmost point, increase clockwise
%
% USAGE:
%   number_simulator          % interactive prompt
%   number_simulator('DRAW2') % draws the number 2
%   number_simulator('CLR')   % clears and restarts
% =========================================================================

function number_simulator(command)

    % Plane / cell definition — 100x100 percent units
    P.originX = 0;
    P.originY = 0;
    P.width   = 100;
    P.height  = 100;

    % ---- Figure setup ----------------------------------------------------
    fig = figure('Name', 'Stepper Motor Drawing Simulator', ...
                 'Color', [0.12 0.12 0.15], ...
                 'NumberTitle', 'off', ...
                 'Position', [100 100 700 760]);

    ax = axes('Parent', fig, ...
              'Color', [0.97 0.97 0.93], ...
              'XLim', [-10 110], ...
              'YLim', [-10 110], ...
              'DataAspectRatio', [1 1 1], ...
              'XGrid', 'on', 'YGrid', 'on', ...
              'GridColor', [0.8 0.8 0.8], ...
              'GridAlpha', 0.6, ...
              'XColor', [0.8 0.8 0.8], ...
              'YColor', [0.8 0.8 0.8], ...
              'FontSize', 10);
    hold(ax, 'on');

    xlabel(ax, 'X (mm)', 'Color', [0.9 0.9 0.9]);
    ylabel(ax, 'Y (mm)  [100=top, 0=bottom]', 'Color', [0.9 0.9 0.9]);

    % Cell boundary
    rectangle('Parent', ax, ...
              'Position', [0 0 100 100], ...
              'EdgeColor', [0.4 0.6 0.9], ...
              'LineWidth', 1.5, 'LineStyle', '--');

    % ---- Parse command ---------------------------------------------------
    if nargin < 1 || isempty(command)
        command = input('Enter command (e.g. DRAW3): ', 's');
    end
    command = upper(strtrim(command));

    if strcmp(command, 'CLR')
        clf(fig);
        fprintf('Display cleared.\n');
        number_simulator();
        return;
    elseif length(command) >= 5 && strcmp(command(1:4), 'DRAW')
        digit = str2double(command(5:end));
        if isnan(digit) || digit < 0 || digit > 9
            error('Invalid digit. Use DRAW0 through DRAW9.');
        end
    else
        error('Unknown command "%s". Use DRAW0-DRAW9 or CLR.', command);
    end

    title(ax, sprintf('Drawing  %d', digit), ...
          'Color', [0.9 0.9 0.9], 'FontSize', 16, 'FontWeight', 'bold');

    % ---- Plotter state ---------------------------------------------------
    state.x           = 0;
    state.y           = 100;    % top-left home position
    state.penDown     = false;
    state.ax          = ax;
    state.color       = [0.10 0.10 0.10];
    state.lw          = 2.5;
    state.travelColor = [0.55 0.65 0.85];
    state.travelLW    = 0.8;

    % Mark home
    plot(ax, state.x, state.y, 'g^', 'MarkerSize', 9, 'MarkerFaceColor', 'g');

    % ---- Dispatch --------------------------------------------------------
    switch digit
        case 0,  state = draw0(state, P);
        case 1,  state = draw1(state, P);
        case 2,  state = draw2(state, P);
        case 3,  state = draw3(state, P);
        case 4,  state = draw4(state, P);
        case 5,  state = draw5(state, P);
        case 6,  state = draw6(state, P);
        case 7,  state = draw7(state, P);
        case 8,  state = draw8(state, P);
        case 9,  state = draw9(state, P);
    end

    legend(ax, {'Cell boundary','Start','Pen-up travel','Pen-down stroke'}, ...
           'Location', 'southoutside', 'Orientation', 'horizontal', ...
           'TextColor', [0.9 0.9 0.9], 'Color', [0.2 0.2 0.25], ...
           'EdgeColor', [0.4 0.4 0.5], 'FontSize', 8);

    hold(ax, 'off');
    fprintf('Done drawing %d.\n', digit);
end


% =========================================================================
%  NUMBER DRAWING FUNCTIONS — coordinates identical to firmware source.
%  Y=100 is top of cell, Y=0 is bottom. No modifications needed.
% =========================================================================

function state = draw0(state, P)
    state = relativeMove(state, P, 85, 50);
    state = penDown(state);
    state = relativeArc(state, P, 50, 50, 35, 45, 0, 360, 24);
    state = penUp(state);
end

function state = draw1(state, P)
    state = relativeMove(state, P, 30, 85);
    state = penDown(state);
    state = relativeMove(state, P, 50, 100);
    state = relativeMove(state, P, 50, 0);
    state = penUp(state);
end

function state = draw2(state, P)
    % Move to left side of top arc
    state = relativeMove(state, P, 15, 72);
    state = penDown(state);

    % Draw top arc from left to right
    state = relativeArc(state, P, 50, 72, 35, 28, 180, 0, 16);

    % Draw diagonal down to bottom-left
    state = relativeMove(state, P, 15, 0);

    % Draw bottom line to bottom-right
    state = relativeMove(state, P, 85, 0);

    state = penUp(state);
end

function state = draw3(state, P)
    % Move to top-left of the 3
    state = relativeMove(state, P, 20, 85);
    state = penDown(state);

    % Top arc: left -> right
    state = relativeArc(state, P, 50, 82, 30, 18, 170, -50, 16);

    % Middle connector
    state = relativeMove(state, P, 50, 50);
    state = relativeMove(state, P, 78, 34);

    % Bottom arc: left -> right
    state = relativeArc(state, P, 50, 28, 30, 18, 20, -170, 16);

    state = penUp(state);
end

function state = draw4(state, P)
    % Start at upper part of the diagonal
    state = relativeMove(state, P, 25, 100);
    state = penDown(state);

    % Diagonal down to the crossbar intersection
    state = relativeMove(state, P, 10, 52);

    % Crossbar to the right
    state = relativeMove(state, P, 85, 52);

    % Lift, then draw the vertical stem
    state = penUp(state);
    state = relativeMove(state, P, 65, 100);
    state = penDown(state);
    state = relativeMove(state, P, 65, 0);

    state = penUp(state);
end

function state = draw5(state, P)
    % Start at top-right
    state = relativeMove(state, P, 80, 100);
    state = penDown(state);

    % Top bar
    state = relativeMove(state, P, 20, 100);

    % Upper left vertical
    state = relativeMove(state, P, 20, 55);

    % Middle bar
    state = relativeMove(state, P, 65, 55);

    % Lower curve
    state = relativeArc(state, P, 50, 27, 15, 28, 0, -180, 16);

    state = penUp(state);
end

function state = draw6(state, P)
    state = relativeMove(state, P, 75, 90);
    state = penDown(state);
    state = relativeArc(state, P, 50, 65, 32, 32,  30, 180, 12);
    state = relativeArc(state, P, 50, 28, 32, 25, 180, 540, 20);
    state = penUp(state);
end

function state = draw7(state, P)
    state = relativeMove(state, P, 15, 100);
    state = penDown(state);
    state = relativeMove(state, P, 85, 100);
    state = relativeMove(state, P, 35, 0);
    state = penUp(state);
end

function state = draw8(state, P)
    state = relativeMove(state, P, 82, 72);
    state = penDown(state);
    state = relativeArc(state, P, 50, 72, 32, 26, 0, 360, 16);
    state = penUp(state);
    state = relativeMove(state, P, 82, 28);
    state = penDown(state);
    state = relativeArc(state, P, 50, 28, 32, 26, 0, 360, 16);
    state = penUp(state);
end

function state = draw9(state, P)
    state = relativeMove(state, P, 82, 72);
    state = penDown(state);
    state = relativeArc(state, P, 50, 72, 32, 28,  0, 360, 20);
    state = relativeArc(state, P, 50, 72, 32, 28,  0,  90,  8);
    state = relativeMove(state, P, 82, 0);
    state = penUp(state);
end


% =========================================================================
%  PRIMITIVE OPERATIONS — no Y-flipping, native firmware coordinates
% =========================================================================

% -------------------------------------------------------------------------
% relativeMove: move to absolute cell position (px, py).
%   px : 0=left,   100=right
%   py : 100=top,  0=bottom   (Y decreases downward — firmware convention)
% -------------------------------------------------------------------------
function state = relativeMove(state, P, px, py)
    destX = P.originX + (px / 100) * P.width;
    destY = P.originY + (py / 100) * P.height;

    if state.penDown
        plot(state.ax, [state.x destX], [state.y destY], ...
             'Color', state.color, 'LineWidth', state.lw, ...
             'DisplayName', 'Pen-down stroke');
    else
        plot(state.ax, [state.x destX], [state.y destY], ...
             '--', 'Color', state.travelColor, 'LineWidth', state.travelLW, ...
             'DisplayName', 'Pen-up travel');
    end

    state.x = destX;
    state.y = destY;
end

% -------------------------------------------------------------------------
% relativeArc: draw an elliptical arc.
%   cx, cy   : ellipse centre (percent units, Y-down)
%   rx, ry   : x and y radii (percent units)
%   startDeg : start angle — 0=right, clockwise positive
%   endDeg   : end angle
%   steps    : number of line segments
%
% 'YDir','reverse' on the axes means clockwise angles in data space
% plot clockwise on screen — exactly matching the physical plotter.
% No angle conversion needed whatsoever.
% -------------------------------------------------------------------------
function state = relativeArc(state, P, cx, cy, rx, ry, startDeg, endDeg, steps)

    cxD = P.originX + (cx / 100) * P.width;
    cyD = P.originY + (cy / 100) * P.height;
    rxD = (rx / 100) * P.width;
    ryD = (ry / 100) * P.height;

    angles = linspace(startDeg, endDeg, steps + 1);

    xPts = cxD + rxD * cosd(angles);
    yPts = cyD + ryD * sind(angles);

    if state.penDown
        plot(state.ax, xPts, yPts, ...
             'Color', state.color, 'LineWidth', state.lw, ...
             'DisplayName', 'Pen-down stroke');
    else
        plot(state.ax, xPts, yPts, ...
             '--', 'Color', state.travelColor, 'LineWidth', state.travelLW, ...
             'DisplayName', 'Pen-up travel');
    end

    state.x = xPts(end);
    state.y = yPts(end);
end

% ---- Pen helpers ---------------------------------------------------------
function state = penDown(state)
    state.penDown = true;
end

function state = penUp(state)
    state.penDown = false;
end