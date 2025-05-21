function CuantificacionNumero1
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascaras_celulas_modificadas\');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Prueba Automatización');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
Experimento=cell(nI,1);
numeroLDs=zeros(nI,1);
desviacion_numero=zeros(nI,1);
%LDsarea=zeros(nI,1);
%%desviacion_area=zeros(nI,1);
%tabla_size_cell={};
%tabla_size_LD={};
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


 %% Contabilizar números
 %NumeroLD_por_celula=zeros(size(unique(etiquetas_final_cel),1),1);
 numero_LD=zeros(size(unique(etiquetas_final_cel),1),1);
 t =max(max(unique(etiquetas_final_cel)));

 for b=1:t
     mask1=zeros(size(Mascara_cel)); %crea una matriz de 0, del mismo tamaño que la imagen original
     mask1(etiquetas_final_cel==b)=1; %da valor 1 a los píxeles del área equivalente a una etiqueta con numero específico
     %mascara_cel_bucle=double(mask1).*double(Mascara_cel); %aplica esta máscara a la imagen binaria (selecciona dicha célula)
     eti_LD_bucle=bwlabeln(double(mask1).*double(Mascara_LD)); %aplica esta máscara a la imagen binaria de las LDs (selecciona las LDs de la célula de interés). Además, las cuenta etiquetándolas
     numero_LD(b)=max(max(unique(eti_LD_bucle))); %obtiene el número de LD dentro del área de esta célula
 end

%NumeroLD_por_celula %esto guardarlo en excel, célula por célula
tabla_nporcel{i,1}= numero_LD; %tabla en la que en cada fila se almacenan el 'area por area' de todas las células de un campo
ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Numeros';
archivo = 'NumeroporCel1.xlsx';
writecell(tabla_nporcel, fullfile(ruta, archivo));


media_NumeroLD_por_celula=mean(numero_LD); %da la media para una condición experimental (para una imagen)
sd_NumeroLD_por_celula=std(numero_LD);

numeroLDs(i,1)=media_NumeroLD_por_celula; %guarda el resultado para esta imagen
desviacion_numero(i,1)=sd_NumeroLD_por_celula/ sqrt(length(etiquetas_final_cel)); %error estándar
Experimento{i,1}=I(i).name;

end

%% Resultados números

T1=table(Experimento,numeroLDs,desviacion_numero);
disp(T1)

ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Numeros';
archivo = 'MediaNumero1.xlsx';
writetable(T1, fullfile(ruta, archivo));


figure, bar(numeroLDs), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD number/Cell'), set(gcf, 'Name', 'Resultado Número')
hold on
x = 1:length(nombre_exp);
xticks(x);
xticklabels({'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'})
errorbar(x, numeroLDs, desviacion_numero, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off

figure, bar(numeroLDs(1:2)), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD area/Cell area'), set(gcf, 'Name', 'Area result')
hold on
x = 1:length(nombre_exp);
xticks(x);
xticklabels({'WT Control','KO Control'});
errorbar(x, numeroLDs(1:2), desviacion_numero(1:2), 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off


end 