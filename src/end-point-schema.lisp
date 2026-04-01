(in-package :cl-alpha-vantage-api)

(defparameter +interval-0-types+
  '(:1min :5min :15min :30min :60min))

(defparameter +interval-1-types+
  '(:1min :5min :15min :30min :60min :daily :weekly :monthly))

(defparameter +interval-2-types+
  '(:daily :weekly :monthly))

(defparameter +interval-3-types+
  '(:monthly :quarterly :annual))

(defparameter +interval-4-types+
  '(:quarterly :annual))

(defparameter +interval-5-types+
  '(:monthly :semiannual))

(defparameter +treasury-maturity-types+
  '(:3month :2year :5year :7year :10year :30year))

(defparameter +boolean-types+
  '(:true :false))

(defparameter +output-size-types+
  '(:compact :full))

(defparameter +listing-status-types+
  '(:active :delisted))

(defparameter +earnings-horizon-types+
  '(:3month :6month :12month))

(defparameter +sort-types+
  '(:latest :earliest :relevance))

(defparameter +series-types+
  '(:close :open :high :low))

(defparameter +ma-types+
  '(:sma :ema :wma :dema :tema :trima :t3 :kama :mama))

(defun convert-ma-type (x)
  "Return the integer code for moving average type keyword X."
  (or (position x +ma-types+)
      (error "Unknown MA type: ~a" x)))

(defparameter +end-points+
  `(((time-series-intraday
      :time-series-ohcl)
     . ((symbol     :required :string)
        (interval   :required :interval-0-types)
        (adjusted   :optional :boolean-types)
        (outputsize :optional :output-size-types)))
    ((time-series-intraday-extended
      :time-series-ohcl)
     . ())
    ((time-series-daily
      :time-series-ohcl)
     . ((symbol     :required :string)
        (outputsize :optional :output-size-types)))
    ((time-series-daily-adjusted
      :time-series-ohcl)
     . ((symbol     :required :string)
        (outputsize :optional :output-size-types)))
    ((time-series-weekly
      :time-series-ohcl)
     . ((symbol     :required :string)))
    ((time-series-weekly-adjusted
      :time-series-ohcl)
     . ((symbol     :required :string)))
    ((time-series-monthly
      :time-series-ohcl)
     . ((symbol     :required :string)))
    ((time-series-monthly-adjusted
      :time-series-ohcl)
     . ((symbol     :required :string)))
    ((global-quote
      :global-quote)
     . ((symbol     :required :string)))
    ((symbol-search
      :symbol-search)
     . ((keywords   :required :string)))
    ((market-status
      :market-status)
     . ())

    ((overview
      :overview)
     . ((symbol    :required :string)))
    ((income-statement
      :fundamental-time-series)
     . ((symbol    :required :string)))
    ((balance-sheet
      :fundamental-time-series)
     . ((symbol    :required :string)))
    ((cash-flow
      :fundamental-time-series)
     . ((symbol    :required :string)))
    ((earnings
      :fundamental-time-series)
     . ((symbol    :required :string)))

    ((currency-exchange-rate
      :fx-real-time)
     . ((from-currency :required :iso-ccy)
        (to-currency   :required :iso-ccy)))
    ((fx-intraday
      :fx-time-series-ohcl)
     . ((from-symbol   :required :iso-ccy)
        (to-symbol     :required :iso-ccy)
        (interval      :required :interval-0-types)
        (outputsize    :optional :output-size-types)))
    ((fx-daily
      :fx-time-series-ohcl)
     . ((from-symbol   :required :iso-ccy)
        (to-symbol     :required :iso-ccy)
        (outputsize    :optional :output-size-types)))
    ((fx-weekly
      :fx-time-series-ohcl)
     . ((from-symbol   :required :iso-ccy)
        (to-symbol     :required :iso-ccy)))
    ((fx-monthly
      :fx-time-series-ohcl)
     . ((from-symbol   :required :iso-ccy)
        (to-symbol     :required :iso-ccy)))

    ((crypto-intraday
      :crypto-time-series-ohcl)
     . ((symbol        :required :iso-ccy)
        (market        :required :iso-ccy)
        (interval      :required :interval-0-types)
        (outputsize    :optional :output-size-types)))
    ((digital-currency-daily
      :crypto-time-series-ohcl)
     . ((symbol        :required :iso-ccy)
        (market        :required :iso-ccy)))
    ((digital-currency-weekly
      :crypto-time-series-ohcl)
     . ((symbol        :required :iso-ccy)
        (market        :required :iso-ccy)))
    ((digital-currency-monthly
      :crypto-time-series-ohcl)
     . ((symbol        :required :iso-ccy)
        (market        :required :iso-ccy)))

    ((wti
      :time-series)
     . ((interval :optional :interval-2-types)))
    ((brent
      :time-series)
     . ((interval :optional :interval-2-types)))
    ((natural-gas
      :time-series)
     . ((interval :optional :interval-2-types)))
    ((gold-silver-history
      :time-series)
     . ((symbol   :required :string)
        (interval :optional :interval-2-types)))
    ((copper
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((aluminum
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((wheat
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((corn
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((cotton
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((sugar
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((coffee
      :time-series)
     . ((interval :optional :interval-3-types)))
    ((all-commodities
      :time-series)
     . ((interval :optional :interval-3-types)))

    ((real-gdp
      :time-series)
     . ((interval :optional :interval-4-types)))
    ((real-gdp-per-capita
      :time-series)
     . ())
    ((treasury-yield
      :time-series)
     . ((interval :optional :interval-2-types)
        (maturity :optional :treasury-maturity-types)))
    ((federal-funds-rate
      :time-series)
     . ((interval :optional :interval-2-types)))
    ((cpi
      :time-series)
     . ((interval :optional :interval-5-types)))
    ((inflation
      :time-series)
     . ())
    ((retail-sales
      :time-series)
     . ())
    ((durables
      :time-series)
     . ())
    ((unemployment
      :time-series)
     . ())
    ((nonfarm-payroll
      :time-series)
     . ())

    ((sma
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((ema
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((wma
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((dema
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((tema
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((trima
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((kama
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((mama
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)
        (fastlimit     :optional :float)
        (slowlimit     :optional :float)))
    ((vwap
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-0-types)))
    ((t3
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((macd
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)
        (fastperiod    :optional :integer)
        (slowperiod    :optional :integer)
        (signalperiod  :optional :integer)))
    ((macdext
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)
        (fastperiod    :optional :integer)
        (slowperiod    :optional :integer)
        (signalperiod  :optional :integer)
        (fastmatype    :optional :ma-types)
        (slowmatype    :optional :ma-types)
        (signalmatype  :optional :ma-types)))
    ((stoch
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (fastkperiod   :optional :integer)
        (slowkperiod   :optional :integer)
        (slowdperiod   :optional :integer)
        (slowkmatype   :optional :ma-types)
        (slowdmatype   :optional :ma-types)))
    ((stochf
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (fastkperiod   :optional :integer)
        (fastdperiod   :optional :integer)
        (fastdmatype   :optional :ma-types)))
    ((rsi
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((stochrsi
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)
        (fastkperiod   :optional :integer)
        (fastdperiod   :optional :integer)
        (fastdmatype   :optional :ma-types)))
    ((willr
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((adx
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((adxr
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((apo
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)
        (fastperiod    :optional :integer)
        (slowperiod    :optional :integer)
        (matype        :optional :ma-types)))
    ((ppo
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)
        (fastperiod    :optional :integer)
        (slowperiod    :optional :integer)
        (matype        :optional :ma-types)))
    ((mom
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((bop
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)))
    ((cci
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((cmo
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((roc
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((rocr
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((aroon
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((aroonosc
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((mfi
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((trix
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((ultosc
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (timeperiod1   :optional :integer)
        (timeperiod2   :optional :integer)
        (timeperiod3   :optional :integer)))
    ((dx
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((minus-di
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((plus-di
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((minus-dm
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((plus-dm
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((bbands
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)
        (nbdevup       :optional :integer)
        (nbdevdn       :optional :integer)
        (matype        :optional :ma-types)))
    ((midpoint
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)
        (series-type   :required :series-types)))
    ((midprice
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((sar
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (acceleration  :optional :float)
        (maximum       :optional :float)))
    ((trange
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)))
    ((atr
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((natr
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (time-period   :required :integer)))
    ((ad
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)))
    ((adosc
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (fastperiod    :optional :integer)
        (slowperiod    :optional :integer)))
    ((obv
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)))
    ((ht-trendline
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))
    ((ht-sine
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))
    ((ht-trendmode
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))
    ((ht-dcperiod
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))
    ((ht-dcphase
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))
    ((ht-phasor
      :ta-time-series)
     . ((symbol        :required :string)
        (interval      :required :interval-1-types)
        (series-type   :required :series-types)))))
