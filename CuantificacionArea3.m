function CuantificacionArea3
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-24 Análisis 3º experimento\Mascaras\Mascaras_Celulas_modificadas\');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-24 Análisis 3º experimento');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
Experimento=cell(nI,1);
LDsarea=zeros(nI,1);
desviacion_area=zeros(nI,1);
tabla_size_LD={};
nombre_exp= ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
ExperimentoAYB={'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'};


% Bucle que actúe sobre cada imagen
for i=1:nI
 %% Células
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-24 Análisis 3º experimento\Mascaras\Mascaras_Celulas_modificadas\');
 Celula=imread(I(i).name);
 figure, imshow(Celula), set(gcf, 'Name', 'Mascara célula')

 Mascara_cel=imbinarize(Celula); 
 etiquetas_final_cel=bwlabeln(Mascara_cel);

 %% LDs
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-24 Análisis 3º experimento\Mascaras\Mascaras_LD_seleccionados');
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
     mask1(etiquetas_final_cel==b)=1; %da valor 1 a los píxeles del área equivalente a una etiqueta con numero específico

     mascara_cel_bucle=double(mask1).*double(Mascara_cel); %aplica esta máscara a la imagen binaria (selecciona dicha célula)
     area_celula=sum(mascara_cel_bucle(:)>0); %calcula el área total que ocupan esta célula, en píxeles
     Size_cel(b)=area_celula;

     mascara_LD_bucle=double(mask1).*double(Mascara_LD); %aplica esta máscara a la imagen binaria de los LDs (selecciona los LDs de la célula de interés).
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
archivo = 'AreaporAreaporCel3.xlsx';
writecell(tabla_areaporarea, fullfile(ruta, archivo));


media_AreaLD_por_celula=mean(AreaLD_por_celula);
sd_AreaLD_por_celula=std(AreaLD_por_celula);

LDsarea(i,1)=media_AreaLD_por_celula; %guarda el resultado para esta imagen
desviacion_area(i,1)=sd_AreaLD_por_celula/ sqrt(length(etiquetas_final_cel)); %error estándar
Experimento{i,1}=I(i).name;
end

%comparacion a y b
T2=table(Experimento,LDsarea,desviacion_area);
disp(T2)

ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Areas';
archivo = 'MediaAreaAYB3.xlsx';
writetable(T2, fullfile(ruta, archivo));

figure, bar(LDsarea), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD area/Cell area'), set(gcf, 'Name', 'Resultado Área')
hold on
x = 1:length(nombre_exp);
xticks(x);
xticklabels({'WT Control','KO Control','WT OA 24h a','WT OA 24h b','KO OA 24h a','KO OA 24h b','WT WS-Ch 24h a','WT WS-Ch 24h b','KO WS-Ch 24h a','KO WS-Ch 24h b'})
errorbar(x, LDsarea, desviacion_area, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off

%comparacion wt y ko (unificacion a y b)
tabla_areaporarea_final = table(tabla_areaporarea, 'VariableNames', {'Vectores_areaporarea'});
num_vectores1 = height(tabla_areaporarea_final);  % Número de vectores
LDsareaAYB=zeros(length(ExperimentoAYB));

vector_WT_control_area=tabla_areaporarea_final.Vectores_areaporarea{1}'; %como de los controles no tenemos 2 espectros, tenemos que incorporarlos manualmente
media_AreaLD_por_celula_WT_control=mean(vector_WT_control_area);
sd_AreaLD_por_celula_WT_control=std(vector_WT_control_area);
LDsareaAYB(1,1)=media_AreaLD_por_celula_WT_control; %guarda el resultado para esta imagen
desviacion_areaAYB(1,1)=sd_AreaLD_por_celula_WT_control/ sqrt(length(vector_WT_control_area)); %error estándar

vector_KO_control_area=tabla_areaporarea_final.Vectores_areaporarea{2}';
media_AreaLD_por_celula_KO_control=mean(vector_KO_control_area);
sd_AreaLD_por_celula_KO_control=std(vector_KO_control_area);
LDsareaAYB(2,1)=media_AreaLD_por_celula_KO_control; %guarda el resultado para esta imagen
desviacion_areaAYB(2,1)=sd_AreaLD_por_celula_KO_control/ sqrt(length(vector_KO_control_area)); %error estándar


for i = 3:2:num_vectores1-1
    vector_AYB = [tabla_areaporarea_final.Vectores_areaporarea{i}', tabla_areaporarea_final.Vectores_areaporarea{i+1}']; %traspuesto
    media_AreaLD_por_celulaAYB=mean(vector_AYB);
    sd_AreaLD_por_celulaAYB=std(vector_AYB);

    LDsareaAYB(i,1)=media_AreaLD_por_celulaAYB; %guarda el resultado para esta imagen
    desviacion_areaAYB(i,1)=sd_AreaLD_por_celulaAYB/ sqrt(length(vector_AYB)); %error estándar
end

LDsareaAYB=LDsareaAYB(LDsareaAYB ~= 0); %como el bucle va de 2 en 2, genera un vector de 12 componentes en la que las impares tienen el valor 0, así que tenemos que eliminarlos
desviacion_areaAYB=desviacion_areaAYB(desviacion_areaAYB ~= 0);

T3=table(ExperimentoAYB(:),LDsareaAYB,desviacion_areaAYB);
disp(T3)

ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Areas';
archivo = 'MediaArea3.xlsx';
writetable(T3, fullfile(ruta, archivo));

figure, bar(LDsareaAYB), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD area/Cell area'), set(gcf, 'Name', 'Resultado Área')
hold on
x = 1:length(ExperimentoAYB);
xticks(x);
xticklabels({'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'})
errorbar(x, LDsareaAYB, desviacion_areaAYB, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off


%% Distribución tamaños.
ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\TamañosLD';
archivo = 'LDsize3.xlsx';
writecell(tabla_size_LD, fullfile(ruta, archivo));

end 