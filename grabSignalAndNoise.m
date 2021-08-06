function [ signal, noise ] = grabSignalAndNoise(mintDur)   

inSignalSelect = 0;
inNoiseSelect = 0;
signal = zeros(1,2) - 1;
noise = zeros(1,2) - 1;

%yy = get(gca,'YLim');
%lH = yy(1) + (yy(2)-yy(1)) * 2/3
lH = 0.1;

while 1

    [x, y, button] = ginput(1);

    if( button == 3 ) % cancel
      display('Exiting selection')
      if noise(1) == -1 || noise(2) == -1
        warning( 'Times set to default')
        signal(1) = 1.0; signal(2) = 1.3;
        noise(1) = 2.5; noise(2) = 3.75;
      end
      break;
    end
    
    if( button == 2 ) % do it
      if ~inNoiseSelect
        noise(1) = x;
        inNoiseSelect = 1;
        display( sprintf( 'Noise starts at %0.2f', x ));
      else
        noise(2) = x;
        display( sprintf( 'Noise ends at %0.2f', x ));
      	inNoiseSelect = 0;
        if noise(1) == -1 || noise(2) == -1
          warning( 'Noise time not properly selected')
          noise = zeros(1,2) - 1;
          continue
        end
        if noise(2)-noise(1) < mintDur
          warning( 'Noise segment too short!')
          noise = zeros(1,2) - 1;
          continue
        end
        line( noise, [lH, lH], 'Color', [0 1 0] )
      end
    end
   
    if( button == 1 ) % report
      if ~inSignalSelect
        signal(1) = x;
        inSignalSelect = 1;
        display( sprintf( 'Signal starts at %0.2f', x ));
      else
        signal(2) = x;
        display( sprintf( 'Signal ends at %0.2f', x ));
      	inSignalSelect = 0;
        if signal(1) == -1 || signal(2) == -1
          warning( 'Signal time not properly selected')
          signal = zeros(1,2) - 1;
          continue
        end
        if signal(2)-signal(1) < mintDur
          warning( 'Signal segment too short!')
          signal = zeros(1,2) - 1;
          continue
        end
        line( signal, [lH, lH], 'Color', [0 0 1] )
      end
    end

  end  % While
