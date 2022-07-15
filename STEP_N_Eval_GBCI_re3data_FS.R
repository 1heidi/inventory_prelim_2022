## Purpose: Cross check FAIRsharing and re3data with Predicted Resource Names
## Parts: 1) find matches via names 2) plot Venn diagram
## Package(s): tidyverse
## Input file(s): eval_predictions_all_2022-07-01.csv, 
## Output file(s):

library(tidyverse)

##=======================================================##
########## PART 1: Find matches via names  ########## 
##=======================================================##

## move files that have to be kept private - there must be a better way to do this
pred <- read.csv("eval_predictions_all_2022-07-01.csv")
pred <- select(pred, 1, 23, 37)
re3 <- read.csv("re3_temp_life_sci_repos_2021-08-06.csv")
re3 <- select(re3, 1, 5, 4)
fs <- read.csv("fs_temp_dbs_all_2022-06-09.csv")
fs <- select(fs, 1:3)

compare_pred_re3 <- full_join(pred, re3, by = c("best_name_overall" = "repositoryName"))
compare_pred_re3_fs <- full_join(compare_pred_re3, fs, by = c("best_name_overall" = "name"))

write.csv(compare_pred_re3_fs,"compare_pred_re3_fs_2022-07-14.csv", row.names = FALSE)

##===========================================##
######### PART 2: Plot Venn Diagram  ########## 
##===========================================##

library(VennDiagram)

# generate lists
GBC_Inventory <- unique(pred$best_name_overall)
FAIRSharing_All <- unique(fs$name)
re3data_Life_Sci <- unique(re3$repositoryName)

library(RColorBrewer)
myCol <- brewer.pal(3, "Pastel2")

venn.diagram(
  x = list(GBC_Inventory, FAIRSharing_All, re3data_Life_Sci),
  category.names = c("GBC_Inventory", "FAIRSharing_All", "re3data_Life_Sci"),
  filename = 'test_venn_diagramm.png',
  output=TRUE,
  
  # Output features
  imagetype="png" ,
  height = 480 , 
  width = 480 , 
  resolution = 300,
  compression = "lzw",
  
  # Circles
  lwd = 2,
  lty = 'blank',
  fill = myCol,
  
  # Numbers
  cex = .6,
  fontface = "bold",
  fontfamily = "sans",
  
  # Set names
  cat.cex = 0.35,
  cat.fontface = "bold",
  cat.default.pos = "outer",
  cat.pos = c(-27, 27, 135),
  cat.dist = c(0.055, 0.055, 0.085),
  cat.fontfamily = "sans",
  rotation = 1
)
