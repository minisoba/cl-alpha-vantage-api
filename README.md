[English](./README.md) | [日本語](./ja)

# Alpha Vantage API for Common Lisp

This is the [Alpha Vantage API](https://www.alphavantage.co/documentation) for Common Lisp, which provides
comprehensive access to the wide range of financial data and time series data offered by Alpha Vantage.

The library consists of an end-point URL generation layer and a data retrieval layer that parses JSON responses
into CLOS objects.

Currently, the following end points are not supported:

- NEWS_SENTIMENT
- TOP_GAINERS_LOSERS
- LISTING_STATUS (URL only)
- EARNINGS_CALENDAR (URL only)
- IPO_CALENDAR (URL only)


## Install

The library is ASDF-enabled and can be loaded by the following command:
```common-lisp
(asdf:load-system "cl-alpha-vantage-api")
```

### Dependencies

- alexandria
- cl-change-case
- cl-ppcre
- closer-mop
- drakma
- duckdb
- local-time
- parse-float
- yason
- fiveam (unit tests)

The library is tested with:

- SBCL (2.3.1)
- LispWorks (7.1.2)


## Quick Start

```common-lisp
;; Set your API token
(alpha-vantage:set-api-token "YOUR-API-TOKEN")

;; Get a time series of daily OHLC prices for AAPL
(alpha-vantage:get-time-series
 (alpha-vantage:time-series-daily :symbol "AAPL"))

;; Iterate over the time series
(alpha-vantage:do-time-series (ts (alpha-vantage:time-series-daily :symbol "AAPL") 'alpha-vantage:timestamp-of)
  (format t "~a: ~a~%" (alpha-vantage:timestamp-of ts) (alpha-vantage:close-price-of ts)))

;; Get a company overview
(alpha-vantage:get-overview "AAPL")

;; Get fundamental data
(alpha-vantage:get-income-statement-series "AAPL")

;; Save time series to a Parquet file
(alpha-vantage:save-to-parquet
 (alpha-vantage:get-time-series
  (alpha-vantage:time-series-daily :symbol "AAPL"))
 "/tmp/aapl-daily.parquet")
```


## API

API calls for individual functions are defined in `end-point-schema.lisp` and the syntax of end-point uses the following format.
The `defendpoint` macro parses an end-point schema and builds a function.

```
(function-name
 group-name)
 . ((argument-name field-attribute (:required or :optional) field-type)
    (argument-name field-attribute (:required or :optional) field-type)
    ...)
```

### Global Variables

##### `*api-token*`

API token for Alpha Vantage API access. Set via `set-api-token` or `setf`.

##### `*end-point-table*`

Routing table of API end-point structs, each containing `:name` and `:group`.

##### `*http-headers*`

HTTP response headers from the last API request.

##### `*http-status-code*`

HTTP status code from the last API request.

##### `*http-reason-phrase*`

HTTP reason phrase from the last API request.

##### `+query-url-base+`

Base URL for Alpha Vantage API queries.


### Classes

#### Time Series Classes

##### `time-series`

Time series class for commodities and economic indicators. Slots: `value-of`, `timestamp-of`.

##### `time-series-ohcl`

OHLC time series class for Core Stock APIs. Slots: `open-price-of`, `high-price-of`, `low-price-of`, `close-price-of`, `volume-of`, `timestamp-of`.

##### `fx-time-series-ohcl`

OHLC time series class for Forex. Slots: `open-price-of`, `high-price-of`, `low-price-of`, `close-price-of`, `timestamp-of`.

##### `crypto-time-series-ohcl`

OHLC time series class for Cryptocurrencies. Slots: `open-price-of`, `open-price-usd-of`, `high-price-of`, `high-price-usd-of`, `low-price-of`, `low-price-usd-of`, `close-price-of`, `close-price-usd-of`, `volume-of`, `market-cap-usd-of`, `timestamp-of`.

##### `ta-time-series`

Technical indicator time series class. Slots: `ta-values-of` (alist of indicator key/value pairs), `timestamp-of`.

##### `quote-snapshot`

Quote snapshot class from the Global Quote endpoint. Slots: `ticker-of`, `open-price-of`, `high-price-of`, `low-price-of`, `price-of`, `volume-of`, `timestamp-of`, `previous-close-price-of`, `change-of`, `change-percent-of`.

##### `fx-quote-snapshot`

FX quote snapshot class from the Currency Exchange Rate endpoint. Slots: `from-ccy-code-of`, `from-ccy-name-of`, `to-ccy-code-of`, `to-ccy-name-of`, `exchange-rate-of`, `timezone-of`, `timestamp-of`, `bid-price-of`, `ask-price-of`.

#### Fundamental Classes

##### `overview`

Company overview with financial metrics: `ticker-of`, `name-of`, `description-of`, `sector-of`, `industry-of`, `market-capitalization-of`, `pe-ratio-of`, `eps-of`, `dividend-yield-of`, `beta-of`, `52-week-high-of`, `52-week-low-of`, and many more.

##### `income-statement`

Slots: `report-period-of`, `fiscal-date-ending-of`, `reported-currency-of`, `gross-profit-of`, `total-revenue-of`, `operating-income-of`, `net-income-of`, `ebitda-of`, etc.

##### `balance-sheet`

Slots: `report-period-of`, `fiscal-date-ending-of`, `reported-currency-of`, `total-assets-of`, `total-liabilities-of`, `total-shareholder-equity-of`, etc.

##### `cash-flow`

Slots: `report-period-of`, `fiscal-date-ending-of`, `reported-currency-of`, `operating-cashflow-of`, `capital-expenditures-of`, `cashflow-from-investment-of`, `cashflow-from-financing-of`, `net-income-of`, etc.

##### `earnings`

Slots: `report-period-of`, `fiscal-date-ending-of`, `reported-eps-of`.

#### Symbol Search Class

##### `symbol-search`

Slots: `ticker-of`, `name-of`, `instrument-type-of`, `region-of`, `market-open-of`, `market-close-of`, `timezone-of`, `ccy-of`, `match-score-of`.


### Data Collection Functions

All data collection functions are found in `api.lisp`.

##### `get-time-series`

```common-lisp
(get-time-series query &optional (date-time-column 'timestamp-of))
```

Fetch and return a time series sorted by DATE-TIME-COLUMN from the Alpha Vantage QUERY URL.

```common-lisp
CL-USER> (alpha-vantage:get-time-series
           (alpha-vantage:time-series-daily :symbol "AAPL"))
;; => list of TIME-SERIES-OHCL objects sorted by timestamp
```

##### [Macro] `do-time-series`

```common-lisp
(do-time-series (var query date-time-column) &body body)
```

Iterate over each element of a time series, binding each to VAR.

```common-lisp
CL-USER> (alpha-vantage:do-time-series
           (ts (alpha-vantage:sma :symbol "AAPL" :interval :daily
                                  :time-period 20 :series-type :close)
               'alpha-vantage:timestamp-of)
           (format t "~a~%" (alpha-vantage:ta-values-of ts)))
```

##### `get-overview`

```common-lisp
(get-overview symbol)
```

Return an OVERVIEW object for SYMBOL.

```common-lisp
CL-USER> (alpha-vantage:get-overview "AAPL")
;; => OVERVIEW instance
```

##### `get-income-statement-series`

```common-lisp
(get-income-statement-series symbol)
```

Return a time series of INCOME-STATEMENT objects for SYMBOL.

```common-lisp
CL-USER> (alpha-vantage:get-income-statement-series "AAPL")
;; => list of INCOME-STATEMENT objects sorted by fiscal-date-ending
```

##### `get-balance-sheet-series`

```common-lisp
(get-balance-sheet-series symbol)
```

Return a time series of BALANCE-SHEET objects for SYMBOL.

```common-lisp
CL-USER> (alpha-vantage:get-balance-sheet-series "AAPL")
;; => list of BALANCE-SHEET objects sorted by fiscal-date-ending
```

##### `get-cash-flow-series`

```common-lisp
(get-cash-flow-series symbol)
```

Return a time series of CASH-FLOW objects for SYMBOL.

```common-lisp
CL-USER> (alpha-vantage:get-cash-flow-series "AAPL")
;; => list of CASH-FLOW objects sorted by fiscal-date-ending
```

##### `get-earnings-series`

```common-lisp
(get-earnings-series symbol)
```

Return a time series of EARNINGS objects for SYMBOL.

```common-lisp
CL-USER> (alpha-vantage:get-earnings-series "AAPL")
;; => list of EARNINGS objects sorted by fiscal-date-ending
```


### Parquet Export

##### `save-to-parquet`

```common-lisp
(save-to-parquet objects parquet-path &key (table-name "alpha_vantage_data"))
```

Write a list of CLOS objects to a Parquet file via DuckDB. Each object's direct slots are mapped to columns. All objects in the list must share the same type and slot layout.

Slot initforms determine column types: `0` → BIGINT, `0.0` → DOUBLE, otherwise → VARCHAR.

```common-lisp
;; Save daily OHLC data
CL-USER> (alpha-vantage:save-to-parquet
          (alpha-vantage:get-time-series
           (alpha-vantage:time-series-daily :symbol "AAPL"))
          "/tmp/aapl-daily.parquet")

;; Save income statements with a custom table name
CL-USER> (alpha-vantage:save-to-parquet
          (alpha-vantage:get-income-statement-series "AAPL")
          "/tmp/aapl-income.parquet"
          :table-name "income_statements")
```


### End-Point URL Functions

Each function builds an Alpha Vantage API query URL. The naming convention follows the Alpha Vantage function name in lispy style (hyphens instead of underscores). All end-point functions are defined in `end-points.lisp`.


#### Core Stock APIs

##### `time-series-intraday`

```common-lisp
(time-series-intraday &key symbol interval adjusted outputsize)
;; symbol     - ticker symbol (string, required)
;; interval   - :1min :5min :15min :30min :60min (required)
;; adjusted   - :true :false (optional)
;; outputsize - :compact :full (optional)
```

```common-lisp
CL-USER> (alpha-vantage:time-series-intraday :symbol "AAPL" :interval :5min)
"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&apikey=...&symbol=AAPL&interval=5min"
```

[Reference](https://www.alphavantage.co/documentation/#intraday)

##### `time-series-daily`

```common-lisp
(time-series-daily &key symbol outputsize)
;; symbol     - ticker symbol (string, required)
;; outputsize - :compact :full (optional)
```

```common-lisp
CL-USER> (alpha-vantage:time-series-daily :symbol "AAPL")
"https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&apikey=...&symbol=AAPL"
```

##### `time-series-daily-adjusted`

```common-lisp
(time-series-daily-adjusted &key symbol outputsize)
;; symbol     - ticker symbol (string, required)
;; outputsize - :compact :full (optional)
```

##### `time-series-weekly`

```common-lisp
(time-series-weekly &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `time-series-weekly-adjusted`

```common-lisp
(time-series-weekly-adjusted &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `time-series-monthly`

```common-lisp
(time-series-monthly &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `time-series-monthly-adjusted`

```common-lisp
(time-series-monthly-adjusted &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `global-quote`

```common-lisp
(global-quote &key symbol)
;; symbol - ticker symbol (string, required)
```

```common-lisp
CL-USER> (alpha-vantage:global-quote :symbol "AAPL")
"https://www.alphavantage.co/query?function=GLOBAL_QUOTE&apikey=...&symbol=AAPL"
```

##### `symbol-search`

```common-lisp
(symbol-search &key keywords)
;; keywords - search keywords (string, required)
```

```common-lisp
CL-USER> (alpha-vantage:symbol-search :keywords "microsoft")
"https://www.alphavantage.co/query?function=SYMBOL_SEARCH&apikey=...&keywords=microsoft"
```

##### `market-status`

```common-lisp
(market-status)
```


#### Fundamental Data

##### `overview`

```common-lisp
(overview &key symbol)
;; symbol - ticker symbol (string, required)
```

```common-lisp
CL-USER> (alpha-vantage:overview :symbol "AAPL")
"https://www.alphavantage.co/query?function=OVERVIEW&apikey=...&symbol=AAPL"
```

##### `income-statement`

```common-lisp
(income-statement &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `balance-sheet`

```common-lisp
(balance-sheet &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `cash-flow`

```common-lisp
(cash-flow &key symbol)
;; symbol - ticker symbol (string, required)
```

##### `earnings`

```common-lisp
(earnings &key symbol)
;; symbol - ticker symbol (string, required)
```


#### Forex (FX)

##### `currency-exchange-rate`

```common-lisp
(currency-exchange-rate &key from-currency to-currency)
;; from-currency - ISO currency code (string, 3 chars, required)
;; to-currency   - ISO currency code (string, 3 chars, required)
```

```common-lisp
CL-USER> (alpha-vantage:currency-exchange-rate :from-currency "USD" :to-currency "JPY")
"https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&apikey=...&from_currency=USD&to_currency=JPY"
```

##### `fx-intraday`

```common-lisp
(fx-intraday &key from-symbol to-symbol interval outputsize)
;; from-symbol - ISO currency code (string, 3 chars, required)
;; to-symbol   - ISO currency code (string, 3 chars, required)
;; interval    - :1min :5min :15min :30min :60min (required)
;; outputsize  - :compact :full (optional)
```

##### `fx-daily`

```common-lisp
(fx-daily &key from-symbol to-symbol outputsize)
;; from-symbol - ISO currency code (string, 3 chars, required)
;; to-symbol   - ISO currency code (string, 3 chars, required)
;; outputsize  - :compact :full (optional)
```

##### `fx-weekly`

```common-lisp
(fx-weekly &key from-symbol to-symbol)
;; from-symbol - ISO currency code (string, 3 chars, required)
;; to-symbol   - ISO currency code (string, 3 chars, required)
```

##### `fx-monthly`

```common-lisp
(fx-monthly &key from-symbol to-symbol)
;; from-symbol - ISO currency code (string, 3 chars, required)
;; to-symbol   - ISO currency code (string, 3 chars, required)
```


#### Cryptocurrencies

##### `crypto-intraday`

```common-lisp
(crypto-intraday &key symbol market interval outputsize)
;; symbol     - crypto symbol, e.g. "ETH" (string, 3 chars, required)
;; market     - exchange market, e.g. "USD" (string, 3 chars, required)
;; interval   - :1min :5min :15min :30min :60min (required)
;; outputsize - :compact :full (optional)
```

##### `digital-currency-daily` (alias: `crypto-daily`)

```common-lisp
(digital-currency-daily &key symbol market)
;; symbol - crypto symbol, e.g. "BTC" (string, 3 chars, required)
;; market - exchange market, e.g. "CNY" (string, 3 chars, required)
```

##### `digital-currency-weekly` (alias: `crypto-weekly`)

```common-lisp
(digital-currency-weekly &key symbol market)
;; symbol - crypto symbol (string, 3 chars, required)
;; market - exchange market (string, 3 chars, required)
```

##### `digital-currency-monthly` (alias: `crypto-monthly`)

```common-lisp
(digital-currency-monthly &key symbol market)
;; symbol - crypto symbol (string, 3 chars, required)
;; market - exchange market (string, 3 chars, required)
```


#### Commodities

##### `wti`

```common-lisp
(wti &key interval)
;; interval - :daily :weekly :monthly (optional)
```

##### `brent`

```common-lisp
(brent &key interval)
;; interval - :daily :weekly :monthly (optional)
```

##### `natural-gas`

```common-lisp
(natural-gas &key interval)
;; interval - :daily :weekly :monthly (optional)
```

##### `copper`

```common-lisp
(copper &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `aluminum`

```common-lisp
(aluminum &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `wheat`

```common-lisp
(wheat &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `corn`

```common-lisp
(corn &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `cotton`

```common-lisp
(cotton &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `sugar`

```common-lisp
(sugar &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `coffee`

```common-lisp
(coffee &key interval)
;; interval - :monthly :quarterly :annual (optional)
```

##### `all-commodities`

```common-lisp
(all-commodities &key interval)
;; interval - :monthly :quarterly :annual (optional)
```


#### Economic Indicators

##### `real-gdp`

```common-lisp
(real-gdp &key interval)
;; interval - :quarterly :annual (optional)
```

##### `real-gdp-per-capita`

```common-lisp
(real-gdp-per-capita)
```

##### `treasury-yield`

```common-lisp
(treasury-yield &key interval maturity)
;; interval - :daily :weekly :monthly (optional)
;; maturity - :3month :2year :5year :7year :10year :30year (optional)
```

```common-lisp
CL-USER> (alpha-vantage:treasury-yield :interval :monthly :maturity :10year)
"https://www.alphavantage.co/query?function=TREASURY_YIELD&apikey=...&interval=monthly&maturity=10year"
```

##### `federal-funds-rate`

```common-lisp
(federal-funds-rate &key interval)
;; interval - :daily :weekly :monthly (optional)
```

##### `cpi`

```common-lisp
(cpi &key interval)
;; interval - :monthly :semiannual (optional)
```

##### `inflation`

```common-lisp
(inflation)
```

##### `retail-sales`

```common-lisp
(retail-sales)
```

##### `durables`

```common-lisp
(durables)
```

##### `unemployment`

```common-lisp
(unemployment)
```

##### `nonfarm-payroll`

```common-lisp
(nonfarm-payroll)
```


#### Technical Indicators

All technical indicator functions accept `:symbol` (required, string) and `:interval` (required, one of `:1min :5min :15min :30min :60min :daily :weekly :monthly`). Many also accept `:time-period` (required, integer) and `:series-type` (required, one of `:close :open :high :low`).

##### `sma`

```common-lisp
(sma &key symbol interval time-period series-type)
```

```common-lisp
CL-USER> (alpha-vantage:sma :symbol "AAPL" :interval :daily :time-period 20 :series-type :close)
"https://www.alphavantage.co/query?function=SMA&apikey=...&symbol=AAPL&interval=daily&time_period=20&series_type=close"
```

##### `ema`

```common-lisp
(ema &key symbol interval time-period series-type)
```

##### `wma`

```common-lisp
(wma &key symbol interval time-period series-type)
```

##### `dema`

```common-lisp
(dema &key symbol interval time-period series-type)
```

##### `tema`

```common-lisp
(tema &key symbol interval time-period series-type)
```

##### `trima`

```common-lisp
(trima &key symbol interval time-period series-type)
```

##### `kama`

```common-lisp
(kama &key symbol interval time-period series-type)
```

##### `mama`

```common-lisp
(mama &key symbol interval time-period series-type fastlimit slowlimit)
;; fastlimit - fast limit (float, optional)
;; slowlimit - slow limit (float, optional)
```

##### `vwap`

```common-lisp
(vwap &key symbol interval)
;; interval - :1min :5min :15min :30min :60min (required)
```

##### `t3`

```common-lisp
(t3 &key symbol interval time-period series-type)
```

##### `macd`

```common-lisp
(macd &key symbol interval series-type fastperiod slowperiod signalperiod)
;; fastperiod   - (integer, optional)
;; slowperiod   - (integer, optional)
;; signalperiod - (integer, optional)
```

##### `macdext`

```common-lisp
(macdext &key symbol interval series-type fastperiod slowperiod signalperiod fastmatype slowmatype signalmatype)
;; fastmatype   - MA type keyword (optional)
;; slowmatype   - MA type keyword (optional)
;; signalmatype - MA type keyword (optional)
```

MA type keywords: `:sma :ema :wma :dema :tema :trima :t3 :kama :mama`

##### `stoch`

```common-lisp
(stoch &key symbol interval fastkperiod slowkperiod slowdperiod slowkmatype slowdmatype)
```

##### `stochf`

```common-lisp
(stochf &key symbol interval fastkperiod fastdperiod fastdmatype)
```

##### `rsi`

```common-lisp
(rsi &key symbol interval time-period series-type)
```

##### `stochrsi`

```common-lisp
(stochrsi &key symbol interval time-period series-type fastkperiod fastdperiod fastdmatype)
```

##### `willr`

```common-lisp
(willr &key symbol interval time-period)
```

##### `adx`

```common-lisp
(adx &key symbol interval time-period)
```

##### `adxr`

```common-lisp
(adxr &key symbol interval time-period)
```

##### `apo`

```common-lisp
(apo &key symbol interval series-type fastperiod slowperiod matype)
```

##### `ppo`

```common-lisp
(ppo &key symbol interval series-type fastperiod slowperiod matype)
```

##### `mom`

```common-lisp
(mom &key symbol interval time-period series-type)
```

##### `bop`

```common-lisp
(bop &key symbol interval)
```

##### `cci`

```common-lisp
(cci &key symbol interval time-period)
```

##### `cmo`

```common-lisp
(cmo &key symbol interval time-period series-type)
```

##### `roc`

```common-lisp
(roc &key symbol interval time-period series-type)
```

##### `rocr`

```common-lisp
(rocr &key symbol interval time-period series-type)
```

##### `aroon`

```common-lisp
(aroon &key symbol interval time-period)
```

##### `aroonosc`

```common-lisp
(aroonosc &key symbol interval time-period)
```

##### `mfi`

```common-lisp
(mfi &key symbol interval time-period)
```

##### `trix`

```common-lisp
(trix &key symbol interval time-period series-type)
```

##### `ultosc`

```common-lisp
(ultosc &key symbol interval timeperiod1 timeperiod2 timeperiod3)
;; timeperiod1 - (integer, optional)
;; timeperiod2 - (integer, optional)
;; timeperiod3 - (integer, optional)
```

##### `dx`

```common-lisp
(dx &key symbol interval time-period)
```

##### `minus-di`

```common-lisp
(minus-di &key symbol interval time-period)
```

##### `plus-di`

```common-lisp
(plus-di &key symbol interval time-period)
```

##### `minus-dm`

```common-lisp
(minus-dm &key symbol interval time-period)
```

##### `plus-dm`

```common-lisp
(plus-dm &key symbol interval time-period)
```

##### `bbands`

```common-lisp
(bbands &key symbol interval time-period series-type nbdevup nbdevdn matype)
;; nbdevup - standard deviation multiplier for upper band (integer, optional)
;; nbdevdn - standard deviation multiplier for lower band (integer, optional)
;; matype  - MA type keyword (optional)
```

##### `midpoint`

```common-lisp
(midpoint &key symbol interval time-period series-type)
```

##### `midprice`

```common-lisp
(midprice &key symbol interval time-period)
```

##### `sar`

```common-lisp
(sar &key symbol interval acceleration maximum)
;; acceleration - acceleration factor (float, optional)
;; maximum      - maximum value (float, optional)
```

##### `trange`

```common-lisp
(trange &key symbol interval)
```

##### `atr`

```common-lisp
(atr &key symbol interval time-period)
```

##### `natr`

```common-lisp
(natr &key symbol interval time-period)
```

##### `ad`

```common-lisp
(ad &key symbol interval)
```

##### `adosc`

```common-lisp
(adosc &key symbol interval fastperiod slowperiod)
;; fastperiod - (integer, optional)
;; slowperiod - (integer, optional)
```

##### `obv`

```common-lisp
(obv &key symbol interval)
```

##### `ht-trendline`

```common-lisp
(ht-trendline &key symbol interval series-type)
```

##### `ht-sine`

```common-lisp
(ht-sine &key symbol interval series-type)
```

##### `ht-trendmode`

```common-lisp
(ht-trendmode &key symbol interval series-type)
```

##### `ht-dcperiod`

```common-lisp
(ht-dcperiod &key symbol interval series-type)
```

##### `ht-dcphase`

```common-lisp
(ht-dcphase &key symbol interval series-type)
```

##### `ht-phasor`

```common-lisp
(ht-phasor &key symbol interval series-type)
```


## Unit Tests

The test suite uses [FiveAM](https://github.com/lispworks/fiveam) and covers end-point URL generation.

```common-lisp
;; Load and run tests
(asdf:test-system :cl-alpha-vantage-api)

;; Or run directly
(ql:quickload :cl-alpha-vantage-api-test)
(fiveam:run! 'alpha-vantage.test:alpha-vantage-tests)
```

## License

MIT (Y. Iguchi)
