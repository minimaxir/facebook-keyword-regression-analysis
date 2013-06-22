The code and data used to write my blog post "Predicting the Number of Likes on a Facebook Status With Statistical Keyword Analysis" at http://minimaxir.com/2013/06/big-social-data/

An explanation of the derivation of the analysis is below.

----------


Before any analysis, it's helpful to validate the data. What is the distribution of the number of Likes on a status? How many statuses have low numbers of likes? How many statuses have gone viral and have an absurdly large number of likes? After removing a few obvious outliers (such as CNN's [status urging fans to vote in the 2012 election](http://www.facebook.com/5550296508/posts/266768910110901) with *314,774* Likes), I've created a histogram of the data:

![](http://minimaxir.com/img/cnn_Likes_Histogram.png)

The data is *very* right-skewed, with most of the data points centered around 1,000 Likes. This behavior isn't surprising; news posts don't go viral every time they're posted, but it could be helpful in the analysis.

The keywords, which for this analysis are *any words containing a capital letter*, are extracted from the post Messages for each Status update and are subsequently tallied. Keywords which appear on atleast 30 different status updates are significant enough to provide useful data for analysis. For CNN, these 93 keywords are:

![](http://minimaxir.com/img/cnn_Frequent.png)

CNN certainly posts about a variety of subjects.

Each of these top keywords are compared against the existing keywords in each status. If a top keyword matches a keyword in the status, that keyword is marked with a **Y** for that status, otherwise, it is marked with a **N**.

Additionally for the regression, two more variables are needed: the *time* the post was made (in days since 6/1/12) and the *type* of post (status, photo, video). The former measures growth over time, and the latter, as noted, has a significant effect on the number of Likes for a status. For these regressions, it's important to include all relevant variables so that the changes in the data can be attributed to the appropriate variable.

Now, we can regress NumLikes on *time*, *type*, and the 93 keyword variables.

    Call:
    lm(formula = numLikes ~ ., data = data)
    
    Residuals:
    	Min 	 1Q  Median  	3Q 		Max 
    -3836.8  -447.8  -192.2   170.5 14522.1 
    
    Coefficients:
    			Estimate 	Std. Error	t value Pr(>|t|)
    (Intercept)	588.3916	76.6119   	7.680 	2.08e-14 ***
    time		-0.2369	 	0.2557 		-0.927 	0.354151
    typephoto 	2095.6119	80.0651  	26.174  < 2e-16	 ***
    typevideo  	381.9977	77.3933   	4.936 	8.38e-07 ***
    CNNY  		-19.3910	83.0820  	-0.233 	0.815468
    SeeY  		-40.9881	60.4718  	-0.678 	0.497943
    TheY  		-11.9820	70.4743  	-0.170 	0.865005
    DoY  		153.5012	93.3257   	1.645 	0.100109 

	...

    BourdainY	2225.6932   653.4404   	3.406 	0.000667 ***
    AtY   		103.2626   	266.3599   	0.388 	0.698278
    DidY 		-140.9736   260.6737  	-0.541 	0.588679
    DrY  		-127.2331   270.5502  	-0.470 	0.638189 
	-----
	Residual standard error: 1424 on 3289 degrees of freedom
	Multiple R-squared: 0.2745,	Adjusted R-squared: 0.2534 


The estimate coefficient of each variable tells us the expected change in the dependent variable (*numLikes*) for a one-unit change in the variable. If the variable is a factor variable, like the presence of a keyword, then in this case, the coefficient describes the expected change in numLikes.

A few examples:

- If CNN made a normal status update with literally no other content than "hi", then the expected amount of likes is about **588 Likes**.
- Every passing day, the expected amount of Likes on a CNN status **decreases by 0.23 Likes**. (i.e. -7 Likes/month)
- If CNN made a Photo post, the expected increase in Likes is about **2095 Likes** (likewise, a Video post has an expected increase of about **382 Likes**)
- If a Status update contains "CNN", the expected amount of likes **decreases by 19 Likes**.

We now have the secret to using keywords, right? Unfortunately, we're not done.

How *accurately* does this model of using keywords predict the number of Likes received? Here's the residual plot of the actual number of Likes for a given status minus the predicted number of likes by the model.

![](http://minimaxir.com/img/cnn_Residual_Plot.png)

The good news is that there's no pattern amount the residuals, and that the majority are centered around 0 (Actual = Predicted). Unfortunately, the variance in the residuals is extremely high, from -4000 to 15000, which indicates that the model alone may not be robust enough to predict the number of Likes.

The R-squared value of the model is 0.2745, i.e. the model explains 27.45% of the variation in the number of Likes on a status. Ideally, this value would be close to 1.0 (the model is perfect), but a R-squared value of 0.2745 by using a simple regression model and uncontrolled real-world data is *pretty damn good*.

We might not be able to determine the *exact* number of Likes predicted by a variable, but we are able to estimate the *importance* of each keyword through relative importance. That analysis is still incredibly useful.

We can improve the model by removing redundant and potentially harmful keyword variables, especially since we only chose the most frequently occurring keywords. We don't need *both* "BREAKING" and "NEWS" since they almost always appear together in the same status. The R programming language has a built-in brute-force optimizer that removes variables from a regression until removing variables stops improving the model.

Running the optimizer reduces the number of keywords in the model from 93 to *26*. Out of those 26, we can only consider the variables which are statistically significant at the 95% confidence level (i.e. we have a less than 5% chance of failing to reject the hypothesis that the keyword variable has no effect on the regression). Therefore, here are the final influential keywords for CNN:

![](http://minimaxir.com/img/cnn_Wordcloud.png)

    				+Likes			Pr(>|t|)
    Bourdain		1962.98			0
    NEWS			1272.64			0
    Photo			1154.6			0
    Barack			1002.45			0
    City			851.82			0
    Monday			705.42			0
    Obama			632.2			0
    United			578.77			0
    Mitt			562.29			0.01
    South			508.43			0.03
    America			505.83			0.01
    Watch			470.51			0
    Boston			398.13			0.05
    New				326.74			0.03
    ET				-433.96			0
    North			-467.05			0.02
    Check			-503.5			0
    Travel			-988.99			0.02


R-squared only changes slightly (0.267). It's not a perfect analysis, but it's a very good analysis in lieu of perfect data.