function  [ residual, meta ] = detectPulsesJB( obj, detector, meta, fid );
%function pulses = detectPulsesJB(obj,option1,option2,option3,option4)
%
%  pulses = get_pulses(obj, option1, option2, ..., option4)
%
%
%   DESCRIPTION
%
% GET_PULSES accepts the TimeData object 'obj' which contains the time 
% series of a single channel of a magnetometer. An algorithm then processes 
% the data to identify pulses and returns the array 'pulses'.
%
% 
%   INPUTS
%
% GET_PULSES requires the timedata object to be passed, but also accepts 
% a range of optional parameters to fine-tune the algorithm.
% 1. obj:           a TimeData object (required)
% 2. amp_thresh:    amplitude threshold (in IQR's), everything below this 
%                   vlaue is considered noise. Default=8
% 3. min_gap:       minimum time-gap between adjacent pulses (in sec). Gaps 
%                   shorter than this are part of the same pulse. Default=10  
% 4. margin:        take some small margin around identified pulses (in sec).
%                   Default=1
% 5. smooth_period: a window to smooth the pulses in order to identify
%                   large peaks and delete spurious peaks (in sec).
%                   Default=0.5
%
%
%   OUTPUT
%
% The output array 'pulses' contains summary information about each of the
% identified pulses.  Each row of the array contains information about a
% single pulses, thus, the total number of rows corresponding to the total
% number of pulses in that particular day.  The columns of the array
% correspond to the following properties of each pulse:
%
% Column number:
% 1.  start time:    of the pulse in seconds, from beginning of the day
% 2.  duration:      of the pulses in seconds
% 3.  max positive:  maximum positive pulse value (in IQR above the median)
% 4.  max negative:  maximum negative pulse value (in IQR below the median)
% 5.  power:         cointained in the pulse (as IQR^2.dt) 
% 6.  num max:       number of positive peaks (maxima)
% 7.  num min:       number of negative peaks (minima)
% 8.  XX  
% 9.  XX
% 10. XX
%

doJacob = 0;

if doJacob % Change to 1 to restore old interface.

  % INPUTS
  % ------
  % Set default values. 
  %amp_thresh      = 8;
  %min_gap         = 10;
  %margin          = 1;
  %smooth_period   = 0.5;

  % Check for optional arguments.
  if nargin==0;
      disp('Function needs at least one input argument');
      return;
  end

  if nargin==2;
      if ~isempty(option1), amp_thresh = option1;     end   
      
      disp(['Using amp_thresh=',num2str(amp_thresh)]);
  end % if 2 input arguments
      

  if nargin==3;
      if ~isempty(option1), amp_thresh = option1;     end    
      if ~isempty(option2), min_gap = option2;        end 
      
      disp(['Using amp_thresh=',num2str(amp_thresh), ...
          ', min_gap=',num2str(min_gap)]);
  end % if 3 input arguments


  if nargin==4;
      if ~isempty(option1), amp_thresh = option1;     end    
      if ~isempty(option2), min_gap = option2;        end    
      if ~isempty(option3), margin = option3;         end 
      
      disp(['Using amp_thresh=',num2str(amp_thresh), ...
          ', min_gap=',num2str(min_gap), ', margin=',num2str(margin)]);
  end % if 4 input arguments


  if nargin==5;
      if ~isempty(option1), amp_thresh = option1;     end    
      if ~isempty(option2), min_gap = option2;        end    
      if ~isempty(option3), margin = option3;         end 
      if ~isempty(option4), smooth_period = option4;  end 
      
      disp(['Using amp_thresh=',num2str(amp_thresh), ...
          ', min_gap=',num2str(min_gap), ', margin=',num2str(margin), ...
          ', smooth_period=',num2str(smooth_period)]);
  end % if 5 input arguments

else % Change doJacob to 1 to restore old interface.

  % Clark: Mapped from detector database
  amp_thresh      = detector.threshold_pos;
  min_gap         = detector.duration_max;
  margin          = detector.duration_min;
  smooth_period   = detector.end_fract;

  sid = sscanf(obj.station,'%f');
  strCh=obj.channel;
  ch = sscanf(strCh(end),'%f');

end



% STEP 1: Get median and quartile values
% --------------------------------------

sig = obj.samples;
t   = [1:obj.sampleCount]/obj.sampleRate;

% Get median * normalize by Inter Quartile range
med = median(sig);

% quartile 1
qt1 = median( sig( sig<=med ) );

% quartile 3
qt3 = median( sig( sig>=med ) );

% inter quartile range
iqr = qt3 - qt1;

sig_n = (sig - med)/iqr;



% STEP 2: IDENTIFY ALL THE PULSES 
% -------------------------------

% identify 'quiet' periods
ind     = [(find(abs(sig_n) > amp_thresh)) ; obj.sampleCount];

d_ind   = diff([1 ; ind]);


start       = find(d_ind > min_gap*obj.sampleRate) ;
stop_ind    = ind(start) - d_ind(start);

stop_ind(1) = [];       % remove first ending point
start(end)  = [];       % remove last starting point
start_ind   = ind(start);   % convert to indices

% take some margin around pulses and trim
ind_margin = round(margin*obj.sampleRate);
start_ind = start_ind - ind_margin;
if start_ind(1)<1, start_ind(1) =1; end

stop_ind = stop_ind + ind_margin;
if stop_ind(end)>obj.sampleCount, stop_ind(end)=obj.sampleCount; end

npulse = length(start_ind)



if ~doJacob

  rows = zeros( npulse, 10 );
  rowCounter = 0;


  meta.ch_dur = meta.ch_dur + obj.sampleCount/obj.sampleRate/ 86400;

  % Add metas
 % meta.pulse_count_lo = meta.pulse_count_lo + NumLowEx;
 % meta.pulse_count_hi = meta.pulse_count_hi + NumHighEx;
 % meta.pulse_dur_lo = meta.pulse_dur_lo + totalLoLength / 86400;
 % meta.pulse_dur_hi = meta.pulse_dur_hi + totalHiLength / 86400;

else
  pulses = [];    % output array
end




% STEP 3: CHARACTERIZE EACH PULSE
% -------------------------------

for si = 1:npulse,
    
    % Get the range of index values of this pulse
    rng = [start_ind(si):stop_ind(si)];
    len = length(rng);
    pulse = sig_n(rng);
    
    % 0. start time
    start_time = start_ind(si)/obj.sampleRate;
    
    % 1. duration
    dur = (rng(end)-rng(1))/obj.sampleRate;
    
    if doJacob
      % 2. max positive
      max_pos = max( pulse );
      
      % 3. max negative
      max_neg = min( pulse );
    else
      % Clark: Used to compute peak time
      % 2. max positive
      [ max_pos, max_pos_ind ] = max( pulse );
      
      % 3. max negative
      [ max_neg, min_pos_ind ] = min( pulse );
    end
    
    % 4. power
    pow = sum( pulse.^2 )/obj.sampleRate ;
    
    
    
    % 5. peaks
    % --------
    % 5.1 smooth the pulse
    smooth_num = round(smooth_period*obj.sampleRate);
    
    % 5.2. Do a sliding average
    pulse_s = slidingavg(pulse, smooth_num);
        
    % 5.3. get extrema
    %dpulse_dt = gradient(pulse_s)*obj.sampleRate;
    [pulse_max,ind_max,pulse_min,ind_min] = extrema(pulse_s);
    
    
    % 5.4 make sure they are greater than 75% of the amp_threshold
    % (amplitude is slightly reduced due to sliding average)
    maxima  = pulse_max( pulse_max > 0.75*amp_thresh );
    max_ind = rng(ind_max(pulse_max > 0.75*amp_thresh ));
    num_max = length(maxima);
    
    minima  = pulse_min( pulse_min < -0.75*amp_thresh );
    min_ind = rng(ind_min(pulse_min < -0.75*amp_thresh ));    
    num_min = length(minima);
    
    % 5.5 Add this pulse to the output array
  if doJacob

    this_pulse = [start_time, dur, max_pos, max_neg, pow, num_max, num_min];
    pulses = [ pulses ; this_pulse ];

  else

    thisPulseStartT = obj.UTCref + start_time / 86400; % datenum
    thisPulseFinishT = thisPulseStartT + (dur/86400); % datenum

   % Clark: Hmmmm
    %if( sum( pulse ) >= 0 )
    if( abs( max_pos ) > abs( max_neg ) )
      peakT = obj.UTCref + ( start_time + max_pos_ind / obj.sampleRate ) / 86400;
      nextRow = [ thisPulseStartT, thisPulseFinishT, 1.0, sid, ch, dur, max_pos, peakT, pow, 1.0 ];
    else  
      peakT = obj.UTCref + ( start_time + min_pos_ind / obj.sampleRate ) / 86400;
      nextRow = [ thisPulseStartT, thisPulseFinishT, -1.0, sid, ch, dur, max_neg, peakT, pow, 1.0 ];
    end
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = nextRow;

  end

end


% Now write
for p = 1 : npulse
    fwrite(fid, rows(p,:), 'double');
end











