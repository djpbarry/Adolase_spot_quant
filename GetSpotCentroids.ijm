args = split(getArgument(), ",");

input = args[0];

//segDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/segs";
centDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/centroids";

//fileList = getFileList(segDir);

print("Input is " + input);

setBatchMode(true);

//for (i = 0; i < fileList.length; i++) {
if(indexOf(input, "spots") > 0){
	print("Processing " + input);
//	open(segDir + File.separator() + input);
	open(input);
	run("3D Centroid");
	resultsFile = centDir + File.separator() + File.getNameWithoutExtension(input) + "_centroids.csv";
	print("Saving " + resultsFile);
	saveAs("Results", resultsFile);
	close("*");
	run("Clear Results");
}
//}

setBatchMode(false);

print("Done");