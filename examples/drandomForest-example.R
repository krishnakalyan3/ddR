### Start the parallel backend with 2 instances
library(ddR)
library(randomForest.ddR)
library(randomForest)
nInst = 2
useBackend("parallel",executors = nInst)




### Switch to distributedR backend
#library(distributedR.ddR)
#useBackend("distributedR", inst = nInst)




### Generate some data with:
### K = 10 clusters, ncol = 10 features, nrow ~ 1000 observations
ncol = 10
nrow = 10000
nrow = as.integer(nrow/nInst)
K = 10

### Generate centers of clusters
centers = 100*matrix(rnorm(K*ncol),nrow = K)

### Generate observations of features
generateRFData <- function(id, centers, nrow, ncol) {
	offsets = matrix(rnorm(nrow*ncol),nrow = nrow,ncol = ncol)
	cluster_ids = sample.int(nrow(centers),nrow,replace = TRUE)
	feature_obs = centers[cluster_ids,] + offsets
	features <- data.frame(cluster_ids, feature_obs)
}
features <- dmapply(generateRFData,id = 1:nInst,
                MoreArgs = list(centers = centers, nrow = nrow, ncol = ncol),
		output.type = "dframe", 
		combine = "rbind", nparts = c(nInst,1))
colnames(features) <- paste("X",1:ncol(features),sep="")




### Example of drandomForest function using formula interface on dframe data
cat("\nStarting drandomForest using formula interface on dframe:")
training <- system.time(model <- drandomForest(X1 ~ ., features,nExecutor = nInst))[3]
predicting <- system.time(predictions <- predict(model, features))[3]
cat("\n\ttraining model took: \t", training," seconds \n\tpredictions took: \t",predicting," seconds\n")




### Reformatting data to match formula interface on data.frame data
features_local <- collect(features)

### Example of drandomForest function using data.frame and formula interface
cat("\nStarting drandomForest using formula over data.frame interface:")
training <- system.time(model <- drandomForest(X1 ~ ., features_local,nExecutor = nInst))[3]
predicting <- system.time(predictions <- predict(model, features_local))[3]
cat("\n\ttraining model took: \t", training," seconds \n\tpredictions took: \t",predicting," seconds\n")




### Reformatting data to match x,y interface on darray data
cat("\nStarting drandomForest using x,y interface on darrays")
features_x = dmapply(function(x) data.matrix(x)[,-1], parts(features),
		output.type = "darray", combine = "rbind", 
		nparts = nparts(features))
features_y = dmapply(function(x) matrix(x[,1],ncol = 1), parts(features),
		output.type = "darray", combine = "rbind", 
		nparts = nparts(features))

### Example of drandomForest function using x,y interface on darrays 
training <- system.time(model <- drandomForest(x = features_x, y = features_y,nExecutor = nInst))[3]
predicting <- system.time(predictions <- predict(model, features_x))[3]
cat("\n\ttraining model took: \t", training," seconds\n\tpredictions took: \t",predicting," seconds\n")




### Reformatting data to match x,y interface on matrix data
cat("\nStarting drandomForest using x,y matrix interface")
features_x = collect(features_x)
features_y = collect(features_y)

### Example of drandomForest function using x,y interface on matrix data
training <- system.time(model <- drandomForest(x = features_x, y = features_y,nExecutor = nInst))[3]
predicting <- system.time(predictions <- predict(model, features_x))[3]
cat("\n\ttraining model took: \t", training," seconds\n\tpredictions took: \t",predicting," seconds\n")




### Comparison to randomForest function using data.frame and formula interface
cat("\nStarting randomForest using formula interface on data.frame")
training <- system.time(model <- randomForest(X1 ~ ., features_local))[3]
predicting <- system.time(predictions <- predict(model, features_local))[3]
cat("\n\ttraining model took: \t", training," seconds\n\tpredictions took: \t",predicting," seconds\n")




