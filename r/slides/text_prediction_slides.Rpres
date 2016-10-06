Text Prediction App
========================================================
author: Josh Morel
date: 2016-10-02
autosize: true

## Data Science Capstone Project

The Problem
========================================================

* Anyone not living under a rock can tell you <b>texting</b> has become a key means of communication
* Unfortunately, unless you're thumb-ninja digital native, communicating ideas through texts can be slow and error-prone
* Just try thumbing out a thoughtful, fully-formed sentence when you've been typing with ten fingers all your life!

The Opportunity
========================================================

* Natural Language Processing, or NLP for short, combined with modern computing can solve the slow thumb problem by lending a predictive helping hand
* Consider: you want to share some love and send a "you're my best friend" message
* You <b>COULD</b> thumb "you're my" and then... letter-by-letter... b e s t [space] f r i e n d
* But with a predictive aid, only two pushes are required to complete those words calculated as very likely to follow the partially formed intention

My Solution - Link & Diagram
========================================================

[Josh's Text Prediction App Protype on ShinyApps.io](https://josh-morel.shinyapps.io/text_prediction/)

![Diagram](text_prediction_dia.svg)

My Approach to the Solution
========================================================

1. Use English text input data from blogs, twitter and news data source from the [HC Corpora](http://www.corpora.heliohost.org/)
2. Design language model program with the "Stupid Back-off" algorithm (truly smart) as described by Brant, et al (1)
3. Develop the model building pipeline with [Python scripts chained through a Bash script](https://github.com/joshmorel/text_prediction) (FYI - the original used Hadoop/MapReduce)
4. Deploy an R Shiny App hosted on shiny.io at https://josh-morel.shinyapps.io/text_prediction/ (repeated... just in case the previous link didn't work!)

[1]: T. Brants, et al. (2007). Large language models in machine translation. [Online] Available: http://www.aclweb.org/anthology/D07-1090.pdf

Areas for Improvements
========================================================

A means to evaluate relatative performance, from both a accuracy & computing, perspective, considering:

* The model's maximum order (5-gram, 6-gram, 7-gram?)
* Percent of source data to use (I used 40% but with the Stupid Backoff approach any amount is possible)
* The vocabulary cut-off at which to map a word to the "unknown" token
* Additional or alternate data sources
* Handling of special characters and patterns, for example Twitter emojis
