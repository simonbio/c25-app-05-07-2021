#### LOAD PACKAGES

pkgs <- c('shiny', 'shinydashboard', 'plotly')

pkg_setup(pkgs)


#### UI 

ui <- dashboardPage(
  
  dashboardHeader(title = 'OMX Copenhagen 25'),
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem(text = 'OMXC25 index',tabName='index',icon=icon('chart-line')),
      menuItem(text = 'Risk versus Reward', tabName = 'rr', icon = icon('signal')),
      menuItem('About', tabName = 'about', icon = icon('question-circle'))
    ), 
    
    selectizeInput(inputId = 'stocks',
                   label = 'Enter a List of Stocks',
                   choices = NULL,
                   multiple = TRUE,
                   options = list(create = TRUE, closeAfterSelect = TRUE)
    )
    
    
  ),
  dashboardBody(
    
    # # Use custom style CSS
    # tags$head(
    #   tags$link(rel = 'stylesheet', type = 'text/css', href = 'custom.css')
    # ),
    
    # Avoid temporary error message in plot when no tickers are chosen
    tags$style(type='text/css',
               '.shiny-output-error { visibility: hidden; }',
               '.shiny-output-error:before { visibility: hidden; }'),
    
    tabItems(
      tabItem(tabName = 'index',
              fluidRow(
                box(title='Candlestick Chart of OMXC25, with Bollinger Bands and Moving Average', status='primary', solidHeader = TRUE,
                    plotlyOutput('p1', height = '940px'), width = 12, height = 1000)
              )
      ),
      
      tabItem(tabName = 'rr',
              fluidRow(
                box(title='Risk versus reward C25 stocks (Size of the Bubble = No. of trading days)', status='primary',solidHeader = TRUE,
                    plotlyOutput('p2', height = '540px'), width = 12, height = 600),
                
                box(title='Adjusted Closing Price', status='primary',solidHeader = TRUE,
                    plotlyOutput('p3', height = '540px'), width = 12, height = 600)
              ) 
      ), 
      
      
      tabItem(tabName = 'about',
              fluidRow(
                box(title='The following 25 companies make up the index as of todays date', status='primary',solidHeader = TRUE,
                    DT::dataTableOutput('table1'), width = 12)),
              
              box(width=12, solidHeader = TRUE, status = 'primary', 
                  p(style='font-size:18px', 'The', strong('OMX Copenhagen 25'), 'Index is a market value weighted, free float adjusted and capped index. 
                  The index contains the 25 largest and most traded shares on NASDAQ Copenhagen. The Index began on December 19, 2016 at a base value of 1000.'),
                  
                  p(style='font-size:18px','This dashboard can be used to explore the index itself as well as the 25 securities making up the index. The Risk/Reward tool is an interactive
              OMXC25 stock screening visualization that compares stocks based on growth (reward), variability (risk),
              and number of samples (risk). The tool can be used to visualize stocks with good characteristics: High growth (large mean log returns),
              low variability (low standard deviation), and high number of samples (days traded).'),
                  
                  p(style='font-size:18px', strong('Bollinger Bands'), 'are a type of chart indicator for technical analysis. The purpose of Bollinger Bands is to provide a relative definition of high and low prices of a market
              By definition, prices are high at the upper band and low at the lower band. This definition can aid in rigorous pattern recognition and is useful in comparing price action to the action of indicators to arrive at systematic trading decisions'),
                  
                  p(style='font-size:18px',strong('A Moving Average'), 'is a calculation used to analyze data points by creating a series of averages of different subsets of the full data set.
              In finance, a moving average (MA) is a stock indicator that is commonly used in technical analysis. The reason for calculating the moving average of a stock is to help smooth out the price data by creating a constantly updated average price.'),
                  
                  p(style='font-size:18px',strong('The Adjusted Closing Price '), 'amends a stocks closing price to reflect that stocks value after accounting for any corporate actions.
              It is often used when examining historical returns or doing a detailed analysis of past performance. '),
                  
                  p(style='font-size:18px','The stock data is retrieved from', tags$a(href='https://finance.yahoo.com/', 'Yahoo Finance'))
                  
              ), 
              
              h4("Author", strong("SKOE")),
              a("R code for this app",target="_blank",href="https://github.com/simonbio/c25-app-05-07-2021")
              
      )
    )
  )
)