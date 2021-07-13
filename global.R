
# Set up package environment
pkg_setup <- function(pkg){
  new_pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new_pkg))
    install.packages(new_pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}


# Fetch stock prices
get_stock_prices <- function(ticker, return_format = "tibble", ...) {
  # Get stock prices
  stock_prices_xts <- getSymbols(Symbols = ticker, auto.assign = FALSE)
  # Rename
  names(stock_prices_xts) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")
  # Return in xts format if tibble is not specified
  if (return_format == "tibble") {
    stock_prices <- data.frame(index(stock_prices_xts), coredata(stock_prices_xts)) %>%
      as_tibble() %>% 
      rename(Date = index.stock_prices_xts.)
  } else {
    stock_prices <- stock_prices_xts
  }
  stock_prices
}

# Calculate log returns
get_log_returns <- function(x, return_format = "tibble", period = 'daily', ...) {
  # Convert tibble to xts
  if (!is.xts(x)) {
    x <- xts(x[,-1], order.by = x$Date)
  }
  # Get log returns
  log_returns_xts <- periodReturn(x = x$Adjusted, type = 'log', period = period)
  # Rename
  names(log_returns_xts) <- "Log.Returns"
  # Return in xts format if tibble is not specified
  if (return_format == "tibble") {
    log_returns <- data.frame(index(log_returns_xts), coredata(log_returns_xts)) %>%
      as_tibble() %>%
      rename(Date = index.log_returns_xts.)
  } else {
    log_returns <- log_returns_xts
  }
  log_returns
}