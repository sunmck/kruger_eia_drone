# Analyzing Changes of Vegetation in Kruger Nationalpark due to the Impact of the African Elephant

## Introduction
Welcome to the Kruger Git of the Internship at Kruger National Park's Scientific Services. Here, we present a collection of multiple approaches 
using different remote sensing products to analyse changes of the savanna vegetation in the national park due to the impact of the African Elephant (Loxodonta africana).
We proccessed and analysed drone data collected in August 2023 in specific small Elephant Impact Areas (EIAs) in the southern park around the Sabie river. Additionally,
we analyse a time series of MODIS vegetation indice products and of various land cover classifications. The aim is to find out whether we can confirm changes in vegetation, that 
have been recorded by game rangers in the field, with remote sensing data.

## Background
The impact of the African Elephant as an "environmental engineer" is a highly discussed topic in the Kruger National Park amongst many other. Whist elephants act to 
curb woody thickening and therefore structuring the physical environment with positive consequences for other fauna, they are feared to potentially decrease biodiversity
by debarking and knocking down specific tree species such as the Marula (Sclerocarya birrea) and Knobthorn (Acacia nigrescens) trees. Areas of high elephant impact are therefore
assumed to have a stronger trend towards an opening of savanna vegetation and a declie of large trees in comparison to areas of lower elephant impact.

## Data Set

## Methods
### Analysis of Small EIAs from Multispectral Drone Imagery
Processing of the multispectral drone data was conducted using the software Pix4D. 
As a basic analysis, vegetation indices are calculated to compare the structure of different EIAs among each other. Using the `lidR` package in R, individual trees are then detected and segmented. Tree tops are detected by applying a Local Maximum Filter (LMF) on the loaded data set. For a given point, the algorithm analyzes neighborhood points, checking if the processed point is the highest. The size of the moving window determines the size of the analysed neighborhood.

## Results
### Paramteres of Small EIAs from Multispectral Drone Imagery
The resulted Digital Surface Model (DSM) and Digital Terrain Model (DTM) of the processed drone data are shown in Figure 1, aswell as the Canopy Height Model (CHM) caluclated as the difference between the two. In Figure 2, the detected tree tops and the crown area are shown. In savanna vegetation, any standing vegetation with minimum height of 1.5 m can be considered a tree. 

![EIA2_Exp1_DEMs](https://github.com/sunmck/kruger_eia/assets/116874799/413b6a87-8d49-4519-b138-e286342616fd)

***Figure 1:** DSM, DTM and CHM of EIA2 Exp1.* 

![EIA2_Exp1_ttops](https://github.com/sunmck/kruger_eia/assets/116874799/5aae9fdd-7941-4abe-bf0c-0a0f23826275)

***Figure 2:** Tree tops and crown area of EIA2 Exp1.* 

An overview of the most important parameters of all currently processed and analysed small EIAs can be found in Table 1.

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

The selection of a suitable method depends on the applied context. If only wanting to classify the inside of the small EIAs, a classification based on the CHM is most accurate. In this case, we classified 0 - 0.5 m as bare Soil / Grassland, 0.5 - 1.5 as shrubs, 1.5 - 5 m as small trees and everything else as big trees. However, when wanting to train a model to classify bigger areas, these classes are too small and segmentated.

Therefore, we sampled some vegetation sites and used these for training a classification model. Results are promising with an overall accuracy of 0.77. All results are shown in Figure 3.

| ![EIA2Exp1_classification_chm_1](https://github.com/sunmck/kruger_eia/assets/116874799/3179b357-646c-448c-8a92-2427fa8e46b2) | ![EIA2Exp1_classification_trainingdata_1](https://github.com/sunmck/kruger_eia/assets/116874799/9abc0103-5e63-4a96-8fe3-9077b164ddd0) | ![EIA2Exp1_classification_rf_1](https://github.com/sunmck/kruger_eia/assets/116874799/b4c8b4f9-660b-468c-8b96-aaf0eb43f12f) |
| -- | -- | -- |
| **(a)** Classification based on CHM | **(b)** Training data for RF classification | **(c)** Classifcation of RF model |

***Figure 3:** Vegetation Classification of EIA2 Exp1.* 


## Outlook
This project should be taken as a basis for a possible change detection analysis as future work. If the same drone flights can be conducted at a similiar time within the next years, very interesting changes in the vegetation could be discovered. This could include changes in the number of trees and especially of big trees as well as changes in the area of grassland or shrubs.


