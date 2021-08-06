function [diff diffZ diffZN] = limitCheck ( signal, reference, type )

% limitCheck.m
%
% Returns:
%	diff    - The differences in the stream.
%	diffZ   - Non limit diffs are zero'd out.
%	diffZN  - Differences are set to 1.

% - Goal: take an input data stream and compare to a reference looking for differences.

%- Subtract the two streams.
%	- ABOVE: Look for positive differences.
%	- BELOW: Look for negative differences.

%- What do wo return?
%	- The raw diff stream?
%	- The diff stream with negative/positive values zero'd out.
%	- The diff stream with negative/positive values zero'd out and the side set to 1
%	- An array of the events.  Include:
%		- Network
%		- Site
%		- Channel
%		- Start time
%		- End time
%		- Max diff
%		- Median diff
%		- std of diff
%		- Type of excursion ???


	sizeSignal    = size( signal );
	sizeReference = size( reference );

	if ( size( signal )  ~= size( reference ) )
		error( ['Signal and reference sizes do not match' ] );
	end % if ( size( signal )  ~= size( reference ) )

	if ( strcmp( type, 'GREATERTHAN' ) == 1 ),
		display( 'Doing a GREATERTHAN comparison' );
		diffType = 0;
	elseif ( strcmp( type, 'LESSERTHAN' ) == 1 ),
		display( 'Doing a LESSERTHAN comparison' );
		diffType = 1;
	else ,
		display( ['Invalid type: ', type ] );
	end % if ( strcmp( type, 'GREATERTHAN' ) == 1 ),


	% Do the diff man
	switch diffType,
		case 0
			diff = signal - reference;
		case 1
			diff = reference - signal; 
	end % switch diffType,

	% Set normal signals in diff stream to zero.
	diffZ = diff;
	inds = find( diffZ <  0 );
	diffZ( inds ) = 0;

	% Set events to 1.
	diffZN = diffZ;
	inds = find( diffZN >  0 );
	diffZN( inds ) = 1;

	% Loop through difference and look for interesting events.

