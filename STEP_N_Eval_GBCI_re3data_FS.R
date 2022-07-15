## Purpose: Cross check FAIRsharing and re3data with Predicted Resource Names
## Parts: 1) find matches via names 2) plot Venn diagram
## Package(s): tidyverse, VennDiagram, RColorBrewer
## Input file(s): ner_predictions_all_reshape_2022-07-01.csv, fairsharing_life_sci_2022-07-14.csv, re3data_life_sci_2022-07-15.csv
## Output file(s): NA

library(tidyverse)

##=======================================================##
########## PART 1: Find matches via names  ########## 
##=======================================================##

pred <- read.csv("ner_predictions_all_reshape_2022-07-01.csv")
pred <- select(pred, 1, 37, 23)
re3d <- read.csv("re3data_life_sci_2022-07-15.csv")
re3d <- select(re3d, 1, 5, 4)
fs <- read.csv("fairsharing_life_sci_2022-07-14.csv")
fs <- select(fs, 1:3)

compare_pred_re3d <- full_join(pred, re3d, by = c("best_name_overall" = "repositoryName"))
compare_pred_re3d_fs <- full_join(compare_pred_re3d, fs, by = c("best_name_overall" = "name"))

write.csv(compare_pred_re3d_fs,"compare_pred_re3d_fs_2022-07-15.csv", row.names = FALSE) ##add to gitignore 

##===========================================##
######### PART 2: Plot Venn Diagram  ########## 
##===========================================##

library(VennDiagram)

flog.threshold(ERROR)

# generate lists
GBC_Inventory <- unique(pred$best_name_overall)
FAIRSharing_Life_Sci <- unique(fs$name)
re3data_Life_Sci <- unique(re3d$repositoryName)

library(RColorBrewer)
myCol <- brewer.pal(3, "Pastel2")

venn.diagram(
  x = list(GBC_Inventory, FAIRSharing_Life_Sci, re3data_Life_Sci),
  category.names = c("GBC_Inventory", "FAIRSharing_Life_Sci", "re3data_Life_Sci"),
  filename = 'test_venn_diagramm.png',
  output=TRUE,
  
  # Output features
  imagetype="png" ,
  height = 1020 , 
  width = 1020 , 
  resolution = 600,
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
  cat.cex = 0.3,
  cat.fontface = "bold",
  cat.default.pos = "outer",
  cat.pos = c(-27, 27, 135),
  cat.dist = c(0.055, 0.055, 0.085),
  cat.fontfamily = "sans",
  rotation = 1
)
