#### SERVER

server <- function(input, output, session) {
  
  #### LOAD PACKAGES
  
  pkgs <- c('quantmod',
            'tidyverse',
            'plotly',
            'lubridate',
            'rvest')
  
  pkg_setup(pkgs)
  
  #### FETCH AND PREPARE DATA
  
  
  ## INDEX ANALYSIS
  
  # fetch stock data
  sym <- getSymbols('^OMXC25', auto.assign = FALSE)
  
  sym <- na.omit(sym)
  
  df <- data.frame(Date=index(sym),coredata(sym))
  
  
  # create Bollinger Bands
  bbands <- BBands(sym[ ,c(2,3,4)])
  
  # join and subset data
  df <- filter(cbind(df, data.frame(bbands[,1:3])), Date >= '2017-01-31')
  
  # # colors column for increasing and decreasing
  df <- df %>% mutate(direction = ifelse(df['OMXC25.Close'] >= df['OMXC25.Open'], 'Increasing', 'Decreasing'))
  
  
  
  ## RISK/REWARD ANALYSIS
  
  # Web-scrape C25 stock list
  c25 <- read_html('https://en.wikipedia.org/wiki/OMX_Copenhagen_25') %>%
    html_node('table.wikitable') %>%
    html_table() %>%
    select(-IPO) %>% 
    as_tibble()
  
  # Format names
  names(c25) <- c25 %>% 
    names() %>% 
    str_to_lower() %>% 
    make.names()
  # Format ticker to yahoo syntax
  c25$ticker.symbol <- c25$ticker.symbol %>% gsub(pattern = ' ', replacement = '-') %>% paste0('.CO')
  
  # Intermediate table for output
  table1 <- c25
  
  # Build a nested data frame holding all information
  c25 <- c25 %>%
    mutate(
      stock.prices = map(ticker.symbol, 
                         function(.x) get_stock_prices(.x, 
                                                       return_format = 'tibble',
                                                       from = '2007-01-01',
                                                       to = '2021-07-01')
      ),
      log.returns  = map(stock.prices, 
                         function(.x) get_log_returns(.x, return_format = 'tibble')),
      mean.log.returns = map_dbl(log.returns, ~ mean(.$Log.Returns)),
      sd.log.returns   = map_dbl(log.returns, ~ sd(.$Log.Returns)),
      n.trade.days = map_dbl(stock.prices, nrow)
    )  
  
  
  # Dynamic UI
  
  updateSelectizeInput(session,
                       'stocks',
                       choices = c25$ticker.symbol,
                       selected = c25$ticker.symbol)
  
  
  
  #### OUTPUT
  
  
  output$p1 <- renderPlotly({
    
    data <- df
    
    # plot candlestick chart
    
    i <- list(line = list(color = '#17BECF'))
    d <- list(line = list(color = '#7F7F7F'))
    
    
    fig <- data %>% plot_ly(x = ~Date, type='candlestick',
                            open = ~OMXC25.Open, close = ~OMXC25.Close,
                            high = ~OMXC25.High, low = ~OMXC25.Low, name = 'OMXC25',
                            increasing = i, decreasing = d)
    fig <- fig %>% add_lines(x = ~Date, y = ~up , name = 'B Bands',
                             line = list(color = '#ccc', width = 1),
                             legendgroup = 'Bollinger Bands',
                             inherit = F)
    fig <- fig %>% add_lines(x = ~Date, y = ~dn, name = 'B Bands',
                             line = list(color = '#ccc', width = 1),
                             legendgroup = 'Bollinger Bands', inherit = F,
                             showlegend = FALSE)
    fig <- fig %>% add_lines(x = ~Date, y = ~mavg, name = 'Mv Avg',
                             line = list(color = '#E377C2', width = 1),
                             inherit = F)
    fig <- fig %>% layout(yaxis = list(title = 'Price'))
    
    # plot volume bar chart
    fig2 <- data
    fig2 <- fig2 %>% plot_ly(x=~Date, y=~OMXC25.Volume, type='bar', name = 'OMXC25 Volume',
                             color = ~direction, colors = c('#7F7F7F', '#7F7F7F'))
    fig2 <- fig2 %>% layout(yaxis = list(title = 'Volume'))
    
    # create rangeselector buttons
    rs <- list(visible = TRUE, x = 0, y = 1,
               xanchor = 'center', yref = 'paper',
               font = list(size = 11),
               bgcolor = 'rgba(150, 200, 250, 0.4)',
               buttons = list(
                 list(
                   step = 'all',
                   count = 1,
                   label = 'reset'
                 ),
                 list(
                   step = 'year',
                   count = 1,
                   label = '1yr',
                   stepmode = 'backward'
                 ),
                 list(
                   step = 'month',
                   count = 3,
                   label = '3 mo',
                   stepmode = 'backward'
                 ),
                 list(
                   step = 'month',
                   count = 1,
                   label = '1 mo',
                   stepmode = 'backward')
               ))
    
    # subplot with shared x axis
    fig <- subplot(fig, fig2, heights = c(0.7,0.2), nrows=2,
                   shareX = TRUE, titleY = TRUE)
    fig <- fig %>% layout(title = paste('OMXC25: 2017-01-31 -',Sys.Date()),
                          hovermode = 'x unified',
                          xaxis = list(rangeselector = rs),
                          legend = list(orientation = 'h', x = 0.5, y = 1,
                                        xanchor = 'center', yref = 'paper',
                                        font = list(size = 10)))
    fig
  })
  
  
  output$p2 <- renderPlotly({
    
    slctd_data <- c25 %>%
      filter(ticker.symbol %in% input$stocks)
    
    
    plot_ly(data  = slctd_data,
            type   = 'scatter',
            mode   = 'markers',
            x      = ~ sd.log.returns,
            y      = ~ mean.log.returns,
            # color  = 'blue',
            #colors = 'Greens',
            size   = ~ n.trade.days,
            sizes = c(50,150),
            text   = ~ str_c('<em>', company, '</em><br>',
                             'Ticker: ', ticker.symbol, '<br>',
                             'Sector: ', gics.sector, '<br>',
                             'Founded: ', founded, '<br>',
                             'No. of Trading Days: ', n.trade.days),
            marker = list(opacity = 0.8,
                          symbol = 'circle',
                          sizemode = 'diameter',
                          sizeref = 4.0,
                          line = list(width = 1, color = 'lightgrey'))) %>%
      
      layout(title   = 'C25 Analysis: Stock Risk vs Reward',
             xaxis   = list(title = 'Risk/Variability (StDev Log Returns)',
                            zerolinewidth = 1,
                            ticklen = 5,
                            gridwidth = 2),
             yaxis   = list(title = 'Reward/Growth (Mean Log Returns)',
                            zerolinewidth = 1,
                            ticklen = 5,
                            gridwith = 2),
             margin = list(l = 100,
                           t = 100,
                           b = 100)) %>% 
      hide_colorbar()
  })
  
  
  output$p3 <- renderPlotly({
    
    slctd_data <- c25 %>%
      filter(ticker.symbol %in% input$stocks) %>%
      unnest(., stock.prices)
    
    plot_ly(data = slctd_data,
            x = ~Date,
            y = ~Adjusted,
            color = ~ticker.symbol,
            type = 'scatter',
            mode = 'lines')
  })
  
  
  
  output$table1 <- DT::renderDataTable({
    
    table1 %>% 
      filter(ticker.symbol %in% input$stocks)
  })
}