###############################################################
### Classification of Drone Data of Small Elephant Impact Sites
###############################################################

### Internship KNP, Author: Sunniva McKeever, Isabella Metz, Maximilan Merzdorf

# libraries
library(terra)
library(ggplot2)
library(mapview)
library(sf)
library(caret)
library(randomForest)


## HYPERPARAMETERS
classnames_string <- c("BareSoilSand", "OpenGrassland", "SmallShrubs", "TreesShrubs", "Trees")
EIA_name <- "EIA2 Exp1"

## DATA
setwd("C://Users/avinn/Documents/Master/Semester3/ElephantTransects/")

# load training and drone data
training <- sf::st_read("./data/classification/training_vegetation/training_EIA2C3.shp")
# EIA2Exp1
Ortho <- terra::rast(c(
  "./ElephantTransectSites/Pix4d/20230810_EIA2_Exp1/20230810_EIA2Exp1_transparent_mosaic_group1.tif",
  "./ElephantTransectSites/Pix4d/20230810_EIA2_Exp1/20230810_EIA2Exp1_transparent_mosaic_green.tif",
  "./ElephantTransectSites/Pix4d/20230810_EIA2_Exp1/20230810_EIA2Exp1_transparent_mosaic_red.tif",
  "./ElephantTransectSites/Pix4d/20230810_EIA2_Exp1/20230810_EIA2Exp1_transparent_mosaic_red edge.tif",
  "./ElephantTransectSites/Pix4d/20230810_EIA2_Exp1/20230810_EIA2Exp1_transparent_mosaic_nir.tif"),
  lyrs = c(1,2,3,5,7,9,11)
)
names(Ortho) <- c("red", "green", "blue", "MS_green", "MS_red", "MS_rededge", "MS_nir")


# load other data
aoi <- st_read("./data/other/polygons.shp")

# preprocess data
training <- sf::st_transform(training, crs(Ortho))
aoi <- sf::st_transform(aoi, crs(Ortho))
Ortho <- terra::mask(Ortho, aoi[aoi$FieldID == EIA_name,])


## Classification
# randomly select certain amount of points in each training polygons class and save labels to them
# number of points sampled per class
points_nb = 200 # also tested with: 100, 1000, 500

points <- list()

for(i in unique(training$class_id)){
  message(paste0("Sampling points from polygons with type = ", i))
  points[[i]] <- st_sample(
    x = training[training$class_id == i,],
    size = points_nb # amount of points saved per class
  )
  points[[i]] <- st_as_sf(points[[i]])
  points[[i]]$resp_var <- i
}
# convert to df
points <- do.call(rbind, points) 

# extract features from drone orthomosaic for the lables points
points_feat <- terra::extract(Ortho, points, df = T)
points_feat <- points_feat[,-1] # no ID column needed
points_feat <- cbind(resp_var = points$resp_var, points_feat)

# remove NA values and duplicates
points_feat <- na.omit(points_feat)
dupl <- duplicated(points_feat)
points_feat <- points_feat[!dupl,]

# split into train (80%) and test data (20%)
set.seed(123)  # for reproducibility
index <- sample(1:nrow(points_feat), round(nrow(points_feat) * 0.8))
train_data <- points_feat[index,]
test_data  <- points_feat[-index,]

# define input to model
x <- train_data[,2:ncol(train_data)] # remove ID column
y <- as.factor(train_data[,1]) # we want caret to treat this as categories, thus factor
x_test <- test_data[,2:ncol(test_data)]
y_test <- as.factor(test_data[,1])

# rename levels, doesn't work with class numbers
levels(y) <- classnames_string
levels(y_test) <- levels(y)


# train the model using random forest
set.seed(825)
model_rf <- train(
  x = x,
  y = y,
  trControl = trainControl(
    p = 0.75, # percentage of samples used for training, rest for validation
    method  = "cv", # cross validation
    number  = 5, # 5-fold
    verboseIter = F, # progress update per iteration
    classProbs = F # probabilities for each example
  ),
  method = "rf" # random forest
)

# model performance
# check performance of the model with train_data
model_rf
#saveRDS(model_rf, "./models/model_EIA2Exp1_Ortho.rds")
confusionMatrix(model_rf)
# final check performance with test_data that was not used when training the model
confusionMatrix(reference = y_test,
                data = predict(model_rf, x_test))

# apply model
classification <- terra::predict(Ortho, model_rf, type='raw', na.rm = T)

# plot
plot(classification, col = c("sandybrown", "lightyellow" ,"lightgreen", "green", "darkgreen"))
writeRaster(classification, "classification_EIA2C3.tif")
