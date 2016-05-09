

%RGB2XYZ	Convert RGB to XYZ color space
%
%	[x, y, z] = RGB2XYZ(r, g, b)
%	xyz = RGB2XYZ(rgb)
%
%	Convert (R,G,B) coordinates to (X,Y,Z) color space.
%	If RGB (or R, G, B) have more than one row, then computation is
% 	done row wise.
%
% SEE ALSO:	ccxyz cmfxyz
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

function [x,y,z] = rgb2xyz(R,G,B)

	a = [
		3.40479 -1.537150 -0.498535
		-0.969256 1.875992 0.041556
		0.055648 -0.204043 1.057311];
	ai = inv(a);

	if nargin == 3,
		RGB = [R G B];
	elseif nargin == 1,
		RGB = R;,
	else
		error('wrong number of arguments')
	end

	XYZ = [];
	for rgb = RGB',
		xyz = ai*rgb;
		XYZ = [XYZ xyz];
	end
	XYZ = XYZ';

	if nargout == 1
		x = XYZ;
	elseif nargout == 3,
		x = XYZ(:,1);
		y = XYZ(:,2);
		z = XYZ(:,3);
	end
