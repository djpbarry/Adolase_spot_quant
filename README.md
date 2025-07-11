# Overview
This repository contains a series of ImageJ/FIJI macros for the automation of **segmentation and analysis of cellular objects and intracellular spots within 3D microscopy images**. The main macro,  `spatial_analysis.ijm`, takes two input images: a **probability map** (produced with [ilastik](https://www.ilastik.org/) using `MyProject_pix_pred.ilp`) and a **raw intensity image**.
# Segmentation and Analysis of Cells and Spots
This ImageJ/FIJI macro processes 3D microscopy image data to segment cellular structures and detect and quantify intracellular spots within them. The workflow involves two main parallel processing streams: one for initial cell segmentation from a probability map, and another for spot detection from the raw intensity image, followed by a detailed analysis of spots within each segmented cell.
## 1. Cellular Object Segmentation
The macro first opens a 3D probability map (output from Ilastik). This probability map, a two-channel image, is split, and the relevant channel representing the cellular probability is selected. A **3D Gaussian blur** is applied for smoothing.
A **threshold** is then applied (fixed at 10000-65535, corresponding to high probability values), and the image is converted to a binary mask. **Holes within these binary masks are filled** to ensure solid objects.
**3D connected component labeling** is performed to identify and label individual cellular objects. The **volume of each labeled object is measured** and saved to a CSV file. Objects below a specified volume threshold (1,000,000 cubic pixels) are filtered out to remove noise or small, irrelevant structures.
## 2. Intracellular Spot Detection
Concurrently, the raw intensity image is opened and its channels are split. The channel containing the signal of interest for spot detection is identified.
A **Difference of Gaussians (DoG) filter** is applied to this image to enhance punctate structures (spots). This is achieved by subtracting a larger 3D Gaussian-blurred image from a smaller 3D Gaussian-blurred image. The resulting DoG image is then **auto-thresholded using Li's method** and converted into a binary mask representing the detected spots.
## 3. Integrated Spot Analysis per Cell
For each identified cellular object from the initial segmentation, the macro performs a detailed analysis of the detected spots:
* A **binary mask for the current cellular object** is generated and saved as a TIFF file.
* **Spots are masked by the individual cell object**: An "AND" operation is performed between the global spot mask and the current cellular object mask to identify only the spots located within that specific cell.
* **3D connected component labeling** is applied to these cell-specific spots.
* **3D distances** from each detected spot to the cell boundary are calculated and saved.
* **3D intensity measurements** are performed on the detected spots within the cell, using the original actin channel for intensity quantification, and these results are also saved.
* The **spot mask for each cell and for each spot size** is saved as a TIFF image.
* The spots are iteratively **dilated** and the distance and intensity analysis is repeated for each dilated spot size, allowing for assessment of spot properties at varying degrees of aggregation or size.
All results, including object volumes, spot distances, and spot intensities, are saved as CSV files, and segmented masks are saved as TIFF images in designated output directories. These results are then subsequently analysed with additional custom scripts.
