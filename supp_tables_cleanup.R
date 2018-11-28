# prepare margins and CIs estimates for supp figures
# clean .csv files

setwd("C:/Users/wue04/Box Sync/school-food-env/school-food-environment/data")

### gender ----
gender <- read.csv("supp_table_gender.csv", stringsAsFactors=FALSE, header=FALSE)
head(gender)
gender <- gender[-c(1:3, 92:94), ]

# move CIs to separate cols
dim(gender)

ci_row <- seq(from=2, to=88, by=2)
for (i in ci_row) {
      gender[i-1, 4] <- gender[i, 2]
      gender[i-1, 5] <- gender[i, 3]
}
gender <- gender[-ci_row, ]
colnames(gender)[1:5] <- c("group", "male", "female", "ci_male", "ci_female")
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
temp <- strsplit(gender$group, "#")
temp <- data.frame(matrix(unlist(temp), nrow=44, byrow=TRUE))
gender$outlet <- substring(temp$X2, 1, 1)
gender$dist <- substring(temp$X1, 2, 3)
gender$dist <- gsub(patter="\\.", replacement = "", gender$dist)
rm(temp)
gender$group <- NULL

apply(gender, 2, class)
gender$dist <- as.numeric(gender$dist)
gender$dist <- (gender$dist-1)*264
gender$outlet[gender$outlet==1] <- "FF"
gender$outlet[gender$outlet==2] <- "BOD"
gender$outlet[gender$outlet==3] <- "WS"
gender$outlet[gender$outlet==4] <- "SUP"

# prepare for export
gender <- gender[, c(7:8, 1, 3:4, 2, 5:6)]
names(gender)
write.csv(gender, "figure_estimates_gender.csv", row.names = FALSE)
rm(ci_female, ci_male)

### by-race analysis ----
race <- read.csv("supp_table_race.csv", stringsAsFactors=FALSE, header=FALSE)
head(race)
race <- race[-c(1:3, 92:94), ]

# move CIs to separate cols
dim(race)
ci_row <- seq(from=2, to=88, by=2)
col <- c(2:5)
for (i in ci_row) {
      for (j in col) {
            race[i-1, j+4] <- race[i, j]
      }
}
race <- race[-ci_row, ]
colnames(race)[1:9] <- c("group", "asain", "hisp", "black", "white", "ci_asian",
                         "ci_hisp", "ci_black", "ci_white")
rm(ci_row, i, j, col)

# clean up signs
race[, 2:9] <- apply(race[, 2:9], 2, clean_signs)

split_clean <- function(x, str, row) {
      object <- strsplit(x, split=str)
      object <- unlist(object)
      object <- matrix(object, nrow=row, byrow=TRUE)
      object <- data.frame(object)
      return(object)
}
ci_asian <- split_clean(x=race$ci_asian, str=",", row=dim(race)[1])
ci_hisp <- split_clean(x=race$ci_hisp, str=",", row=dim(race)[1])
ci_black <- split_clean(x=race$ci_black, str=",", row=dim(race)[1])
ci_white <- split_clean(x=race$ci_white, str=",", row=dim(race)[1])
race <- cbind(race, ci_asian, ci_hisp, ci_black, ci_white)
colnames(race)[10:17] <- c("ci_asian_lower", "ci_asian_upper", "ci_hisp_lower",
                           "ci_hisp_upper", "ci_black_lower", "ci_black_upper",
                           "ci_white_lower", "ci_white_upper")
race <- race[, -c(6:9)]
rm(ci_asian, ci_hisp, ci_black, ci_white)

# create variables
# indicate food outlet and distance
temp <- split_clean(x=race$group, str="#", row=dim(race)[1])
race$outlet <- substring(temp$X2, 1, 1)
race$dist <- substring(temp$X1, 2, 3)
race$dist <- gsub(patter="\\.", replacement = "", race$dist)
rm(temp)
race$group <- NULL

apply(race, 2, class)
race$dist <- as.numeric(race$dist)
race$dist <- (race$dist-1)*264
race$outlet[race$outlet==1] <- "FF"
race$outlet[race$outlet==2] <- "BOD"
race$outlet[race$outlet==3] <- "WS"
race$outlet[race$outlet==4] <- "SUP"

# prepare for export
race <- race[, c(13:14, 1, 5:6, 2, 7:8, 3, 9:10, 4, 11:12)]
names(race)
write.csv(race, "figure_estimates_race.csv", row.names = FALSE)

### by_boro ----
boro <- read.csv("supp_table_boro.csv", stringsAsFactors=FALSE, header=FALSE)
head(boro)
boro <- boro[-c(1:3, 92:94), ]

# move CIs to separate cols
dim(boro)
ci_row <- seq(from=2, to=88, by=2)
col <- c(2:5)
for (i in ci_row) {
      for (j in col) {
            boro[i-1, j+4] <- boro[i, j]
      }
}
boro <- boro[-ci_row, ]
colnames(boro)[1:9] <- c("group", "asain", "hisp", "black", "white", "ci_asian",
                         "ci_hisp", "ci_black", "ci_white")
rm(ci_row, i, j, col)

# clean up signs
boro[, 2:9] <- apply(boro[, 2:9], 2, clean_signs)

split_clean <- function(x, str, row) {
      object <- strsplit(x, split=str)
      object <- unlist(object)
      object <- matrix(object, nrow=row, byrow=TRUE)
      object <- data.frame(object)
      return(object)
}
ci_asian <- split_clean(x=boro$ci_asian, str=",", row=dim(boro)[1])
ci_hisp <- split_clean(x=boro$ci_hisp, str=",", row=dim(boro)[1])
ci_black <- split_clean(x=boro$ci_black, str=",", row=dim(boro)[1])
ci_white <- split_clean(x=boro$ci_white, str=",", row=dim(boro)[1])
boro <- cbind(boro, ci_asian, ci_hisp, ci_black, ci_white)
colnames(boro)[10:17] <- c("ci_asian_lower", "ci_asian_upper", "ci_hisp_lower",
                           "ci_hisp_upper", "ci_black_lower", "ci_black_upper",
                           "ci_white_lower", "ci_white_upper")
boro <- boro[, -c(6:9)]
rm(ci_asian, ci_hisp, ci_black, ci_white)

# create variables
# indicate food outlet and distance
temp <- split_clean(x=boro$group, str="#", row=dim(boro)[1])
boro$outlet <- substring(temp$X2, 1, 1)
boro$dist <- substring(temp$X1, 2, 3)
boro$dist <- gsub(patter="\\.", replacement = "", boro$dist)
rm(temp)
boro$group <- NULL

apply(boro, 2, class)
boro$dist <- as.numeric(boro$dist)
boro$dist <- (boro$dist-1)*264
boro$outlet[boro$outlet==1] <- "FF"
boro$outlet[boro$outlet==2] <- "BOD"
boro$outlet[boro$outlet==3] <- "WS"
boro$outlet[boro$outlet==4] <- "SUP"

# prepare for export
boro <- boro[, c(13:14, 1, 5:6, 2, 7:8, 3, 9:10, 4, 11:12)]
names(boro)
write.csv(boro, "figure_estimates_boro.csv", row.names = FALSE)




