#### David Chou
#### CSCI 2930 - Unix Tools
#### 4/25/2018

# Scraping Hotel Review Data from Trip Advisor

This project is attached to my project for Machine Learning, in which I will build a classifier to classify hotel reviews.  However, the hard part for classifying hotel reviews, is getting a training set of hotel reviews!  This is why I’ve decided to do this project in Unix Tools, to scrape reviews from TripAdvisor pages on the internet, to gather reviews in an efficient way.

The way that I was doing this previously was using [import.io](https://www.import.io/), a website that allows for scraping of data for machine learning purposes.  However, with the trial version I was using, it only allowed 500 queries per account, and I had to keep making new trial accounts to get all the data I needed.  To remedy this, my goal is to download the HTML for each webpage, and extract the data using Unix Tools, sanitizing the data as much as I can, so that I can input the data into my machine learning project.

### Process
First, I extracted the general place the data resides on the webpage, by finding the specific `<div>`(s) that the reviews are located in.

`cat FILENAME_HERE.html | tr -d "\r\n" | tr '[:upper:]' '[:lower:]' | egrep -o "<div class=\"listcontainer.hide-more-mobile.*<a data-page-number=\"[0-9]*\".*data-offset=\"[0-9]*\"class=\"pagenum last[^<]*</a></div></div><[^>]*><[^>]*>"`

- `tr -d "\r\n"` removes the return and newline characters in the file
- `tr '[:upper:]' '[:lower:]'` changes all uppercase characters to lowercase.  This *should* work for any UTF-8 language.
- the `egrep` call isolates the specific div where the reviews lie

So far, this isolates the specific div where each of the 5 reviews lie.  Now, I have to grab the **review text** as well as the **rating**.  Luckily, these are the only things I need for the purpose of machine learning.

### Grabbing the Review Text
`Not working yet`

 `egrep -o "<p class=\"partial_entry\"[^<]*<p>"`
 What I want this to do is to grab the whole `<p></p>` block but it doesn't work because it stops at any HTML tag within that block.  There are some <scan> tags, so this doesn't work too well.

TODO: Finish the process
