#### Text Prediction - Model and Data Description
##### *Author: [Josh Morel](https://github.com/joshmorel)*

This app was created as the Capstone Project in the [Data Science
Specialization](https://www.coursera.org/learn/data-science-project) on
Coursera. The topic is Natural Language Processing (NLP), specifically text
prediction.

##### *Usage:*

Type in the text box an English sentence or phrase. The next best words are
predicted predicted and displayed below, with the best option at left. Click any
button to append the word to the active textbox.

##### *Model:*

Using English blogs, twitter and news text from the [HC
Corpora](http://www.corpora.heliohost.org/), a 4-gram stupid backoff model was
created with Python scripts. This type of model is suited for utilizing large volumes
of text data for various NLP tasks and is described in ["Large Language Models in
Machine Translation"](http://www.aclweb.org/anthology/D07-1090.pdf). The model
is loaded into R quickly using the [data.table](https://cran.r-project.org/web/packages/data.table/index.html) package. Text tokenization and
prediction is done using the [stringi](https://cran.r-project.org/web/packages/stringi/index.html) package and my custom textpred package.

For more information on the Python scripts and textpred package, please visit https://github.com/joshmorel/text_prediction

##### Other Thanks:
* Python testing: [py.test](http://doc.pytest.org/en/latest/)
* R testing with: [testthat](https://cran.r-project.org/web/packages/testthat/index.html).
* Python IDE: [PyCharm](https://www.jetbrains.com/pycharm)
* R IDE: [RStudio](https://www.rstudio.com/)
* All the great contributors to Python, R, Linux, git
* Numerous NLP researchers and developers
