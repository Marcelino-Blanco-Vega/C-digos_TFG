function CuantificacionNumero2
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-17 Análisis 2º experimento\Mascaras\Mascaras_Celulas_modificadas\');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-17 Análisis 2º experimento\');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
Experimento=cell(nI,1);
numeroLDs=zeros(nI,1);
desviacion_numero=zeros(nI,1);
nombre_exp= ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'];

% Bucle que actúe sobre cada imagen
for i=1:nI
 %% Células
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-17 Análisis 2º experimento\Mascaras\Mascaras_Celulas_modificadas\');
 Celula=imread(I(i).name);
 figure, imshow(Celula), set(gcf, 'Name', 'Mascara célula')

 Mascara_cel=imbinarize(Celula); 
 etiquetas_final_cel=bwlabeln(Mascara_cel);

 %% LDs
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-17 Análisis 2º experimento\Mascaras\\Mascaras_LD_seleccionados\');
 L=dir('*.tif');
 LD=imread(L(i).name);
 figure, imshow(LD), set(gcf, 'Name', 'Mascara LD')

 Mascara_LD=imbinarize(LD);


 %% Contabilizar números
 numero_LD=zeros(size(unique(etiquetas_final_cel),1),1);
 t =max(max(unique(etiquetas_final_cel)));

 for b=1:t
     mask1=zeros(size(Mascara_cel)); %crea una matriz de 0, del mismo tamaño que la imagen original
     mask1(etiquetas_final_cel==b)=1; %da valor 1 a los píxeles del área equivalente a una etiqueta con numero específico
     mascara_LD_bucle=bwlabeln(double(mask1).*double(Mascara_LD)); %aplica esta máscara a la imagen binaria de las LDs (selecciona las LDs de la célula de interés). Además, las cuenta etiquetándolas
     numero_LD(b)=max(max(unique(mascara_LD_bucle))); %obtiene el número de LD dentro del área de esta célula
 end

%NumeroLD_por_celula %esto guardarlo en excel, célula por célula
tabla_nporcel{i,1}= numero_LD; %tabla en la que en cada fila se almacenan el 'area por area' de todas las células de un campo
ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Numeros';
archivo = 'NumeroporCel2.xlsx';
writecell(tabla_nporcel, fullfile(ruta, archivo));

media_NumeroLD_por_celula=mean(numero_LD); %da la media para una condición experimental (para una imagen)
sd_NumeroLD_por_celula=std(numero_LD);


numeroLDs(i,1)=media_NumeroLD_por_celula; %guarda el resultado para esta imagen
desviacion_numero(i,1)=sd_NumeroLD_por_celula/ sqrt(length(etiquetas_final_cel)); %error estándar
Experimento{i,1}=I(i).name;

end

%% Resultados números
%a vs b
T1=table(Experimento,numeroLDs,desviacion_numero);
disp(T1)

ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Numeros';
archivo = 'MediaNumeroAYB2.xlsx';
writetable(T1, fullfile(ruta, archivo));


figure, bar(numeroLDs), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD number/Cell'), set(gcf, 'Name', 'Resultado Número')
hold on
x = 1:length(nombre_exp);
xticks(x);
xticklabels({'WT Control a','WT Control b','KO Control a','KO Control b','WT OA 24h a','WT OA 24h b','KO OA 24h a','KO OA 24h b','WT WS-Ch 24h a','WT WS-Ch 24h b','KO WS-Ch 24h a','KO WS-Ch 24h b'})
errorbar(x, numeroLDs, desviacion_numero, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off


%comparacion wt y ko (unificacion a y b)
tabla_numero_final = table(tabla_nporcel, 'VariableNames', {'Vectores_numeroporcel'});
num_vectores1 = height(tabla_numero_final);  % Número de vectores

    %unificacion de vectores
    for i = 1:2:num_vectores1-1
        vector_AYB = [tabla_numero_final.Vectores_numeroporcel{i}', tabla_numero_final.Vectores_numeroporcel{i+1}']; %traspuesto
        media_nLD_por_celulaAYB=mean(vector_AYB);
        sd_nLD_por_celulaAYB=std(vector_AYB);
    
        LDsnAYB(i,1)=media_nLD_por_celulaAYB; %guarda el resultado para esta imagen
        desviacion_nAYB(i,1)=sd_nLD_por_celulaAYB/ sqrt(length(vector_AYB)); %error estándar
    end
    
    LDsnAYB=LDsnAYB(LDsnAYB ~= 0); %como el bucle va de 2 en 2, genera un vector de 12 componentes en la que las impares tienen el valor 0, así que tenemos que eliminarlos
    desviacion_nAYB=desviacion_nAYB(desviacion_nAYB ~= 0);

ExperimentoAYB={'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'};
T3=table(ExperimentoAYB(:),LDsnAYB,desviacion_nAYB);
disp(T3)

ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-05-09 Análisis completo\Numeros';
archivo = 'MediaNumero2.xlsx';
writetable(T3, fullfile(ruta, archivo));

figure, bar(LDsnAYB), title('CSP effect on LD generation'), xlabel('Experimental condition'), ylabel('LD number/Cell'), set(gcf, 'Name', 'Resultado Número')
hold on
x = 1:length(ExperimentoAYB);
xticks(x);
xticklabels({'WT Control','KO Control','WT OA 24h','KO OA 24h','WT WS-Ch 24h','KO WS-Ch 24h'})
errorbar(x, LDsnAYB, desviacion_nAYB, 'k', 'LineStyle', 'none', 'LineWidth', 0.5);
hold off

end 