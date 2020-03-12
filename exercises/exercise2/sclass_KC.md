sclass\_KC
================
Kyle Carter, Jacob Rachiele, Crystal Tse, Jinfang Yan
3/13/2020

## Problem 1: S Class

![](sclass_KC_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->![](sclass_KC_files/figure-gfm/unnamed-chunk-1-2.png)<!-- -->

We start with the 350 trim model and find the optimal K that minimizes
the RMSE after iterating through many train-test splits. Then we compare
the KNN model to linear regression models, one of which predicts price
using mileage, and the other uses a polynomial of mileage predicting
price. The red line is the RMSE for the linear regression model and teh
blude line is the second-degree polynomial.

![](sclass_KC_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

![](sclass_KC_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Do the same for the 65 Trim Train-test split for sclass
    65

![](sclass_KC_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

![](sclass_KC_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

    ##    min       Q1  median     Q3    max     mean       sd   n missing
    ##  18990 48711.25 79994.5 225975 247075 117121.1 81315.27 292       0

    ##   min       Q1 median       Q3    max     mean       sd   n missing
    ##  6600 19401.25  52900 61991.25 106010 46854.32 22842.57 416       0

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](sclass_KC_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](sclass_KC_files/figure-gfm/unnamed-chunk-6-2.png)<!-- -->

## Conclusion

It seems that the 65 trim has a much wider range, so the best KNN model
generalizes over that variation. In contrast, the 350 trim, although its
mean is being pulled downwards from low values, is more normally
distributed and has a tighter distribution. Also, there are fewer
observations for the 65 trim, so it is more prone to outliers. Thus, due
to the noise and few points to average over, the model must be more
flexible. Visually, if we compare the price of each trim to mileage in
the initial graphs, the 65 trim points are more spread out and have
several points with mileage values between 200,000 and 250,000 with low
or zero prices that could skew the results. Since the trend here is much
less obvious, the model benefits from a higher K; more points are being
averaged over and it results in a more “smoothed out” model. Conversely,
the 350 trim (although it appears to have 2 or 3 separate sup-groupings
with different slopes) has a more linear trend, so the K performs better
when it is smaller and more granular.

If we compare the RMSEs for both, the out-of-sample RMSE for the 65 trim
model is almost twice that of the 350 model, so the model is worse for
the 65 trim, likely due to the variation as described above. The
relatively higher K and RMSE values for the 65 trim could suggest high
bias; the model is oversimplifying and struggling to make a prediction.
Another indication of this is that the regression models perform better
for the 350 trim than for the 65 trim; a second-degree polynomial does
not perform much better than a linear line for the 350 trim whereas the
linear model has an extremely high error rate compared to the polynomial
and the KNN model.
