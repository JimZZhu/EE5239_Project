function [xout,yout,varargout] = sp_proj(zone,type,x,y,units)
% SP_PROJ - convert to and from US state plane coordinates
%
%   [XOUT,YOUT] = SP_PROJ(ZONE,TYPE,X,Y,UNITS) converts to or 
%   from US state plane coordinates X and Y located in the state
%   plane zone specified by ZONE. The TYPE and UNITS inputs are used to 
%   specify whether to convert from or to state plane coordinates and 
%   the units of the inputs or outputs. XOUT and YOUT will either 
%   be state plane coordinates or geographic coordinates based 
%   on the TYPE of transformation specified.
% 
%   All calcuations assume the NAD83 datum and GRS1980 spheriod.
%
%   [XOUT,YOUT,MSTRUCT] = SP_PROJ(...) - The optional third output
%   argument returns the map projection used by PROJFWD and 
%   PROJINV to perform the coordinate transformation.
%
%   INPUTS
%       'zone'  - State plane zone (string). Use SP_PROJ([],...) 
%                 to select the zone from a list of available zones. 
%                 Zones can also be specified using the FIPS ID (eg.
%                 '0401' specifies the 'California 1' zone).
%       'type'  - Two possible options: 'forward' converts from 
%                 geographic coordinates to state plane and 
%                 'inverse' converts from state plane coordinates to 
%                 geographic
%       'x'     - x coordinates (either state plane or longitude)
%       'y'     - y coordinates (either state plane or latitude)
%       'units' - units of input or output.  When converting to 
%                 state plane (ie. 'forward' option), units specifies
%                 the units of the output coordinates.  When converting
%                 from state plane to geographic, units specifies the 
%                 the units of the input coordinates. Units can either be
%                 'meters' or 'survey feet' [abr. 'm', 'sf', respectively]. 
%
%   EXAMPLE 
%   %geographic data
%   lat = 37.45569; 
%   lon = -122.17009; 
%   
%   % Calculate the x,y, coordinates in survey feet at my 
%   % office in the "California 1" state plane zone
%   [xsp,ysp] = sp_proj('california 1','forward',lon,lat,'sf')
%
%   % Re-calculate the geographic coordinates
%   [lon1,lat1] = sp_proj('california 1','inverse',xsp,ysp,'sf')
% 
% SEE ALSO PROJFWD PROJINV AXESM
