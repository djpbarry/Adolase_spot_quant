var n_erosions = 2;
var initial_spot_size = 2;
var nCPUs = parseInt(call("ij.util.ThreadUtil.getNbCpus"));
var morphDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/morph";
var plotDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/plots";
var segDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/segs";
var intensDir = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/intensities";

args = split(getArgument(), ",");
prob_input = args[0];
raw_input = args[1];

//prob_input = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/pix_probs/1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0 - 1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0_Probabilities.tiff";
//raw_input = "/camp/stp/lm/inputs/tybulewiczv/Robert/iSIM Stacks for Dave (Phalloidin)/220706 CD46 KO stacks 2 experiments/1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0 - 1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0.tif";
//prob_input = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/test_input/1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0 - 1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0_Probabilities-1.tif";
//raw_input = "/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/test_input/1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0 - 1min-ko-CD3-CD46-E1_01_1_MMStack_Pos0-1.tif";


setBatchMode(true);

print("Opening " + prob_input);
open(prob_input);
orig = getTitle();
getDimensions(width, height, channels, slices, frames);
n = channels * slices * frames;
run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=" + (n / 2) + " frames=1 display=Grayscale");
run("Split Channels");
close("C2*");
rename("prob_map");
prob_actin = getTitle();
print("Smoothing...");
run("Gaussian Blur 3D...", "x=2.8 y=2.8 z=1.0");
setThreshold(10000, 65535, "raw");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Huang background=Dark");
setOption("BlackBackground", false);
print("Filling holes...");
run("Fill Holes", "stack");
//run("Invert", "stack");
//run("3D Exclude Edges", " ");
//selectWindow("Objects_removed");
binary = getTitle();
print("Labelling objects...");
run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
rename("Object_Labels");
labels = getTitle();
close("\\Others");
print("Analysing object volumes...");
run("3D Volume");
//run("Analyze Regions 3D", "volume surface_area mean_breadth sphericity euler_number bounding_box centroid equivalent_ellipsoid ellipsoid_elongations max._inscribed surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
updateTable("Volume(Pix)", 1000000);
saveAs("results", morphDir + File.separator() + orig + ".csv");
maxVols = Table.getColumn("Volume(Pix)");
objLabels = Table.getColumn("LabelObj");
run("Clear Results");
print("Opening " + raw_input);
open(raw_input);
run("Split Channels");
images = getList("image.titles");
for (i = 0; i < images.length; i++) {
	if(startsWith(images[i], "C1")){
		selectWindow(images[i]);
		rename("spot_input");
		spotInput = getTitle();
	} else if(startsWith(images[i], "C2")){
		selectWindow(images[i]);
		rename("actin");
		actin = getTitle();
	}
}
selectWindow(spotInput);
print("Calculating DoG for spot size " + initial_spot_size);
run("Duplicate...", "duplicate");
run("Gaussian Blur 3D...", "x=" + (initial_spot_size + 1) + " y=" + (initial_spot_size + 1) + " z=" + ((initial_spot_size + 1) / 3.0));
rename("large");
selectWindow(spotInput);
run("Duplicate...", "duplicate");
run("Gaussian Blur 3D...", "x=" + (initial_spot_size - 1) + " y=" + (initial_spot_size - 1) + " z=" + ((initial_spot_size - 1) / 3.0));
rename("small");
imageCalculator("Subtract create 32-bit stack", "small","large");
rename("Difference of Gaussians");
dog = getTitle();
close("small");
close("large");
selectWindow(dog);
setAutoThreshold("Li dark stack");
setOption("BlackBackground", false);
run("Convert to Mask", "method=Li background=Dark");
rename("Spots");
spots = getTitle();
for (i = 0; i < objLabels.length; i++) {
	print("Processing object " + (i + 1) + " of " + objLabels.length);
	selectWindow(labels);
	run("Duplicate...", "duplicate");
	setThreshold(objLabels[i] - 0.1, objLabels[i] + 0.1, "raw");
	run("Convert to Mask", "method=Li background=Dark");
	print("Saving cell mask...");
	saveAs("TIFF", segDir + File.separator() + orig + "_cell_" + objLabels[i] + ".tiff");
	rename("Mask");
	mask = getTitle();
	analyseSpots(spots, mask, actin, orig, initial_spot_size);
	selectWindow(spots);
	run("Duplicate...", "duplicate");
	dilated = getTitle();
	for(s = initial_spot_size + 1; s <= initial_spot_size + n_erosions; s++){
		print("Dilating spots...");
		selectWindow(dilated);
		temp = getTitle();
		run("Morphological Filters (3D)", "operation=Dilation element=Ball x-radius=1 y-radius=1 z-radius=0.3");
		dilated = getTitle();
		close(temp);
		analyseSpots(dilated, mask, actin, orig, s);
	}
	close(mask);
	print("Object " + (i + 1) + " finished");
}

close("*");

setBatchMode(false);

print("Analysis complete.");

exit();

function updateTable(col, thresh){
	for (i = 0; i < nResults(); i++) {
		if(getResult(col, i) < thresh){
			IJ.deleteRows(i, i);
			i--;
		}
	}
}

function analyseSpots(spots, mask, actin, orig, s){
	print("Analysing spot size " + s);
		imageCalculator("AND create stack", mask, spots);
		run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
		filteredSpots = getTitle();
		run("3D Distances", "image_a=[" + filteredSpots + "] image_b=[" + mask + "] distance_maximum_cc=1000 distance_maximum_cb_(pix)=1000 distance_maximum_cb_(unit)=1000 distance_maximum_bb_(pix)=1000 distance_maximum_bb_(unit)=1000");
		resultsName = orig + "_Object_" + objLabels[i] + "_SpotSize_" + s +  "_CenterCenterPixelUnit.csv";
		saveAs("Results", plotDir + File.separator() + resultsName);
		close(resultsName);
		run("Clear Results");
		run("3D Intensity Measure", "objects=" + filteredSpots + " signal=" + actin);
		resultsName = orig + "_Object_" + objLabels[i] + "_SpotSize_" + s +  "_Intensities.csv";
		saveAs("Results", intensDir + File.separator() + resultsName);
		close(resultsName);
		selectWindow(filteredSpots);
		saveAs("TIFF", segDir + File.separator() + orig + "_spots_" + objLabels[i] + "_SpotSize_" + s + ".tiff");
		close(filteredSpots);
		close("Results");
}
