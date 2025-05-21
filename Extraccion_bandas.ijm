inputDir = getDirectory("Select an input directory (spectra.tif)");
outputDir = getDirectory("Select an output directory (folder for Raman bands)");
list = getFileList(inputDir);

numberimages=lengthOf(list);

names = newArray(numberimages); 
ids = newArray(numberimages); 


for (q=0; q < ids.length; q++){ 
		open(inputDir + list[q]);
		print("Abriendo imagen: " + list[q]);
		showProgress(q, numberimages);
        selectImage(q+1); 
        ids[q] = getImageID(); 
        names[q] = getTitle(); 
        selectWindow(names[q]);
	    getDimensions(width, height, channels, slices, frames);
	    print("Ancho: " + width);
		print("Alto: " + height);
		print("Canales: " + channels);
		print("Slices: " + slices);
		print("Frames: " + frames);
	    
	    for (f=1; f <= frames; f++){ 
			selectImage(q+1);
			run("Make Substack...", "frames="+f);
			saveAs("Tiff", outputDir + "/" + names[q] + "-substack_" + f + ".tif");
   		    close();
}
}

close("*"); // Cierra todas las imágenes abiertas
print("Proceso completado.");