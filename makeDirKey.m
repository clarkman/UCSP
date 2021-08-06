function dirKey = makeDirKey()
%MAKEDIRKEY Returns a consistent order of firing direction plot markers across Aretmis analyese.
% 
% Only eight are needed: N, NE, E, SE, S, SW, W, NW, they are returned in this order (compass)

dirKey(1).marker = '^';
dirKey(1).name = 'N';
dirKey(2).marker = '+';
dirKey(2).name = 'NE';
dirKey(3).marker = '>';
dirKey(3).name = 'E';
dirKey(4).marker = 'o';
dirKey(4).name = 'SE';
dirKey(5).marker = 'v';
dirKey(5).name = 'S';
dirKey(6).marker = '*';
dirKey(6).name = 'SW';
dirKey(7).marker = '<';
dirKey(7).name = 'W';
dirKey(8).marker = 'x';
dirKey(8).name = 'NW';
