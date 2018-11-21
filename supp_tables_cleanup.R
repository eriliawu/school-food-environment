# prepare margins and CIs estimates for supp figures
# clean .csv files

setwd("C:/Users/wue04/Box Sync/school-food-env/school-food-environment/data")

### gender ----
gender <- read.csv("supp_table_gender.csv", stringsAsFactors=FALSE, header=FALSE)
head(gender)
gender <- gender[-c(1:3, 92:94), ]

# move CIs to separate cols
dim(gender)
gender$ci_male <- NULL
gender$ci_female <- NULL

ci_row <- seq(from=2, to=88, by=2)
for (i in ci_row) {
      gender[i-1, 4] <- gender[i, 2]
      gender[i-1, 5] <- gender[i, 3]
}
gender <- gender[-ci_row, ]
colnames(gender)[1:3] <- c("group", "margin_male", "margin_female")
rm(ci_row, i)

# clean up signs
clean_signs <- function(x) {
      x <- gsub(patter="\\*", replacement="", x)
      x <- gsub(patter="=", replacement="", x) #b/c both backslash and * are special symbols, need backslash to escape
      x <- gsub(patter="\\[", replacement="", x)
      x <- gsub(patter="\\]", replacement="", x)
}
gender[, 2:5] <- apply(gender[, 2:5], 2, clean_signs)

ci_male <- strsplit(gender$ci_male, ",")
ci_male <- data.frame(matrix(unlist(ci_male), nrow=44, byrow=TRUE))
ci_female <- strsplit(gender$ci_female, ",")
ci_female <- data.frame(matrix(unlist(ci_female), nrow=44, byrow=TRUE))
gender <- cbind(gender, ci_male, ci_female)
colnames(gender)[6:9] <- c("ci_male_lower", "ci_male_upper",
                           "ci_female_lower", "ci_female_upper")
gender <- gender[, -c(4:5)]

# create variables
# indicate food outlet and distance
gender$outlet <- NULL
gender$dist <- NULL















