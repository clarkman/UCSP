function obj = addToHistory(obj, string)
% Adds the string to this object's history field.

if obj.history
    % Append the new string to the front, to maintain the processing
    % history
    obj.history = [string, ', ', obj.history];
else
    obj.history = string;
end


    
