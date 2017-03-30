function lineclip(p,w)
% Draw a line with clipping using the Cohen-Sutherland algorithm.
%
% Input arguments:
% x0,x1:
%    x coordinates of start and end point of line to clip
% y0,y1:
%    y coordinates of start and end point of line to clip
% xmin, xmax, ymin, ymax:
%    clip rectangle bounded diagonally by [xmin,ymin] and [xmax,ymax]

% Copyright 2011 Levente Hunyadi

    INSIDE = uint8(0);  % 0000
    LEFT = uint8(1);    % 0001
    RIGHT = uint8(2);   % 0010
    BOTTOM = uint8(4);  % 0100
    TOP = uint8(8);     % 1000

    x0 = p(1); x1 = p(2); y0 = p(3); y1 = p(4);
    xmin = w(1); xmax = w(2); ymin = w(3); ymax = w(4);
    CohenSutherlandLineClip(x0,y0,x1,y1);

    function code = ComputeOutCode(x,y)
    % Computes the bit code for a point [x,y] using the clip rectangle.

        code = INSIDE;  % initialized as being inside of clip window

        if (x < xmin)      % to the left of clip window
            code = bitor(code, LEFT);
        elseif (x > xmax)  % to the right of clip window
            code = bitor(code, RIGHT);
        end
        if (y < ymin)      % below the clip window
            code = bitor(code, BOTTOM);
        elseif (y > ymax)  % above the clip window
            code = bitor(code, TOP);
        end
    end

    function CohenSutherlandLineClip(x0,y0,x1,y1)
    % Clips a line from (x0, y0) to (x1, y1) against a rectangle.
    %
    % Input arguments:
    % xmin, xmax, ymin, ymax:
    %    clip rectangle bounded diagonally by (xmin, ymin) and (xmax, ymax)

        % compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
        outcode0 = ComputeOutCode(x0, y0);
        outcode1 = ComputeOutCode(x1, y1);
        accept = false;

        while true
            if ~bitor(outcode0, outcode1)  % bitwise OR is 0, trivially accept and get out of loop
                accept = true;
                break;
            elseif bitand(outcode0, outcode1)  % bitwise AND is not 0, trivially reject and get out of loop
                break;
            else
                % failed both tests, so calculate the line segment to clip from an outside point to an intersection with clip edge

                % at least one endpoint is outside the clip rectangle; pick it
                if outcode0
                    outcodeOut = outcode0;
                else
                    outcodeOut = outcode1;
                end

                % find the intersection point;
                % use formulas y = y0 + slope * (x - x0) and x = x0 + (1 / slope) * (y - y0)
                if bitand(outcodeOut, TOP)  % point is above the clip rectangle
                    x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                    y = ymax;
                elseif bitand(outcodeOut, BOTTOM)  % point is below the clip rectangle
                    x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                    y = ymin;
                elseif bitand(outcodeOut, RIGHT)  % point is to the right of clip rectangle
                    y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                    x = xmax;
                elseif bitand(outcodeOut, LEFT)  % point is to the left of clip rectangle
                    y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                    x = xmin;
                end

                % move outside point to intersection point to clip and get ready for next pass
                if outcodeOut == outcode0
                    x0 = x;
                    y0 = y;
                    outcode0 = ComputeOutCode(x0, y0);
                else
                    x1 = x;
                    y1 = y;
                    outcode1 = ComputeOutCode(x1, y1);
                end
            end
        end

        if accept
            if 0
                axes( ...
                    'XLim', [xmin,xmax], ...
                    'XLimMode', 'manual', ...
                    'YLim', [ymin,ymax], ...
                    'YLimMode', 'manual'); %#ok<UNRCH>
            end
            line([x0 x1], [y0,y1]);
        end
    end
end