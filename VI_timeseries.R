#########################################################
### MODIS VI Time Series of Big Elephant Impact Sites
#########################################################

### Internship KNP, Author: Sunniva McKeever, Isabella Metz, Maximilan Merzdorf

# TODO: set wd to downloaded MODIS timeseries data
setwd("")

# libraries
library(terra)
library(ggplot2)
library(mapview)
library(sf)
library(data.table)
library(lubridate)
library(ggthemes)
library(ggspatial)
library(gridExtra)

## hyperparameters
crs_epsg <- "epsg:32736"
dates_VI <- seq(ymd("2000-1-1"), ymd("2022-5-1"), by = "months")
dates_LAI <- seq(ymd("2003-1-1"), ymd("2022-9-1"), by = "months")

# import MODIS rasters
EVI_files <- list.files(path = paste0(getwd(), "/data/MODIS/EVI/"), pattern='.tif$', all.files=TRUE, full.names=FALSE)
EVI_stack <- terra::rast(paste0(getwd(), "/data/MODIS/EVI/", EVI_files))
EVI_stack <- terra::app(EVI_stack, fun=function(x) x * 0.0001) # correct for scale factor of MODIS data
EVI_stack <- terra::project(EVI_stack, crs_epsg)

NDVI_files <- list.files(path = paste0(getwd(), "/data/MODIS/NDVI/"), pattern='.tif$', all.files=TRUE, full.names=FALSE)
NDVI_stack <- terra::rast(paste0(getwd(), "/data/MODIS/NDVI/", NDVI_files))
NDVI_stack <- terra::app(NDVI_stack, fun=function(x) x * 0.0001) # correct for scale factor of MODIS data
NDVI_stack <- terra::project(NDVI_stack, crs_epsg)

LAI_files <- list.files(path = paste0(getwd(), "/data/MODIS/LAI_update/"), pattern='.tif$', all.files=TRUE, full.names=FALSE)
LAI_stack <- terra::rast(paste0(getwd(), "/data/MODIS/LAI_update/", LAI_files))
LAI_stack[LAI_stack>100] <- NA
LAI_stack <- terra::app(LAI_stack, fun=function(x) x * 0.1) # correct for scale factor of MODIS data
LAI_stack <- terra::project(LAI_stack, crs_epsg)


# import aois
aoi_Kruger <- st_read("./data/EIA/WDPA_WDOECM_Sep2023_Public_873_shp-polygons.shp")
aoi_EIA <- st_read("./data/EIA/elephant_impact_sites_veg_merged.shp")
aoi_nonEIA <- st_read("./data/EIA/non_elephant_impact_sites_veg.shp")

aoi_Kruger <- st_transform(aoi_Kruger, crs_epsg)
aoi_EIA <- st_transform(aoi_EIA, crs_epsg)
aoi_nonEIA <- st_transform(aoi_nonEIA, crs_epsg)

# check
plot(EVI_stack[[2]])
plot(aoi_Kruger, add = T, col = "white")

# calculate mean EVI
EVI_Kruger <- extract(EVI_stack, aoi_Kruger, fun=mean)
EVI_EIA <- extract(EVI_stack, aoi_EIA, fun=mean)
EVI_nonEIA <- extract(EVI_stack, aoi_nonEIA, fun=mean)

EVI_Kruger_mean <- terra::mean(EVI_stack, na.rm = T)
EVI_Kruger_mean <- terra::mask(EVI_Kruger_mean, aoi_Kruger)

# calculate mean NDVI
NDVI_Kruger <- extract(NDVI_stack, aoi_Kruger, fun=mean)
NDVI_EIA <- extract(NDVI_stack, aoi_EIA, fun=mean)
NDVI_nonEIA <- extract(NDVI_stack, aoi_nonEIA, fun=mean)

NDVI_Kruger_mean <- terra::mean(NDVI_stack, na.rm = T)
NDVI_Kruger_mean <- terra::mask(NDVI_Kruger_mean, aoi_Kruger)

# calculate mean LAI
LAI_Kruger <- extract(LAI_stack, aoi_Kruger, fun=mean, na.rm = T)
LAI_EIA <- extract(LAI_stack, aoi_EIA, fun=mean, na.rm = T)
LAI_nonEIA <- extract(LAI_stack, aoi_nonEIA, fun=mean, na.rm = T)

LAI_Kruger_mean <- terra::mean(LAI_stack, na.rm = T)
LAI_Kruger_mean <- terra::mask(LAI_Kruger_mean, aoi_Kruger)

# edit EVI df
colnames(EVI_Kruger) <- seq.int(1:nlyr(EVI_stack))
EVI_Kruger <- transpose(EVI_Kruger)
EVI_Kruger$date <- dates
EVI_Kruger <- EVI_Kruger[-1,]
colnames(EVI_Kruger) <- c("evi", "date")
EVI_Kruger$type <- "KNP"

colnames(EVI_EIA) <- seq.int(1:nlyr(EVI_stack))
EVI_EIA <- transpose(EVI_EIA)
EVI_EIA$date <- dates
EVI_EIA <- EVI_EIA[-1,]
colnames(EVI_EIA) <- c("evi", "date")
EVI_EIA$type <- "EIA"

colnames(EVI_nonEIA) <- seq.int(1:nlyr(EVI_stack))
EVI_nonEIA <- transpose(EVI_nonEIA)
EVI_nonEIA$date <- dates
EVI_nonEIA <- EVI_nonEIA[-1,]
colnames(EVI_nonEIA) <- c("evi", "date")
EVI_nonEIA$type <- "non EIA"

