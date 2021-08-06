function outObj = sosfilt( obj, sos )

outObj = obj;

outObj.samples =  sosfilt( sos, obj.samples );


