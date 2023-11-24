args = split(getArgument(), ",");

input = args[0];

//segDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/segs";
morphDir = "/nemo/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/cell_morph_2D";

//fileList = getFileList(segDir);

print("Input is " + input);

setBatchMode(true);

//for (i = 0; i < fileList.length; i++) {
if(indexOf(input, "cell") > 0){
	print("Processing " + input);
//	open(segDir + File.separator() + input);
	open(input);
	run("Z Project...", "projection=[Max Intensity]");
	proj = getTitle();
	run("Set Measurements...", "area perimeter bounding fit shape feret's display redirect=None decimal=3");
	run("Analyze Particles...", "  show=Nothing display exclude");
	resultsFile = morphDir + File.separator() + File.getNameWithoutExtension(input) + "_cell_morph_2D.csv";
	print("Saving " + resultsFile);
	saveAs("Results", resultsFile);
	close("*");
	run("Clear Results");
}
//}

setBatchMode(false);

print("Done");