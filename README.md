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

```
for x in $@
        do
                cat $x | tr -d "\r\n" | tr '[:upper:]' '[:lower:]' | egrep -o "<div class=\"listcontainer.hide-more-mobile.*<a data-page-number=\"[0-9]*\".*data-offset=\"[0-9]*\"class=\"pagenum last[^<]*</a></div></div><[^>]*><[^>]*>" | sed 's/<span class=\"ui_bubble_rating bubbl/\n&/g' | sed s/"<span class=\"ui_bubble_rating bubble_\([0-9]\)[0-9]"/\\1/ | sed 's/<div class=\"loadingshade hidden/\n&/g' | sed 's/<div class=\"mgrrspninline\">.*<\/div><\/div><\/div>//g' | sed 's/<p/\n&/g' | sed 's/\"><\/span><span class=\"ratingdate\".*<div class=\"entry\">//' | egrep -o "^[0-9]|<p class=\"partial_entry\".*</p>" | sed s/"<[^>]*>"//g | paste - - >> reviews.txt
        done
```
This is the bash script I created to scrape the review text as well as the score.

##### Explanation:

To grab the reviews, they're inside of `<p> /Review Text/ </p>` tags, so I grabbed those using egrep, plus this cool sed trick:
`sed 's/<p/\n&/g' | egrep -o "<p class=\"partial_entry\".*</p>"`

I used that same trick to remove the manager response to each review: `sed 's/<div class=\"loadingshade hidden/\n&/g' | sed 's/<div class=\"mgrrspninline\">.*<\/div><\/div><\/div>//g'`
 
Each review score is inside this `<span class="ui_bubble_rating bubble_RATINGHERE>`.  So I had to use the newline trick with sed to isolate those. (`sed s/"<span class=\"ui_bubble_rating bubble_\([0-9]\)[0-9]"/\\1/`)

After that, I just grepped the lines that started and ended with just one number, or the `<p> /Review Text/ </p>` (`egrep -o "^[0-9]|<p class=\"partial_entry\".*</p>"`)

Lastly, I removed all the HTML tags: `sed s/"<[^>]*>"//g`

And then pasted each line (which was formatted "RATING_NUMBER, newline, REVIEW_TEXT" together using this cool paste trick: `paste - -` (Thanks StackOverflow!)

Next, we have to pipe those into files!  Just add >> filename.txt to the end of the pipeline, and it will append to a file (`>` is good for saving to a file once, `>>` is good for parallelization (saving to files and adding to that same file)).  I did this with both scores.

Now we're ready to parallelize.

### PARALLELIZING:

The way that `curl` works is that it downloads the html, but is more robust than `wget` and uses a library, called libcurl.  Using curl, we can download each TripAdvisor link:

`https://www.tripadvisor.com/Hotel_Review-g32655-d124956-Reviews-or[this number increments by 5]-Hotel_Figueroa-Los_Angeles_California.html`

As you can see, the format of the link dictates that the "or_" number increments by 5 for each page.

This can be done with curl by doing: `curl https://www.tripadvisor.com/Hotel_Review-g32655-d124956-Reviews-or[5-575:5]-Hotel_Figueroa-Los_Angeles_California.html -o HotelFigueroaPage#1.html`

*Keep in mind, the number of pages TripAdvisor says it has should be multiplied by 5.  E.g. 116 pages of reviews = [5-575:5]*

1. So, download each review page using curl, and the syntax defined above
2. run `reviewScraper.sh` on each file like this:
 `find *.html | xargs bash reviewScraper.sh`
3. There should be one file remaining with you reviews, called `reviews.txt`. (Tip: This is a tab delimited file, so you can load it into Excel if you use the import function and say that it is delimited by tabs)


And we're done!  That is my complete pipeline and parallelization process for grabbing hotel reviews for any hotel from TripAdvisor!

Feel free to use, change, and/or modify this if you would like.
