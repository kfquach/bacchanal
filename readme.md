### Clustering NASDAQ and NYSE tech tickers with longitudinal data

Outside of earnings reports, stock tickers are strongly corrleated in daily movements. The relatively high volatily in tech stockers provide a good subset of data to explore how tech stocks may potentially be clustering together. To consider time-dependent movements, a longitudinal analysis is required to appropriately cluster tech tickers. This work will explore use of a longitudinal k-means algorithm to achieve this goal.

This will apply the work of C Genolini et al. (2015) `[https://www.jstatsoft.org/article/view/v065i04]`

### Data Sources

- List of total tickers in NYSE and NASDAQ obtained from `https://www.nasdaq.com/screening/company-list.aspx`
- Ticker data obtained from Tiingo API from 2018-10-01 to 2019-03-15
- Earnings calendar obtained from `earningscalendar.net`

### Longitudinal k-means algorithm

- Imputes missing data
- Determines clusters with 7 potential methods (`randomAll`, `randomK`, `maxDist`, `kmeans++`, `kmeans+`, `kmeans--`, `kmeans-`)
- Calculates distances by `id` and `time_period` specified

### Example

##### Input

Cell values are daily percentage changes

```
  ticker 2018-10-01 2018-10-02 2018-10-03 2018-10-04 2018-10-05
1   AABA -1.8967027  0.2557930 -0.3851281 -2.3200120 -0.8749041
2    AAN -0.5859733 -1.0322581  0.7575758 -1.9358407 -0.1311353
3   AAPL -0.3026980  0.8932893  0.8780700 -1.2089436 -1.6099316
4   ACIA -1.8401937  0.1976773  1.8190757 -0.2444988 -4.1092520
5   ACIW -3.7769149 -1.6880734  1.1507053 -1.7311234  0.3367003
6   ACLS -0.7085020 -0.4573171  1.7857143 -5.5165496 -2.8116711
```
##### Output

Output class based on number of clusters specified

```
  ticker cluster_12 cluster_15 cluster_18 cluster_21
1   AABA          D          D          D          E
2    AAN          A          A          A          B
3   AAPL          G          H          K          I
4   ACIA          C          B          C          K
5   ACIW          A          A          A          A
6   ACLS          C          B          C          D
```