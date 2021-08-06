function plotWaterVel( fhndl1, fhndl2, fhndl3 )

temp = 0:0.1:40;

saln = temp;

vel1 = zeros(numel(temp));
vel2 = zeros(numel(temp));
vel3 = zeros(numel(temp));

for j = 1 : numel(temp)
  vel1(j,:) = fhndl1(1.5,saln(j),temp);
  vel2(j,:) = fhndl2(1.5,saln(j),temp);
  vel3(j,:) = fhndl3(1.5,saln(j),temp);
end


surf(saln,temp,vel1,'FaceColor',[0.8 0.8 1],'EdgeColor','none')
hold on
surf(saln,temp,vel2,'FaceColor',[1 0.8 0.8],'EdgeColor','none')
surf(saln,temp,vel3,'FaceColor',[0.8 1 0.8],'EdgeColor','none')
alpha(0.5);

xlabel('Salinity - PSU')
ylabel('Temp deg - °C')
zlabel('Velocity - m/sec')

fun1Name = func2str(fhndl1); 
fun1Name = fun1Name(4:end); 
fun2Name = func2str(fhndl2); 
fun2Name = fun2Name(4:end); 
fun3Name = func2str(fhndl3);
fun3Name = fun3Name(4:end); 

legend({fun1Name, fun2Name, fun3Name})
title( [ 'Velocity models, Compared' ] )
