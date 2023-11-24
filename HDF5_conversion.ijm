setBatchMode(true);

args = split(getArgument(), ",");
inputFile = args[0];
outputDir = args[1];
fileName = File.getName(inputFile);

print("Opening " + inputFile);
open(inputFile);
run("Split Channels");
close("C1*");
channel2 = getTitle();
selectWindow(channel2);
run("Grays");
print("Saving " + outputDir + File.separator + fileName);
//run("Export HDF5", "select=[" + channel2 + ".h5] exportpath=[" + outputDir + File.separator() + fileName + ".h5] datasetname=data compressionlevel=0 input=[" + channel2 + "]");
saveAs("TIFF", outputDir + File.separator + fileName);

print("Done.");

close("*");

setBatchMode(false);