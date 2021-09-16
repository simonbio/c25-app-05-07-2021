# OMX Copenhagen 25 app

This dashboard can be used to explore the index itself as well as the 25 securities making up the index. The Risk/Reward tool is an interactive OMXC25 stock screening visualization that compares stocks based on growth (reward), variability (risk), and number of samples (risk). The tool can be used to visualize stocks with good characteristics: High growth (large mean log returns), low variability (low standard deviation), and high number of samples (days traded).

The stock data is retrieved from [Yahoo Finance](https://finance.yahoo.com/)


The Risk versus Reward analysis is based on the article: [Quantitative Stock Analysis Tutorial: Screening the Returns for Every S&P500 Stock in Less than 5 Minutes](https://www.business-science.io/investments/2016/10/23/SP500_Analysis.html)

# How to run

Either,

```bash
git clone https://github.com/simonbio/c25-app-05-07-2021
```

```bash
R -e "shiny::runApp('c25-app-05-07-2021/')"
```

Or to deploy the containerised app and deployment environment,

```bash
sudo docker build -t c25-app-image .

sudo docker run --rm -p 3838:3838 c25-app-image
```

You can then access the Shiny app inside the Docker container rendered by your browser by navigating to http://localhost:3838.