# edit NDVI df
colnames(NDVI_Kruger) <- seq.int(1:nlyr(NDVI_stack))
NDVI_Kruger <- transpose(NDVI_Kruger)
NDVI_Kruger$date <- dates
NDVI_Kruger <- NDVI_Kruger[-1,]
colnames(NDVI_Kruger) <- c("ndvi", "date")
NDVI_Kruger$type <- "KNP"

colnames(NDVI_EIA) <- seq.int(1:nlyr(NDVI_stack))
NDVI_EIA <- transpose(NDVI_EIA)
NDVI_EIA$date <- dates
NDVI_EIA <- NDVI_EIA[-1,]
colnames(NDVI_EIA) <- c("ndvi", "date")
NDVI_EIA$type <- "EIA"

colnames(NDVI_nonEIA) <- seq.int(1:nlyr(NDVI_stack))
NDVI_nonEIA <- transpose(NDVI_nonEIA)
NDVI_nonEIA$date <- dates
NDVI_nonEIA <- NDVI_nonEIA[-1,]
colnames(NDVI_nonEIA) <- c("ndvi", "date")
NDVI_nonEIA$type <- "non EIA"

# edit LAI df
colnames(LAI_Kruger) <- seq.int(1:nlyr(LAI_stack))
LAI_Kruger <- transpose(LAI_Kruger)
LAI_Kruger$date <- dates_LAI
LAI_Kruger <- LAI_Kruger[-1,]
colnames(LAI_Kruger) <- c("lai", "date")
LAI_Kruger$type <- "KNP"

colnames(LAI_EIA) <- seq.int(1:nlyr(LAI_stack))
LAI_EIA <- transpose(LAI_EIA)
LAI_EIA$date <- dates_LAI
LAI_EIA <- LAI_EIA[-1,]
colnames(LAI_EIA) <- c("lai", "date")
LAI_EIA$type <- "EIA"

colnames(LAI_nonEIA) <- seq.int(1:nlyr(LAI_stack))
LAI_nonEIA <- transpose(LAI_nonEIA)
LAI_nonEIA$date <- dates_LAI
LAI_nonEIA <- LAI_nonEIA[-1,]
colnames(LAI_nonEIA) <- c("lai", "date")
LAI_nonEIA$type <- "non EIA"

# plot time series separately
ggplot(EVI_Kruger, aes(x=date,y=evi)) +
  geom_line()

ggplot(EVI_EIA, aes(x=date, y=evi)) +
  geom_line()

ggplot(EVI_nonEIA, aes(x=date, y=evi)) +
  geom_line()

# plot time series together
EVI_all <- rbind(EVI_EIA, EVI_nonEIA)
NDVI_all <- rbind(NDVI_EIA, NDVI_nonEIA)
LAI_all <- rbind(LAI_EIA, LAI_nonEIA)

ggplot(EVI_all, aes(x=date, y=evi, color=type, group=type)) + 
  geom_line() +
  geom_smooth() +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Time Series of EVI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean EVI") +
  theme_bw()

ggplot(EVI_all, aes(x=date, y=evi, color=type, group=type)) +            
  geom_point() +                                      
  stat_smooth(method = "lm", 
              formula = y ~ x) +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Trend of EVI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean EVI") +
  theme_bw()

ggplot(NDVI_all, aes(x=date, y=ndvi, color=type, group=type)) + 
  geom_line() +
  geom_smooth() +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Time Series of NDVI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean NDVI") +
  theme_bw()

ggplot(NDVI_all, aes(x=date, y=ndvi, color=type, group=type)) +            
  geom_point() +                                      
  stat_smooth(method = "lm", 
              formula = y ~ x) +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Trend of NDVI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean NDVI") +
  theme_bw()

ggplot(LAI_all, aes(x=date, y=lai, color=type, group=type)) + 
  geom_line() +
  geom_smooth() +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Time Series of LAI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean LAI") +
  theme_bw()

ggplot(LAI_all, aes(x=date, y=lai, color=type, group=type)) +            
  geom_point() +                                      
  stat_smooth(method = "lm", 
              formula = y ~ x) +
  scale_color_manual(values=c("cornflowerblue", "coral"), guide_colorbar(title = "")) + 
  ggtitle("MODIS Trend of LAI from 2000-2022\nKruger National Park") +
  xlab("") + 
  ylab("mean LAI") +
  theme_bw()

# calculate differences in VI
EVI_diff <- EVI_stack[[263]] - EVI_stack[[1]]
EVI_diff <- terra::mask(EVI_diff, aoi_Kruger)
#EVI_diff_EIA <- terra::mask(EVI_diff, aoi_EIA)
#EVI_diff_nonEIA <- terra::mask(EVI_diff, aoi_nonEIA)

NDVI_diff <- NDVI_stack[[263]] - NDVI_stack[[1]]
NDVI_diff <- terra::mask(NDVI_diff, aoi_Kruger)

LAI_diff <- LAI_stack[[236]] - LAI_stack[[1]]
LAI_diff <- terra::mask(LAI_diff, aoi_Kruger) 

# save plots
png(file="evi_timeseries.png",res=600)
dev.off()

writeRaster(LAI_Kruger_mean, "./figs/MODIS/LAI_Kruger_mean_v2.tif", overwrite=TRUE)
