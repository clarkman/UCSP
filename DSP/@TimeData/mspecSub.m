function mspecSub( freq1, freq2, freq3, obj )


[amp1, mag1] = mspec( obj, freq1 );
[amp2, mag2] = mspec( obj, freq2 );
[amp3, mag3] = mspec( obj, freq3 );

hold on;
plot( amp1, amp2, amp3 )
