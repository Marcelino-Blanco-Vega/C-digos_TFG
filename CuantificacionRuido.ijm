run("Set Measurements...", "area mean standard min max display redirect=None decimal=3");

inputDir1 = getDirectory("Select an input directory for Raman bands");
//inputDir1 = "C:/Users/USUARIO/Documents/Estudios/Universidad/4to/4to Segundo Cuatri/TFG/TFG/Raman/2025-02-19 Análisis 1º experimento/HeLa TIFF_Raman bands/";
list1 = getFileList(inputDir1);
numberimages1 = lengthOf(list1);
names1 = newArray(numberimages1); 
ids1 = newArray(numberimages1); 

// Función para extraer el número (después del "_", antes del ".tif")
function extractNumber(name) {
    underscore = indexOf(name, "_");
    dot = lastIndexOf(name, ".");
    return parseInt(substring(name, underscore + 1, dot));
}

// Función para extraer la letra (prefijo del nombre)
function extractLetter(name) {
    return substring(name, 0, 1);
}

// Ordenar list1 por número y luego por letra
for (i = 0; i < list1.length - 1; i++) {
    for (j = i + 1; j < list1.length; j++) {
        numI = extractNumber(list1[i]);
        numJ = extractNumber(list1[j]);
        letterI = extractLetter(list1[i]);
        letterJ = extractLetter(list1[j]);

        if (numI > numJ || (numI == numJ && letterI > letterJ)) {
            temp = list1[i];
            list1[i] = list1[j];
            list1[j] = temp;
        }
    }
}


inputDir2 = getDirectory("Select an input directory for binary masks");
//inputDir2 = "C:/Users/USUARIO/Documents/Estudios/Universidad/4to/4to Segundo Cuatri/TFG/TFG/Raman/2025-02-19 Análisis 1º experimento/Mascaras/Mascaras_celulas_modificadas/";
list2 = getFileList(inputDir2);
numberimages2 = lengthOf(list2);
names2 = newArray(numberimages2); 
ids2 = newArray(numberimages2);

outputDir = getDirectory("Select an output directory");
//outputDir = "C:/Users/USUARIO/Documents/Estudios/Universidad/4to/4to Segundo Cuatri/TFG/TFG/Raman/2025-02-19 Análisis 1º experimento/Results/Cells";


m=0;
nband=0;

//Da un bucle por banda
for (q=0; q < names1.length; q++){ 
	
	//Abre las diferentes máscaras en ciclos de 6 (1-6, 1-6, etc.)
        m = (q % names2.length);

        open(inputDir2 + list2[m]);
		print("Abriendo imagen: " + list2[m]);
		showProgress(m, numberimages2);
        //selectImage(m+1);        
        ids2[m] = getImageID(); 
        names2[m] = getTitle(); 
        selectWindow(names2[m]);
	    getDimensions(width, height, channels, slices, frames);
		print(ids2[m] + " = " + names2[m] + "   Mask= " + m);
		//wait(1000);
		
		run("Analyze Particles...", "display clear include add"); //genera los ROIs de interés
		//run("ROI Manager...");
		close(names2[m]);
		
	//Abre una banda Raman con cada iteración del bucle (abre la primera banda en todas, luego la segunda en todas, etc.)
        open(inputDir1 + list1[q]);
		print("Abriendo imagen: " + list1[q]);
		showProgress(q, numberimages1);
        //selectImage(q+1);
        
        ids1[q] = getImageID(); 
        names1[q] = getTitle(); 
        selectWindow(names1[q]);
	    getDimensions(width, height, channels, slices, frames);
        print(ids1[q] + " = " + names1[q] + "   Raman band= " + q); 
        //wait(1000);
       
		
	//Medir ruido, intensidad en zona donde no hay células.
		run("ROI Manager...");
		run("Select All");
		roiManager("Combine");
		roiManager("Add"); //genera un único roi con todas las células
		
		makeRectangle(0, 0, width, height);
		roiManager("Add"); //genera un roi con toda la imagen
		
		roiCount = roiManager("Count");
		roiManager("Select", newArray(roiCount - 2, roiCount - 1)); // selecciona los dos ultimos roi creados
		roiManager("XOR"); // selecciona el área no común a los rois seleccionados: área no celular
		roiManager("Add");
		
		roiManager("Select", roiManager("Count") - 1); // Medir solo la ROI inversa (última añadida)
		run("Clear Results");
		roiManager("Measure");   
		

			
		selectWindow("Results");
		
		if (q % names2.length == 0 && q != 0) {
        nband++;
        } //cada 6 iteraciones aumenta en 1 el número de banda
        
		saveAs("Results", outputDir + "background_experiment_" + m+1 + "_band_" + nband+1 + ".csv");
				
		//roiManager("Save",outputDir + names1[q] +'-ROIset.zip');	
		roiManager("reset");
		
		//wait(1000);
		close("*");

		//selectWindow("Log");
		//saveAs("Text", outputDir + "experiment_" + m+1 + "_band_" + nband + ".txt");
}


if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );
    }
    
if (isOpen("Log")) {
         selectWindow("Log");
         run("Close" );
    }
    
if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");
	}
    
close("*"); // Cierra todas las imágenes abiertas
print("Proceso completado.");