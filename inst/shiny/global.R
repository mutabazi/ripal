#'
#' global.R
#' 
#' load required libraries & setup, well, global vars
#' 

library(shiny)
library(data.table)
library(stringr)
library(ggplot2)
library(ripal)

options(shiny.maxRequestSize=30*1024^2)

#' 25 worst passwords (global)  

worst.pass <- c("password", "123456", "12345678", "qwerty", "abc123", 
                "monkey", "1234567", "letmein", "trustno1", "dragon", 
                "baseball", "111111", "iloveyou", "master", "sunshine", 
                "ashley", "bailey", "passw0rd", "shadow", "123123", 
                "654321", "superman", "qazwsx", "michael", "football")

weekdays.full <- c("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
weekdays.abbrev <- c("sun", "mon", "tue", "wed", "thu", "fri", "sat")
months.full <- tolower(month.name)
months.abbrev <- tolower(month.abb)

common.colors <- c("black", "blue", "brown", "gray", "green", "orange", "pink", 
                   "purple", "red", "white", "yellow", "violet", "indigo")

seasons <- c("summer", "fall", "winter", "spring")

planets <- c("mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune", "pluto")