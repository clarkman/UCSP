function obj = addToTitle(obj, string)
% Adds the string to this object's title field.

if obj.title
    % Save the old title in the history.
    obj = addToHistory(obj, obj.title);
end

obj.title = string;
