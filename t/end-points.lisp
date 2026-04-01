(in-package :alpha-vantage.test)

(def-suite end-point-tests :in alpha-vantage-tests
  :description "End point tests")

(in-suite end-point-tests)

(defun %compare-unordered-list (lst1 lst2 &key test sep)
  (equal (sort (cl-ppcre:split sep lst1) test)
         (sort (cl-ppcre:split sep lst2) test)))

(defun validate-url (source target)
  "Check if SOURCE and TARGET URLs are matched with un-ordered URL token."
  (let ((target (format nil "https://~a~a&apikey=~a" +query-url-base+ target *api-token*)))
    (is-true (%compare-unordered-list source target :test #'string< :sep "&"))))

(defun validate-parameter-type (typ values)
  "Check if VALUES are of TYPE."
  (dolist (x values)
    (is-true (alpha-vantage::check-parameter-type "" "" typ x))))

(defmacro validate-parameter-condition (typ err-cond)
  "Check if an invalid value generates an ERR-COND of TYPE."
  `(signals ,err-cond
     (alpha-vantage::check-parameter-type "" "" ,typ :invalid)))

(test check-parameter-type-test
  (validate-parameter-type
   :interval-0-types
   '(:1min :5min :15min :30min :60min))

  (validate-parameter-condition
   :interval-0-types
   interval-0-types-error)

  (validate-parameter-type
   :interval-1-types
   '(:1min :5min :15min :30min :60min :daily :weekly :monthly))

  (validate-parameter-condition
   :interval-1-types
   interval-1-types-error)

  (validate-parameter-type
   :interval-2-types
   '(:daily :weekly :monthly))

  (validate-parameter-condition
   :interval-2-types
   interval-2-types-error)

  (validate-parameter-type
   :interval-3-types
   '(:monthly :quarterly :annual))

  (validate-parameter-condition
   :interval-3-types
   interval-3-types-error)

  (validate-parameter-type
   :interval-4-types
   '(:quarterly :annual))

  (validate-parameter-condition
   :interval-4-types
   interval-4-types-error)

  (validate-parameter-type
   :interval-5-types
   '(:monthly :semiannual))

  (validate-parameter-condition
   :interval-5-types
   interval-5-types-error)

  (validate-parameter-type
   :treasury-maturity-types
   '(:3month :2year :5year :7year :10year :30year))

  (validate-parameter-condition
   :treasury-maturity-types
   treasury-maturity-types-error)

  (validate-parameter-type
   :boolean-types
   '(:true :false))

  (validate-parameter-condition
   :boolean-types
   boolean-types-error)

  (validate-parameter-type
   :output-size-types
   '(:compact :full))

  (validate-parameter-condition
   :output-size-types
   output-size-types-error)

  (validate-parameter-type
   :earnings-horizon-types
   '(:3month :6month :12month))

  (validate-parameter-condition
   :earnings-horizon-types
   earnings-horizon-types-error)

  (validate-parameter-type
   :sort-types
   '(:latest :earliest :relevance))

  (validate-parameter-condition
   :sort-types
   sort-types-error)

  (validate-parameter-type
   :series-types
   '(:close :open :high :low))

  (validate-parameter-condition
   :series-types
   series-types-error)

  (validate-parameter-type
   :ma-types
   '(:sma :ema :wma :dema :tema :trima :t3 :kama :mama))

  (validate-parameter-condition
   :ma-types
   ma-types-error))

(test time-series-intraday-tests
  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :1min)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=1min")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :5min)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=5min")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :15min)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=15min")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :30min)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=30min")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :60min)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=60min")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :60min :adjusted :true)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=60min&adjusted=true")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :60min :adjusted :false)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=60min&adjusted=false")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :60min :adjusted :false :outputsize :compact)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=60min&adjusted=false&outputsize=compact")

  (validate-url
   (time-series-intraday
    :symbol "AAPL" :interval :60min :adjusted :false :outputsize :full)
   "TIME_SERIES_INTRADAY&symbol=AAPL&interval=60min&adjusted=false&outputsize=full"))

(test time-series-daily-tests
  (validate-url
   (time-series-daily
    :symbol "AAPL")
   "TIME_SERIES_DAILY&symbol=AAPL")

  (validate-url
   (time-series-daily
    :symbol "AAPL" :outputsize :compact)
   "TIME_SERIES_DAILY&symbol=AAPL&outputsize=compact")

  (validate-url
   (time-series-daily
    :symbol "AAPL" :outputsize :full)
   "TIME_SERIES_DAILY&symbol=AAPL&outputsize=full"))

(test time-series-daily-adjusted-tests
  (validate-url
   (time-series-daily-adjusted
    :symbol "AAPL")
   "TIME_SERIES_DAILY_ADJUSTED&symbol=AAPL")

  (validate-url
   (time-series-daily-adjusted
    :symbol "AAPL" :outputsize :compact)
   "TIME_SERIES_DAILY_ADJUSTED&symbol=AAPL&outputsize=compact")

  (validate-url
   (time-series-daily-adjusted
    :symbol "AAPL" :outputsize :full)
   "TIME_SERIES_DAILY_ADJUSTED&symbol=AAPL&outputsize=full"))

(test time-series-weekly-tests
  (validate-url
   (time-series-weekly
    :symbol "AAPL")
   "TIME_SERIES_WEEKLY&symbol=AAPL"))

(test time-series-weekly-adjusted-tests
  (validate-url
   (time-series-weekly-adjusted
    :symbol "AAPL")
   "TIME_SERIES_WEEKLY_ADJUSTED&symbol=AAPL"))

(test time-series-monthly-tests
  (validate-url
   (time-series-monthly
    :symbol "AAPL")
   "TIME_SERIES_MONTHLY&symbol=AAPL"))

(test time-series-monthly-adjusted-tests
  (validate-url
   (time-series-monthly-adjusted
    :symbol "AAPL")
   "TIME_SERIES_MONTHLY_ADJUSTED&symbol=AAPL"))

(test global-quote-tests
  (validate-url
   (global-quote
    :symbol "AAPL")
   "GLOBAL_QUOTE&symbol=AAPL"))

(test symbol-search-tests
  (validate-url
   (symbol-search
    :keywords "microsoft")
   "SYMBOL_SEARCH&keywords=microsoft"))

(test market-status-tests
  (validate-url
   (market-status)
   "MARKET_STATUS"))

(test company-overview-tests
  (validate-url
   (overview
    :symbol "AAPL")
   "OVERVIEW&symbol=AAPL"))

(test income-statement-tests
  (validate-url
   (income-statement
    :symbol "AAPL")
   "INCOME_STATEMENT&symbol=AAPL"))

(test balance-sheet-tests
  (validate-url
   (balance-sheet
    :symbol "AAPL")
   "BALANCE_SHEET&symbol=AAPL"))

(test cash-flow-tests
  (validate-url
   (cash-flow
    :symbol "AAPL")
   "CASH_FLOW&symbol=AAPL"))

(test earnings-tests
  (validate-url
   (earnings
    :symbol "AAPL")
   "EARNINGS&symbol=AAPL"))

(test currency-exchange-rate-tests
  (validate-url
   (currency-exchange-rate
    :from-currency "USD"
    :to-currency "JPY")
   "CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=JPY"))

(test fx-intraday-tests
  (validate-url
   (fx-intraday
    :from-symbol "EUR"
    :to-symbol "USD"
    :interval :1min)
   "FX_INTRADAY&from_symbol=EUR&to_symbol=USD&interval=1min")

  (validate-url
   (fx-intraday
    :from-symbol "EUR"
    :to-symbol "USD"
    :interval :1min
    :outputsize :full)
   "FX_INTRADAY&from_symbol=EUR&to_symbol=USD&interval=1min&outputsize=full"))

(test fx-daily-tests
  (validate-url
   (fx-daily
    :from-symbol "EUR"
    :to-symbol "USD")
   "FX_DAILY&from_symbol=EUR&to_symbol=USD")

  (validate-url
   (fx-daily
    :from-symbol "EUR"
    :to-symbol "USD"
    :outputsize :full)
   "FX_DAILY&from_symbol=EUR&to_symbol=USD&outputsize=full"))

(test fx-weekly-tests
  (validate-url
   (fx-weekly
    :from-symbol "EUR"
    :to-symbol "USD")
   "FX_WEEKLY&from_symbol=EUR&to_symbol=USD"))

(test fx-monthly-tests
  (validate-url
   (fx-monthly
    :from-symbol "EUR"
    :to-symbol "USD")
   "FX_MONTHLY&from_symbol=EUR&to_symbol=USD"))

(test crypto-intraday-tests
  (validate-url
   (crypto-intraday
    :symbol "ETH"
    :market "USD"
    :interval :1min)
   "CRYPTO_INTRADAY&symbol=ETH&market=USD&interval=1min")

  (validate-url
   (crypto-intraday
    :symbol "ETH"
    :market "USD"
    :interval :1min
    :outputsize :full)
   "CRYPTO_INTRADAY&symbol=ETH&market=USD&interval=1min&outputsize=full"))

(test digital-currency-daily-tests
  (validate-url
   (digital-currency-daily
    :symbol "BTC"
    :market "CNY")
   "DIGITAL_CURRENCY_DAILY&symbol=BTC&market=CNY"))

(test digital-currency-weekly-tests
  (validate-url
   (digital-currency-weekly
    :symbol "BTC"
    :market "CNY")
   "DIGITAL_CURRENCY_WEEKLY&symbol=BTC&market=CNY"))

(test digital-currency-monthly-tests
  (validate-url
   (digital-currency-monthly
    :symbol "BTC"
    :market "CNY")
   "DIGITAL_CURRENCY_MONTHLY&symbol=BTC&market=CNY"))

(test wti-tests
  (validate-url
   (wti
    :interval :daily)
   "WTI&interval=daily")

  (validate-url
   (wti
    :interval :weekly)
   "WTI&interval=weekly")

  (validate-url
   (wti
    :interval :monthly)
   "WTI&interval=monthly"))

(test brent-tests
  (validate-url
   (brent
    :interval :daily)
   "BRENT&interval=daily"))

(test natural-gas-tests
  (validate-url
   (natural-gas
    :interval :daily)
   "NATURAL_GAS&interval=daily"))

(test copper-tests
  (validate-url
   (copper
    :interval :monthly)
   "COPPER&interval=monthly")

  (validate-url
   (copper
    :interval :quarterly)
   "COPPER&interval=quarterly")

  (validate-url
   (copper
    :interval :annual)
   "COPPER&interval=annual"))

(test aluminum-tests
  (validate-url
   (aluminum
    :interval :monthly)
   "ALUMINUM&interval=monthly")

  (validate-url
   (aluminum
    :interval :quarterly)
   "ALUMINUM&interval=quarterly")

  (validate-url
   (aluminum
    :interval :annual)
   "ALUMINUM&interval=annual"))

(test wheat-tests
  (validate-url
   (wheat
    :interval :monthly)
   "WHEAT&interval=monthly")

  (validate-url
   (wheat
    :interval :quarterly)
   "WHEAT&interval=quarterly")

  (validate-url
   (wheat
    :interval :annual)
   "WHEAT&interval=annual"))

(test corn-tests
  (validate-url
   (corn
    :interval :monthly)
   "CORN&interval=monthly")

  (validate-url
   (corn
    :interval :quarterly)
   "CORN&interval=quarterly")

  (validate-url
   (corn
    :interval :annual)
   "CORN&interval=annual"))

(test cotton-tests
  (validate-url
   (cotton
    :interval :monthly)
   "COTTON&interval=monthly")

  (validate-url
   (cotton
    :interval :quarterly)
   "COTTON&interval=quarterly")

  (validate-url
   (cotton
    :interval :annual)
   "COTTON&interval=annual"))

(test sugar-tests
  (validate-url
   (sugar
    :interval :monthly)
   "SUGAR&interval=monthly")

  (validate-url
   (sugar
    :interval :quarterly)
   "SUGAR&interval=quarterly")

  (validate-url
   (sugar
    :interval :annual)
   "SUGAR&interval=annual"))

(test coffee-tests
  (validate-url
   (coffee
    :interval :monthly)
   "COFFEE&interval=monthly")

  (validate-url
   (coffee
    :interval :quarterly)
   "COFFEE&interval=quarterly")

  (validate-url
   (coffee
    :interval :annual)
   "COFFEE&interval=annual"))

(test all-commodities-tests
  (validate-url
   (all-commodities
    :interval :monthly)
   "ALL_COMMODITIES&interval=monthly")

  (validate-url
   (all-commodities
    :interval :quarterly)
   "ALL_COMMODITIES&interval=quarterly")

  (validate-url
   (all-commodities
    :interval :annual)
   "ALL_COMMODITIES&interval=annual"))

(test real-gdp-tests
  (validate-url
   (real-gdp
    :interval :quarterly)
   "REAL_GDP&interval=quarterly")

  (validate-url
   (real-gdp
    :interval :annual)
   "REAL_GDP&interval=annual"))

(test real-gdp-per-capita-tests
  (validate-url
   (real-gdp-per-capita)
   "REAL_GDP_PER_CAPITA"))

(test treasury-yield-tests
  (validate-url
   (treasury-yield
    :interval :daily)
   "TREASURY_YIELD&interval=daily")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :3month)
   "TREASURY_YIELD&interval=monthly&maturity=3month")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :2year)
   "TREASURY_YIELD&interval=monthly&maturity=2year")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :5year)
   "TREASURY_YIELD&interval=monthly&maturity=5year")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :7year)
   "TREASURY_YIELD&interval=monthly&maturity=7year")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :10year)
   "TREASURY_YIELD&interval=monthly&maturity=10year")

  (validate-url
   (treasury-yield
    :interval :monthly
    :maturity :30year)
   "TREASURY_YIELD&interval=monthly&maturity=30year"))

(test federal-funds-rate-tests
  (validate-url
   (federal-funds-rate
    :interval :daily)
   "FEDERAL_FUNDS_RATE&interval=daily")

  (validate-url
   (federal-funds-rate
    :interval :weekly)
   "FEDERAL_FUNDS_RATE&interval=weekly")

  (validate-url
   (federal-funds-rate
    :interval :monthly)
   "FEDERAL_FUNDS_RATE&interval=monthly"))

(test cpi-tests
  (validate-url
   (cpi
    :interval :monthly)
   "CPI&interval=monthly")

  (validate-url
   (cpi
    :interval :semiannual)
   "CPI&interval=semiannual"))

(test inflation-tests
  (validate-url
   (inflation)
   "INFLATION"))

(test retail-sales-tests
  (validate-url
   (retail-sales)
   "RETAIL_SALES"))

(test durables-tests
  (validate-url
   (durables)
   "DURABLES"))

(test unemployment-tests
  (validate-url
   (unemployment)
   "UNEMPLOYMENT"))

(test nonfarm-payroll-tests
  (validate-url
   (nonfarm-payroll)
   "NONFARM_PAYROLL"))

(test sma
  (validate-url
   (sma
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "SMA&symbol=AAPL&interval=1min&time_period=60&series_type=open")

  (validate-url
   (sma
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :high)
   "SMA&symbol=AAPL&interval=1min&time_period=60&series_type=high")

  (validate-url
   (sma
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :low)
   "SMA&symbol=AAPL&interval=1min&time_period=60&series_type=low")

  (validate-url
   (sma
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :close)
   "SMA&symbol=AAPL&interval=1min&time_period=60&series_type=close"))

(test ema
  (validate-url
   (ema
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "EMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test wma
  (validate-url
   (wma
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "WMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test dema
  (validate-url
   (dema
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "DEMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test tema
  (validate-url
   (tema
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "TEMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test trima
  (validate-url
   (trima
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "TRIMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test kama
  (validate-url
   (kama
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open)
   "KAMA&symbol=AAPL&interval=1min&time_period=60&series_type=open"))

(test mama
  (validate-url
   (mama
    :symbol "AAPL"
    :interval :1min
    :time-period 60
    :series-type :open
    :fastlimit 0.01
    :slowlimit 0.01)
   "MAMA&symbol=AAPL&interval=1min&time_period=60&series_type=open&fastlimit=0.01&slowlimit=0.01"))

(test vwap
  (validate-url
   (vwap
    :symbol "AAPL"
    :interval :1min)
   "VWAP&symbol=AAPL&interval=1min"))

(test t3
  (validate-url
   (t3
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "T3&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test macd
  (validate-url
   (macd
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "MACD&symbol=AAPL&interval=60min&series_type=open")

  (validate-url
   (macd
    :symbol "AAPL"
    :interval :60min
    :series-type :open
    :fastperiod 12
    :slowperiod 26
    :signalperiod 9)
   "MACD&symbol=AAPL&interval=60min&series_type=open&fastperiod=12&slowperiod=26&signalperiod=9"))

(test macdext
  (validate-url
   (macdext
    :symbol "AAPL"
    :interval :60min
    :series-type :open
    :fastperiod 12
    :slowperiod 26
    :signalperiod 9
    :fastmatype :sma
    :slowmatype :ema
    :signalmatype :wma)
   "MACDEXT&symbol=AAPL&interval=60min&series_type=open&fastperiod=12&slowperiod=26&signalperiod=9&fastmatype=0&slowmatype=1&signalmatype=2"))

(test stoch
  (validate-url
   (stoch
    :symbol "AAPL"
    :interval :60min)
   "STOCH&symbol=AAPL&interval=60min")

  (validate-url
   (stoch
    :symbol "AAPL"
    :interval :60min
    :fastkperiod 5
    :slowkperiod 3
    :slowdperiod 4
    :slowkmatype :ema
    :slowdmatype :wma)
   "STOCH&symbol=AAPL&interval=60min&fastkperiod=5&slowkperiod=3&slowdperiod=4&slowkmatype=1&slowdmatype=2"))

(test stochf
  (validate-url
   (stochf
    :symbol "AAPL"
    :interval :60min)
   "STOCHF&symbol=AAPL&interval=60min")

  (validate-url
   (stochf
    :symbol "AAPL"
    :interval :60min
    :fastkperiod 5
    :fastdperiod 3
    :fastdmatype :ema)
   "STOCHF&symbol=AAPL&interval=60min&fastkperiod=5&fastdperiod=3&fastdmatype=1"))

(test rsi
  (validate-url
   (rsi
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "RSI&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test stochrsi
  (validate-url
   (stochrsi
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "STOCHRSI&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test willr
  (validate-url
   (willr
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "WILLR&symbol=AAPL&interval=60min&time_period=60"))

(test adx
  (validate-url
   (adx
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "ADX&symbol=AAPL&interval=60min&time_period=60"))

(test adxr
  (validate-url
   (adxr
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "ADXR&symbol=AAPL&interval=60min&time_period=60"))

(test apo
  (validate-url
   (apo
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "APO&symbol=AAPL&interval=60min&series_type=open")

  (validate-url
   (apo
    :symbol "AAPL"
    :interval :60min
    :series-type :open
    :fastperiod 12
    :slowperiod 26
    :matype :ema)
   "APO&symbol=AAPL&interval=60min&series_type=open&fastperiod=12&slowperiod=26&matype=1"))

(test ppo
  (validate-url
   (ppo
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "PPO&symbol=AAPL&interval=60min&series_type=open")

  (validate-url
   (ppo
    :symbol "AAPL"
    :interval :60min
    :series-type :open
    :fastperiod 12
    :slowperiod 26
    :matype :ema)
   "PPO&symbol=AAPL&interval=60min&series_type=open&fastperiod=12&slowperiod=26&matype=1"))

(test mom
  (validate-url
   (mom
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "MOM&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test bop
  (validate-url
   (bop
    :symbol "AAPL"
    :interval :60min)
   "BOP&symbol=AAPL&interval=60min"))

(test cci
  (validate-url
   (cci
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "CCI&symbol=AAPL&interval=60min&time_period=60"))

(test cmo
  (validate-url
   (cmo
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "CMO&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test roc
  (validate-url
   (roc
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "ROC&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test rocr
  (validate-url
   (rocr
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "ROCR&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test aroon
  (validate-url
   (aroon
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "AROON&symbol=AAPL&interval=60min&time_period=60"))

(test aroonosc
  (validate-url
   (aroonosc
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "AROONOSC&symbol=AAPL&interval=60min&time_period=60"))

(test mfi
  (validate-url
   (mfi
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "MFI&symbol=AAPL&interval=60min&time_period=60"))

(test trix
  (validate-url
   (trix
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "TRIX&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test ultosc
  (validate-url
   (ultosc
    :symbol "AAPL"
    :interval :60min)
   "ULTOSC&symbol=AAPL&interval=60min")

  (validate-url
   (ultosc
    :symbol "AAPL"
    :interval :60min
    :timeperiod1 7
    :timeperiod2 14
    :timeperiod3 28)
   "ULTOSC&symbol=AAPL&interval=60min&timeperiod1=7&timeperiod2=14&timeperiod3=28"))

(test dx
  (validate-url
   (dx
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "DX&symbol=AAPL&interval=60min&time_period=60"))

(test minus-di
  (validate-url
   (minus-di
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "MINUS_DI&symbol=AAPL&interval=60min&time_period=60"))

(test plus-di
  (validate-url
   (plus-di
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "PLUS_DI&symbol=AAPL&interval=60min&time_period=60"))

(test minus-dm
  (validate-url
   (minus-dm
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "MINUS_DM&symbol=AAPL&interval=60min&time_period=60"))

(test plus-dm
  (validate-url
   (plus-dm
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "PLUS_DM&symbol=AAPL&interval=60min&time_period=60"))

(test bbands
  (validate-url
   (bbands
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "BBANDS&symbol=AAPL&interval=60min&time_period=60&series_type=open")

  (validate-url
   (bbands
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open
    :nbdevup 2
    :nbdevdn 2
    :matype :ema)
   "BBANDS&symbol=AAPL&interval=60min&time_period=60&series_type=open&nbdevup=2&nbdevdn=2&matype=1"))

(test midpoint
  (validate-url
   (midpoint
    :symbol "AAPL"
    :interval :60min
    :time-period 60
    :series-type :open)
   "MIDPOINT&symbol=AAPL&interval=60min&time_period=60&series_type=open"))

(test midprice
  (validate-url
   (midprice
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "MIDPRICE&symbol=AAPL&interval=60min&time_period=60"))

(test sar
  (validate-url
   (sar
    :symbol "AAPL"
    :interval :60min)
   "SAR&symbol=AAPL&interval=60min")

  (validate-url
   (sar
    :symbol "AAPL"
    :interval :60min
    :acceleration 0.01
    :maximum 0.20)
   "SAR&symbol=AAPL&interval=60min&acceleration=0.01&maximum=0.2"))

(test trange
  (validate-url
   (trange
    :symbol "AAPL"
    :interval :60min)
   "TRANGE&symbol=AAPL&interval=60min"))

(test atr
  (validate-url
   (atr
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "ATR&symbol=AAPL&interval=60min&time_period=60"))

(test natr
  (validate-url
   (natr
    :symbol "AAPL"
    :interval :60min
    :time-period 60)
   "NATR&symbol=AAPL&interval=60min&time_period=60"))

(test ad
  (validate-url
   (ad
    :symbol "AAPL"
    :interval :60min)
   "AD&symbol=AAPL&interval=60min"))

(test adosc
  (validate-url
   (adosc
    :symbol "AAPL"
    :interval :60min)
   "ADOSC&symbol=AAPL&interval=60min")

  (validate-url
   (adosc
    :symbol "AAPL"
    :interval :60min
    :fastperiod 3
    :slowperiod 10)
   "ADOSC&symbol=AAPL&interval=60min&fastperiod=3&slowperiod=10"))

(test obv
  (validate-url
   (obv
    :symbol "AAPL"
    :interval :60min)
   "OBV&symbol=AAPL&interval=60min"))

(test ht-trendline
  (validate-url
   (ht-trendline
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_TRENDLINE&symbol=AAPL&interval=60min&series_type=open"))

(test ht-sine
  (validate-url
   (ht-sine
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_SINE&symbol=AAPL&interval=60min&series_type=open"))

(test ht-trendmode
  (validate-url
   (ht-trendmode
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_TRENDMODE&symbol=AAPL&interval=60min&series_type=open"))

(test ht-dcperiod
  (validate-url
   (ht-dcperiod
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_DCPERIOD&symbol=AAPL&interval=60min&series_type=open"))

(test ht-dcphase
  (validate-url
   (ht-dcphase
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_DCPHASE&symbol=AAPL&interval=60min&series_type=open"))

(test ht-phasor
  (validate-url
   (ht-phasor
    :symbol "AAPL"
    :interval :60min
    :series-type :open)
   "HT_PHASOR&symbol=AAPL&interval=60min&series_type=open"))
