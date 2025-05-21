function Unificacion_datos

% Seleccionar la carpeta con los CSV
inputDir = uigetdir('C:\Users\USUARIO\Documents\Estudios\Universidad\4to\4to Segundo Cuatri\TFG\TFG\Raman\2025-03-17 Análisis 2º experimento\Results\Cells\', 'Selecciona la carpeta con los archivos CSV');

if inputDir == 0
    disp('Selección cancelada. No se procesarán archivos.');
    return;
end

% Seleccionar el archivo de salida Excel
[excelFile, outputDir] = uiputfile('*.xlsm', 'Guardar archivo Excel como');

if excelFile == 0
    disp('Guardado cancelado.');
    return;
end

outputExcel = fullfile(outputDir, excelFile);

% Obtener lista de archivos CSV
csvFiles = dir(fullfile(inputDir, '*.csv'));

if isempty(csvFiles)
    disp('No se encontraron archivos CSV en la carpeta seleccionada.');
    return;
end

% Ordenar numéricamente los archivos basándonos en el número principal del nombre
fileNames = {csvFiles.name};
fileNums = zeros(size(fileNames));

for i = 1:length(fileNames)
    name = fileNames{i};
    % Extraer *último* número del nombre por si hay varios (más fiable en casos como 'data_1_10.csv')
    nums = regexp(name, '\d+', 'match');
    fileNums(i) = str2double(nums{end});
end

[~, sortedIdx] = sort(fileNums);
csvFiles = csvFiles(sortedIdx);  % reordenar estructura completa

% Leer y guardar los datos
numFiles = length(csvFiles);
allData = cell(1, numFiles);
columnNames = {};

for i = 1:numFiles
    csvFile = fullfile(inputDir, csvFiles(i).name);
    data = readtable(csvFile);
    allData{i} = data;

    if isempty(columnNames)
        columnNames = data.Properties.VariableNames;
    end
end

% Escribir cada tipo de dato (columna) en una hoja diferente
for j = 1:length(columnNames)
    sheetName = columnNames{j}; 
    combinedData = table();

    for i = 1:numFiles
        if j <= width(allData{i})
            columnData = allData{i}(:, j);
            [~, name, ~] = fileparts(csvFiles(i).name);
            newVarName = matlab.lang.makeValidName(name);
            columnData.Properties.VariableNames = {newVarName};
            combinedData = [combinedData columnData];
        end
    end

    writetable(combinedData, outputExcel, 'Sheet', sheetName);
end

disp('✅ Proceso completado. El archivo Excel se ha guardado en:');
disp(outputExcel);

end