function found = getKeyVal( keys, vals, pick )

if isnumeric(pick)
	display('Supplied val')
	found = find( vals(:) == pick );
else
	display('Supplied key')
	keys{:}
	found = find( keys{:} == pick )
end
 
