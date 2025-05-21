inputDir = getDirectory("Select an input directory");
list = getFileList(inputDir);
numberimages=lengthOf(list);
names = newArray(numberimages); 
ids = newArray(numberimages); 

outputDir = getDirectory("Select an output directory");

for (q=0; q < ids.length; q++){ 
		open(inputDir + list[q]);
		print("Abriendo imagen: " + list[q]);
		showProgress(q, numberimages);
        ids[q] = getImageID(); 
        names[q] = getTitle(); 
        selectWindow(names[q]);
        run("Z Project...", "start=24 stop=30 projection=[Average Intensity]");
        
        saveAs("Tiff", outputDir + "/" + names[q] + "_LD_24-30" + ".tif");
        close("*"); // Cierra todas las imágenes abiertas
}

close("*"); // Cierra todas las imágenes abiertas
print("Proceso completado.");