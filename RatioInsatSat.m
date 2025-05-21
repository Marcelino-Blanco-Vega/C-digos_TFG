function RatioInsatSat
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\7Specific bands\2849');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
radio_aver=2;


% Bucle que actúe sobre cada imagen
for i=1:nI
 %% Máscaras Células y LD
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\4a_Mascaras\Mascaras_celulas_modificadas\');
 C=dir('*.tif');
 Celula=imread(C(i).name);
 figure, imshow(Celula), set(gcf, 'Name', 'Mascara célula')
 Mascara_cel=imbinarize(Celula); 
 

 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\4a_Mascaras\Mascaras_LD_seleccionados\');
 D=dir('*.tif');
 LD=imread(D(i).name);
 
    
 %% 2850
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\7Specific bands\2849');
 I=dir('*.tif');
 Raman2850_full=imread(I(i).name);
 Raman2850_cell= Raman2850_full .*uint8(Mascara_cel);
 %figure, imshow(Raman2850_cell), colormap(jet), set(gcf, 'Name', 'Banda 2850')

 Raman2850_ruido=Raman2850_full-Raman2850_cell;
 %figure, imshow(Raman2850_ruido), set(gcf, 'Name', 'Banda 2850 ruido')
 Raman2850_ruido_av=mean(double(Raman2850_ruido(:)));

 Raman2850_cell_clean=double(Raman2850_cell)-Raman2850_ruido_av;
 Raman2850_cell_clean(Raman2850_cell_clean<0)=0;
 %figure, imshow(Raman2850_cell_clean), colormap(jet), set(gcf, 'Name', 'Banda 2850 clean')
 

 %% 3013
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\7Specific bands\3013');
 L=dir('*.tif');
 Raman3013_full=imread(L(i).name);
 Raman3013_cell= Raman3013_full .*uint8(Mascara_cel);


 Raman3013_ruido=Raman3013_full-Raman3013_cell;
 Raman3013_ruido_av=mean(double(Raman3013_ruido(:)));

 Raman3013_cell_clean=double(Raman3013_cell)-Raman3013_ruido_av;
 Raman3013_cell_clean(Raman3013_cell_clean<0)=0;


%% Ratio
 
 %ratiolipidos= Raman2850_cell ./ (Raman2850_cell+Raman2930_cell);
 ratiolipidos= (Raman3013_cell_clean ./ Raman2850_cell_clean);
 ratio_8bit = uint8(ratiolipidos * 255);
 aver = fspecial('average', radio_aver);
 ratio_aver = imfilter(ratio_8bit, aver, 'same');
 ratio_contraste=imadjust(ratio_aver, [0.05 1], [0 1]);


 figure,imshow(ratio_contraste), colormap("turbo"), set(gcf, 'Name', '3013/2850') %ratio insaturacion/saturacion

 ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-06 Análisis 4º experimento\8Ratiometric\3013-2849';
 nombre = sprintf('resultado_%02d.png', i);
 ratio_contraste_rgb = ind2rgb(ratio_contraste, turbo(256));
 imwrite(ratio_contraste_rgb, fullfile(ruta, nombre));


end
end