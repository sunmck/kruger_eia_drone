# Analyzing Changes of Vegetation in Kruger Nationalpark due to the Impact of the African Elephant

## Introduction
Welcome to the Kruger Git of the Internship at Kruger National Park's Scientific Services. Here, we present a collection of multiple approaches 
using different remote sensing products to analyse changes of the savanna vegetation in the national park due to the impact of the African Elephant (Loxodonta africana). The aim is to see if we can confirm changes in vegetation that have been recorded by game rangers in the field in remote sensing data.

In this project, we proccessed and analysed drone data collected in August 2023 in specific small Elephant Impact Areas (EIAs) in the southern KNP around the Sabie river. This is an analysis of the first flights and thus only a momentary time stamp. We hope that the flights will be repeated in the upcoming years to use this repository as a basis for change detections and time series analysis.

## Background
The impact of the African Elephant as an "environmental engineer" is a highly discussed topic in the Kruger National Park amongst many other. Whist elephants act to 
curb woody thickening and therefore structuring the physical environment with positive consequences for other fauna, they are feared to potentially decrease biodiversity
by debarking and knocking down specific tree species such as the Marula (Sclerocarya birrea) and Knobthorn (Acacia nigrescens) trees. Areas of high elephant impact are therefore assumed to have a stronger trend towards an opening of savanna vegetation and a declie of large trees in comparison to areas of lower elephant impact.

## Data Set
Drone flights were conducted from the 6th to the 10th August 2023 on selected trianguar small EIAs. The drone was DJI's Mavic 3 Multispectral which records the following bands: Green (560 nm), Red (650 nm), Red Edge (730 nm), Near Infrared (860 nm) and an additional RGB camera. Processing of the multispectral drone data was conducted using the software Pix4D and included allignment of the photos, point cloud generation and densification as well as the calculation of a DSM, DTM and Orthomosaic.

For the supervised classification of the vegetation, samples were labelled for EIA2 Exp1, C1 and C3. These can be found in the folder `kruger_eia_drone/training`. Exeplary pictures of the different classes are shown in Figure 1.

| ![baresoil jpg](https://github.com/sunmck/kruger_eia_drone/assets/116874799/37307bd2-02d9-4759-91a3-c91af683aaf2) | ![opengrassland jpg](https://github.com/sunmck/kruger_eia_drone/assets/116874799/16648807-8889-4ed9-a2c8-8176ad0ae9ea) | ![shrubs jpg](https://github.com/sunmck/kruger_eia_drone/assets/116874799/689b3b22-d391-4eb6-9635-d78bd117db33) | ![shrubstrees jpg](https://github.com/sunmck/kruger_eia_drone/assets/116874799/df873ded-4e7b-477f-9ee7-01ca363e9e4a) | ![trees jpg](https://github.com/sunmck/kruger_eia_drone/assets/116874799/8c5d5d1e-115d-4dc3-9954-f14c1a52d151) |
| -------- | ------- |------- |------- |------- |
|  **(a)** Bare Soil / Sand | **(b)** Open Grassland | **(c)** Shrubs | **(d)** Trees and Shrubs | **(e)** Trees |

***Figure 1:** Classes of the training data for a vegetation classification.* 

## Methods and Results
### Paramteres of Small EIAs from Multispectral Drone Imagery
The DTM was substracted from the DSM to calculate a Canopy Height Model (CHM). Using the `lidR` package in R, individual trees can be detected and segmented from this data. In savanna vegetation, any standing vegetation with minimum height of 1.5 m can be considered a tree. Tree tops are detected by applying a Local Maximum Filter (LMF) on the loaded data set. For a given point, the algorithm analyzes neighborhood points, checking if the processed point is the highest. The size of the moving window determines the size of the analysed neighborhood. As a basic analysis, vegetation indices are calculated to compare the structure of different EIAs among each other. 

The results of all currently processed and analysed small EIAs are located in `kruger_eia_drone/results`. This includes the DSM, DTM, CHM, detected tree tops and canopy area. An overview of the most important parameters of is given in Table 1.

|     | EIA2 Exp1 | EIA2 C1 | EIA2 C3 |
| -------- | ------- |------- |------- |
| number of trees  | 429 | 341 | 254 |
| tree density per ha | 3900 | 3100 | 2309 |
| treeheight min. [m]    | 1.6 | 1.5 | 1.5 |
| treeheight max. [m]    | 3.26 | 1.2 | 1.04 |
| treeheight mean [m]    | 9.07 | 3.59 | 4.22 |
| canopy area [m²]    | 24754.74 | 4287.12 | 4717.36 |
| mean ndvi   | 0.99 |  0.98 | 0.98 |
| mean evi   | 2.49 | 2.49 | 2.48 |
| mean gci   | 0.1 | 0.04 | 0.06 |
| mean lai   | 8.88 | 8.9 | 8.86 |

***Table 1:** Vegetation parameters of EIA2 Exp1, C1 and C3.* 

### Classification of Small EIAs
We propose two different approaches of classifying savanna vegetation in the small EIAs:

  1. a classification based on the heights of the CHM and
  2. a supervised RF model trained with ground truth data collected in the field.

The selection of a suitable method depends on the applied context. If only wanting to classify the inside of the small EIAs, a classification based on the CHM is most accurate. In this case, we classified 0 to 0.5 m as bare soil / grassland, 0.5 to 1.5 as shrubs, 1.5 to 5 m as small trees and everything else as big trees. However, when wanting to train a model to classify bigger areas, these classes are too small and segmentated.

Therefore, we sampled some vegetation sites and used these for training a classification model. Results are promising with an overall accuracy of 0.77. All results are shown in Figure 2.

| ![EIA2Exp1_classification_chm_1](https://github.com/sunmck/kruger_eia/assets/116874799/3179b357-646c-448c-8a92-2427fa8e46b2) | ![EIA2Exp1_classification_trainingdata_1](https://github.com/sunmck/kruger_eia/assets/116874799/9abc0103-5e63-4a96-8fe3-9077b164ddd0) | ![EIA2Exp1_classification_rf_1](https://github.com/sunmck/kruger_eia/assets/116874799/b4c8b4f9-660b-468c-8b96-aaf0eb43f12f) |
| -- | -- | -- |
| **(a)** Classification based on CHM | **(b)** Training data for RF classification | **(c)** Classifcation of RF model |

***Figure 2:** Vegetation Classification of EIA2 Exp1.* 

## Outlook
This project should be taken as a basis for a possible change detection analysis as future work. If the same drone flights can be conducted at a similiar time within the next years, very interesting changes in the vegetation could be discovered. This could include changes in the number of trees and especially of big trees as well as changes in the area of grassland or shrubs.


