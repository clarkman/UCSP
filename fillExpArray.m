function [ fullExps, fullExpsLbls ] = fillExpArray( exps, expLbls, sensors, fps );

sz = size(exps);
nrows = sz(1);
ncols = sz(2);

num2Add = 4;

newExp = zeros(nrows,ncols+num2Add);
newExp(:,1:ncols) = exps;

newExpLbls = cell(1,ncols+num2Add);
for c = 1 : ncols
  newExpLbls{c} = expLbls{c};
end

% Pluck from firing positions
col = ncols+1;
newExpLbls{col} = 'range';
newExpLbls{col+1} = 'meter';
for r = 1 : nrows
  fp = exps(r,1)
  sens = exps(r,4)
  idx = find( fps(:,1) == fp )
  idx = find( fps(:,2) == sens )
  idx = find( fps(:,1) == fp & fps(:,2) == sens )
  if numel(idx) ~= 1
  	for ith = 1 : numel(idx)
      foundFp = fp(idx(ith),1);
      foundSens = fp(idx(ith),2);
  	end
    r
    error('Concept error!')
  end
  newExp(r,col) = fps(idx,3);
  newExp(r,col+1) = fps(idx,4);
end

col = ncols+3;
newExpLbls{col} = 'height';
newExpLbls{col+1} = 'hexrow';
numSensors = numel(sensors);
for r = 1 : nrows
  sens = exps(r,4);
  % Dev: hits = 0;
  for idx = 1 : numSensors
    if sens == sensors(idx).sensId
      %hits = hits + 1;
      newExp(r,col) = sensors(idx).height;
      newExp(r,col+1) = idx;
    end
  end
  % if hits ~= 1
  % 	error('Concept')
  % end
end

fullExps = newExp;
fullExpsLbls = newExpLbls;
