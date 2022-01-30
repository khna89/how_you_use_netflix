# How you use netflix: interactive data visualization with R
Visualization of the user's Netflix data with shiny app (R) and flexdashboard (R). Both programs create a user interface for R data vizualization objects. Flexdashboard is static, and one has to provide the path to the data in the code. Shiny app is interactive. One could upload their data into it and also control the number of movies included in their personal top. The app is also available [online](https://nin-khodorivsko.shinyapps.io/my_netflix_project/). Both shiny app and flexdashboard visualize top movies and tv-shows one watched on Netflix with the amount of time in hours, for how long one watched something when they did so, how many hours one watched per year. The app also builds a simple linear regression model that predicts the trend of the time spent on every video, and prints the output of the function that checks if the assumptions of the model are satisfied.
### Access the app online
If you don't code and you want to directly use the data visualization app - go [here](https://nin-khodorivsko.shinyapps.io/my_netflix_project/). You will need to upload a file that you can get from Netflix. Netflix instructs how to do that [here](https://www.netflix.com/account/getmyinfo). After you've download the data - unzip the folder. You will find the necessary file in netflix-report/CONTENT_INTERACTION.
Concerning your data: I don't have access to it through the shiny app, but I can't truly explain what happens to it when you upload it to R servers. If you don't want to upload your data like that you could download this repository instead, install R on your computer - it's free - and run my_netflix_project/app.R. It will ask you to provide the same file, but this time it won't upload it anywhere on the Internet, the file stays on your computer. 
Alternatively, you could preprocess your ViewingActivity.csv with the code below. This way the data will not contain any information that would personally identify you, it will only contain the names of the tv shows you watched, for how long and when you watched it (without specifying who this "you" is). 
#### To anonymize your data run this:
`PATH <- #PROVIDE THE PATH TO YOUR DATA HERE

NEW_PATH <- #PROVIDE THE DIRECTORY WHERE YOU WANT TO STORE THE FILTERED DATA

data <- read.csv(PATH)

new_data <- data[ , c("Start.Time","Duration","Title")]

write.csv(new_data, NEW_PATH, row.names = FALSE)`
### What does the code do
Processing of the data is the same in both app and dashboard. The data of the start.time variable is transformed into date objects. The data of the duration variable - into time objects. A new variable dur_in_min is created to incorporate hours, minutes and seconds into one value. A general_title variable contains filtered cleaned titles, so that, for example, "The Big Bang Theory: Season 1 Episode...." and "The Big Bang Theory: Season 5 Episode..." can be considered as instances of the same show, "The Big Bang Theory". A separate dataframe is created that aggregates duration in minutes according to these general titles. Another aggregated dataframe contains duration of viewing per year. A linear regression model is fitted with start.time as predictor and duration in minutes as outcome variables. The coefficients of the model are used for plotting the regression line, the assumptions are checked with gvlma(). 
The data is visualized with basic R graphics. 
