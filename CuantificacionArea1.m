function CuantificacionArea1
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascaras_celulas_modificadas\');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Prueba Automatización');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
Experimento=cell(nI,1);
LDsarea=zeros(nI,1);
desviacion_area=zeros(nI,1);
tabla_size_LD={};
nombre_exp= ['1', '2', '3', '4', '5', '6'];


% Bucle que actúe sobre cada imagen
for i=1:nI
 %% Células
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascaras_celulas_modificadas\');
 Celula=imread(I(i).name);
 figure, imshow(Celula), set(gcf, 'Name', 'Mascara célula')

 Mascara_cel=imbinarize(Celula); 
 etiquetas_final_cel=bwlabeln(Mascara_cel);

 %% LDs
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascara_LD\');
 L=dir('*.tif');
 LD=imread(L(i).name);
 figure, imshow(LD), set(gcf, 'Name', 'Mascara LD')

 Mascara_LD=imbinarize(LD);
 etiquetas_final_LD=bwlabeln(Mascara_LD);


%% Contabilizar áreas
 Size_cel=zeros(size(unique(etiquetas_final_cel),1),1);
 Size_LD=zeros(size(unique(etiquetas_final_LD),1),1);
 AreaLD_por_celula=zeros(size(unique(etiquetas_final_cel),1),1);
 t =max(max(unique(etiquetas_final_cel)));

 for b=1:t
     mask1=zeros(size(Mascara_cel)); %crea una matriz de 0, del mismo tamaño que la imagen original
     mask1(etiquetas_final_cel==b)=1; %da valor 1 a los píxeles del área equivalente a la célula correspondiente

     mascara_cel_bucle=double(mask1).*double(Mascara_cel); %aplica esta máscara a la imagen binaria de las células (selecciona dicha célula)
     area_celula=sum(mascara_cel_bucle(:)>0); %calcula el área total que ocupa esta célula, en píxeles
     Size_cel(b)=area_celula;

     mascara_LD_bucle=double(mask1).*double(Mascara_LD); %aplica esta máscara a la imagen binaria de los LDs (selecciona los LDs de la célula de interés)
     area_LD=sum(mascara_LD_bucle(:)>0); %calcula el área de estos LDs, en píxeles
     Size_LD(b)=area_LD;

     AreaLD_por_celula(b)=area_LD/area_celula;
 end

 %Cálculo del tamaño de cada LD
 stats2 = regionprops(etiquetas_final_LD, 'Area'); %calcula el tamaño de cada etiqueta
vector_pixeles_etif_LD = [stats2.Area]; %almacena los tamaños en un vector
tabla_size_LD{i,1}=vector_pixeles_etif_LD;
 
%AreaLD_por_celula, célula por célula
tabla_areaporarea{i,1}= AreaLD_por_celula; %celda en la que en cada fila se almacena el 'area por area' de cada una de las células de un campo.
ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Areas';
archivo = 'AreaporAreaporCel1.xlsx';
writecell(tabla_areaporarea, fullfile(ruta, archivo));


media_AreaLD_por_celula=mean(AreaLD_por_celula);
sd_AreaLD_por_celula=std(AreaLD_por_celula);

LDsarea(i,1)=media_AreaLD_por_celula; %guarda el resultado para esta imagen
desviacion_area(i,1)=sd_AreaLD_por_celula/ sqrt(length(etiquetas_final_cel)); %error estándar
Experimento{i,1}=I(i).name;
end

%% Resultados ratio área

T2=table(Experimento,LDsarea,desviacion_area);
disp(T2)
ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Areas';
archivo = 'MediaArea1.xlsx';
writetable(T2, fullfile(ruta, archivo));

figure, bar(LDsarea), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD area/Cell area'), set(gcf, 'Name', 'Resultado Área')
hold on
x = 1:length(nombre_exp);
xticks(x);
xticklabels({'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'})
errorbar(x, LDsarea, desviacion_area, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off


%% Distribución tamaños de LD (no area/area, tamaños)


ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\TamañosLD';
archivo = 'LDsize1.xlsx';
writecell(tabla_size_LD, fullfile(ruta, archivo));

end 