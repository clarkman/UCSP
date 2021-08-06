function obj = selectType( inObj, filename, type, annotation )
% XXX Clark not a good early-on design decision ...

doMask=0;
if( strfind( annotation, 'Mask' )  )
    doMask=1;
end



switch type 
case 'dataq' 
    %obj = remakeDataQFile( inObj, filename, annotation )
    obj = inputWinDaQ( inObj, filename, annotation, '' );
case 'quakesat' 
    if( strcmp( annotation, 'HdrOnly' ) )
        obj = makeHdrOnlyRawTextFile( filename, annotation );
    else
        [obj, classname, parent] = remakeRawTextFile( inObj, filename, type, annotation );
	obj = class(obj, classname, parent);        
        obj = updateEndTime(obj);

    end
case 'ma' 
    obj = remakeMAFile( inObj, filename, annotation );
%case { 'dem', 'dem1', 'dem2', 'dem3' } 
case 'dem1135' 
    [obj, classname, parent] = remakeDemeter1135File2( inObj, filename, type, annotation );
    obj = class(obj, classname, parent);        
    obj = updateEndTime(obj);
case 'dem1131' 
    [obj, classname, parent] = remakeDemeterFile( inObj, filename, type, annotation );
    obj = class(obj, classname, parent);        
    obj = updateEndTime(obj);
case 'dem1136' 
    [obj, classname, parent] = remakeDemeterFile( inObj, filename, type, annotation );
    obj = class(obj, classname, parent);        
    obj = updateEndTime(obj);
case 'hk' 
    obj = remakeHKFile( inObj, filename, type, annotation );
case 'bk'
    % XXX Clark could have smudged them all over to 'cmn' after Jim converted the data format  
    % of BK data to same as 800 serieas.  Left it separate to allow customizations.
%    [obj, classname, parent] = remakeRawBK( inObj, filename, type, annotation );
    % New loader uses mx/mex and is ~ 3x faster !!!
    [obj, classname, parent] = remakeRawBK2( inObj, filename, annotation );
    obj = makeObjects(obj, classname, parent);
    %obj = bkLoadOptions( obj, annotation );
case 'cmnrms' 
    [obj, classname, parent] = remakeCalMagNetRMSFile( inObj, filename, annotation );
    obj = makeObjects(obj, classname, parent);        
case 'cmnNASA' 
    [obj, classname, parent] = remakeCalMagNetFile( inObj, filename, annotation );
    obj = makeObjects(obj, classname, parent);        
case 'cmn' 
    [obj, classname, parent] = remakeCalMagNetFile2( inObj, filename, annotation );
    obj = makeObjects(obj, classname, parent);
    if( doMask )
        obj = maskObjects( obj );
    end
otherwise
    msg = ['Type unknown: ',type,'. Default object created.'];
    warning( msg );
    obj = inObj;
end    



function outObj = makeObjects( obj, classname, parent )
if( iscell(obj) )
    numSegments = length(obj);
    outObj = cell( numSegments, 1 );
    for ith = 1 : numSegments
        daObj = class( obj{ith}, classname, parent{ith} );
        outObj{ith} = updateEndTime( daObj );
    end
else
    outObj = class( obj, classname, parent );        
    outObj = updateEndTime( outObj );
end



function outObj = maskObjects( obj )

    % This is a 5th generation addon to segments as driven by a database
    [status, procDir] = system( 'echo -n $CMN_PROC_ROOT' );
    if( length( procDir ) == 0 )
        error( 'env must contain CMN_PROC_ROOT variable' );
    end
    
    if( iscell( obj ) )
        numBlocks = length(obj);
        inObj = obj{1};
        startDn = obj{1}.DataCommon.UTCref;
        endDn = obj{end}.DataCommon.UTCref + obj{end}.sampleCount / ( obj{end}.sampleRate * 86400 );
        ch = obj{1}.DataCommon.channel;
        ch = ch(end);
        sid = obj{1}.DataCommon.station;
    else
        numBlocks = 1;
        startDn = obj.DataCommon.UTCref;
        endDn = startDn + obj.sampleCount / ( obj.sampleRate * 86400 );
        ch = obj.DataCommon.channel;
        ch = ch(end);
        sid = obj.DataCommon.station;
    end

    % Get exclusions for this day/sta/ch, if any.
    sT = datenum2str( startDn, 'sql' );
    eT = datenum2str( endDn, 'sql' );
    proc = [ procDir, '/getExclusions.bash ', sid, ' ', ch, ' "', sT, '" "', eT, '"' ];
    [status, exclusionList] = system( proc );
    exclusions = strread(exclusionList,'%s','delimiter','\n');
    numExclusions = length(exclusions);
    if( ~numExclusions ) % Nothing to do
        outObj = obj;
        return
    end
    
    % Where angles fear to tread ...
    exclSet = cell( numExclusions, 1 );
    padder = 0.0/86400;
    numExclSegs = 0;
    for ex = 1 : numExclusions
    
        [excl_start, excl_finish, station, channel] = strread(exclusions{ex},'%s%s%s%s','delimiter','|');
        exclBegDn = str2datenum(sql2stdDate(excl_start{1}))-padder;
        exclFinDn = str2datenum(sql2stdDate(excl_finish{1}))+padder;
        if( exclBegDn >= exclFinDn ), error('Period Reversal');, end;

        if( numBlocks == 1 )
        
            outList = mask( obj, [exclBegDn, exclFinDn] );
            numObjs = length(outList);
            val = 0;
            if( outList{1}.sampleCount ), val=1;, end;
            if( numObjs == 2 && outList{2}.sampleCount ), val=val+1;, end;
            obj = cell(val,1);
            iith = 1;
            if( outList{1}.sampleCount )
                obj{iith}=outList{iith};
                iith = iith + 1;
            end;
            if( numObjs == 2 && outList{2}.sampleCount )
                obj{iith}=outList{iith};
            end
            numBlocks = val;
            
        end
        
        for ii = 1 : numBlocks
        
            inObj = obj{ii};
            outList = mask( inObj, [exclBegDn, exclFinDn] );
            numObjs = length(outList);
            
            for n = 1 : numObjs
                if( outList{n}.sampleCount ) % Zero means nada, skip
                    numExclSegs = numExclSegs + 1;
                    numBlocks = numBlocks + 1;
                    outObj{numExclSegs,1} = outList{n};
                end
            end
            
        end
        
    end
    
    
