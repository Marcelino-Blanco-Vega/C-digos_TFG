function SegmentacionArea1
% Para coger los ficheros de su ubicación
cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\HeLa TIFF_average\Cell\');
addpath('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Prueba Automatización');
I=dir('*.tif');
% Para preparar las variables finales
nI=size(I,1);
Experimento=cell(nI,1);
%numeroLDs=zeros(nI,1);
%desviacion_numero=zeros(nI,1);
LDsarea=zeros(nI,1);
desviacion_area=zeros(nI,1);
tabla_size_cell={};
tabla_size_LD={};
nombre_exp= ['1', '2', '3', '4', '5', '6'];
radio_aver=1;
size_fmediana=20;
radio_ero=0;

% Bucle que actúe sobre cada imagen
for i=1:nI
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\HeLa TIFF_average\Cell\');
 Celula=imread(I(i).name);
 figure, imshow(Celula), set(gcf, 'Name', 'Celula sin modificar')

 %% Células
 Celula_contraste=imadjust(Celula, [0.117 0.468], [0 1]); %8-bit= 30-120
 %figure, imshow(Celula_contraste), set(gcf, 'Name', 'ventana celulas')
 
 aver = fspecial('average', radio_aver);
 Celula_aver = imfilter(Celula_contraste, aver, 'same');
 
 %figure, imshow(Celula_aver), set(gcf, 'Name', 'Celula Average')

 Celula_filt=medfilt2(Celula_aver, [size_fmediana size_fmediana]);
 gradiente= imgradient(Celula_filt);
 L=watershed(gradiente);
 Celula_wshed=L < 1;
 %figure, imshow(Celula_wshed), title('Celula Watershed filtro mediana'), set(gcf, 'Name', 'Celulas tras Watershed')

 Celula_full=imfill(Celula_wshed, 'holes');
 %figure, imshow(Celula_full), title('Celula Binarizada con Wshed+Fill'),set(gcf, 'Name', 'Celula binaria')
 %figure, imshowpair(Celula_wshed,Celula_full),title('Comparativa relleno'), set(gcf, 'Name', 'Comparativa relleno')
 
 %Celula_full_clean1=imclearborder(Celula_full); %permite ser más laxo a la hora de quitar bordes

 %Quitabordes estricto
 %Celula_full_edges=edge(Celula_full);
 %Celula_full_edges_full=imfill(Celula_full_edges,'holes');
 %Celula_full_clean2=imclearborder(Celula_full_edges_full); %es más restrictivo quitando bordes, pierde demasiada info
 %figure, imshowpair(Celula_full_clean1,Celula_full_clean2),title('Comparativa quitabordes'), set(gcf, 'Name', 'Comparativa quitabordes')
 
 SE=strel('disk', radio_ero);
 %Celula_full_erode=imerode(Celula_full_clean1,SE); %coninúa el algoritmo quitando bordes
 Celula_full_erode=imerode(Celula_full,SE);
 %figure, imshowpair(Celula_full,Celula_full_erode),title('Comparativa erosion'), set(gcf, 'Name', 'Comparativa erosion')
  
 %Etiquetas sin filtrar
 etiquetas_cel=bwlabeln(Celula_full_erode);
 %figure, imshow(etiquetas_cel), set(gcf, 'Name', 'Etiquetas sin filtrar, full')
 stats = regionprops(etiquetas_cel, 'Area'); %calcula el tamaño de cada etiqueta
 vector_pixeles_eti = [stats.Area]; %almacena los tamaños en un vector
 %figure, histogram(vector_pixeles_eti, 50), title('Histograma de Tamaños de Células Prefiltrado'); xlabel('Tamaño de área (píxeles)'); ylabel('Frecuencia')
 
 %Filtrado de etiquetas
 pixeles_min_cel = 2000;
 etiquetas_final_cel=etiquetas_cel;
    for n = 1:length(vector_pixeles_eti)
        if vector_pixeles_eti(n) < pixeles_min_cel
            etiquetas_final_cel(etiquetas_cel == n) = 0; % Elimina la etiqueta
        end
    end
 
 etiquetas_final_cel = bwlabeln(etiquetas_final_cel > 0);
 figure, imshow(etiquetas_final_cel), set(gcf, 'Name', 'Células post filtrado')
 stats2 = regionprops(etiquetas_final_cel, 'Area'); %calcula el tamaño de cada etiqueta
 vector_pixeles_etif = [stats2.Area]; %almacena los tamaños en un vector
 %figure, histogram(vector_pixeles_etif, 40), title('Histograma de Tamaños de Células Postfiltrado'); xlabel('Tamaño de área (píxeles)'); ylabel('Frecuencia')
 tabla_size_cell{i,1}=vector_pixeles_etif;

 binary_final_cel=imbinarize(etiquetas_final_cel); 
 final_cel_255=binary_final_cel*255;

 ruta = 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascara_Celulas';
 filename = sprintf('Mascara_Cel%s.tif', nombre_exp(i));
 filepath = fullfile(ruta, filename);
 imwrite(final_cel_255, filepath);

 %% LDs
 cd('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\HeLa TIFF_average\LD\');
 L=dir('*.tif');
 LD=imread(L(i).name);
 LD(~binary_final_cel) = 0; %aplicar la máscara a los LDs
 %figure, imshow(LD), set(gcf, 'Name', 'LD tras aplicar mascara')
 LD_contraste=imadjust(LD, [0.33 1], [0 1]); %8-bit= 84-255
 %figure, imshow(LD_contraste), set(gcf, 'Name', 'ventana LDs y autoF')

 LD_aver = imfilter(LD_contraste, aver, 'same');
 LD_binary=edge(LD_aver,'log');
 LD_full=imfill(LD_binary,'holes');
 %figure, imshowpair(LD_binary,LD_full), set(gcf, 'Name', 'LDs binario y relleno')

 

  %Etiquetas sin filtrar
 etiquetasLD=bwlabeln(LD_full);
 %figure, imshow(etiquetasLD), set(gcf, 'Name', 'LDs sin filtrar, full')

 statsLD = regionprops(etiquetasLD, 'Area'); %calcula el tamaño de cada etiqueta
 vector_pixeles_etiLD = [statsLD.Area]; %almacena los tamaños en un vector
 %figure, histogram(vector_pixeles_etiLD, 100), title('Histograma de Tamaños de LDs prefiltrado'); xlabel('Tamaño de área (píxeles)'); ylabel('Frecuencia')

  %Filtrado de etiquetas
 pixeles_min_LD = 10;
 etiquetas_final_LD=etiquetasLD;
    for n = 1:length(vector_pixeles_etiLD)
        if vector_pixeles_etiLD(n) < pixeles_min_LD
            etiquetas_final_LD(etiquetasLD == n) = 0; % Elimina la etiqueta
        end
    end
 
 etiquetas_final_LD = bwlabeln(etiquetas_final_LD > 0);
 figure, imshow(etiquetas_final_LD), set(gcf, 'Name', 'LDs post filtrado')

 %Quitar AutoF
         % Mostrar etiquetas en color
        figure;
        imshow(label2rgb(etiquetas_final_LD));
        title('Haz clic sobre los objetos que quieras eliminar. Pulsa Enter cuando termines.');
        
        labels_to_delete = [];  % aquí guardamos las etiquetas seleccionadas
        
        while true
        [x, y, button] = ginput(1);
        if isempty(x)  % Si se presiona Enter sin hacer clic, se sale del bucle
            break;
        end
        
        % Obtener etiqueta en ese punto
        clicked_label = etiquetas_final_LD(round(y), round(x));
        
        if clicked_label > 0
            labels_to_delete(end+1) = clicked_label;  % guarda la etiqueta
            disp(['Etiqueta seleccionada: ', num2str(clicked_label)]);
            
            % Marcar visualmente las etiquetas eliminadas
            hold on;
            plot(x, y, 'rx', 'MarkerSize', 3, 'LineWidth', 1);
        else
            disp('Área sin etiqueta.');
        end
        end
        
        % Eliminar etiquetas seleccionadas
        if ~isempty(labels_to_delete)
            etiquetas_final_LD(ismember(etiquetas_final_LD, labels_to_delete)) = 0;
            disp(['Se eliminaron ', num2str(length(labels_to_delete)), ' etiquetas.']);
        else
            disp('No se seleccionó ninguna etiqueta. Nada fue eliminado.');
        end
        
        % Mostrar resultado
        figure;
        imshow(etiquetas_final_LD);
        title('Resultado tras eliminar etiquetas seleccionadas');
        
        % Reetiquetar:
        etiquetas_final_LD = bwlabel(etiquetas_final_LD > 0);

 stats2 = regionprops(etiquetas_final_LD, 'Area'); %calcula el tamaño de cada etiqueta
 vector_pixeles_etif_LD = [stats2.Area]; %almacena los tamaños en un vector
 %figure, histogram(vector_pixeles_etif_LD, 100), title('Histograma de Tamaños de LDs postfiltrado'); xlabel('Tamaño de área (píxeles)'); ylabel('Frecuencia')
 tabla_size_LD{i,1}=vector_pixeles_etif_LD;


 binary_final_LD=imbinarize(etiquetas_final_LD);   
 final_LD_255=etiquetas_final_LD*255;

 ruta2= 'C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-02-19 Análisis 1º experimento\Mascaras\Mascara_LD';
 filename = sprintf('Mascara_LD%s.tif', nombre_exp(i));
 filepath = fullfile(ruta2, filename);
 imwrite(final_LD_255, filepath);
 

end