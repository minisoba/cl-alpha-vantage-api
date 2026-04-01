(in-package :cl-user)

(defpackage :cl-alpha-vantage-api
  (:use :cl)
  (:nicknames :alpha-vantage)
  (:export
   #:*api-token*
   #:set-api-token
   #:*end-point-table*
   #:*http-headers*
   #:*http-status-code*
   #:*http-reason-phrase*

   #:+query-url-base+
   #:+interval-0-types+
   #:+interval-1-types+
   #:+interval-2-types+
   #:+interval-3-types+
   #:+interval-4-types+
   #:+interval-5-types+
   #:+treasury-maturity-types+
   #:+boolean-types+
   #:+output-size-types+
   #:+listing-status-types+
   #:+earnings-horizon-types+
   #:+sort-types+
   #:+series-types+
   #:+ma-types+

   #:data-type-error
   #:http-request-error
   #:interval-0-types-error
   #:interval-1-types-error
   #:interval-2-types-error
   #:interval-3-types-error
   #:interval-4-types-error
   #:interval-5-types-error
   #:treasury-maturity-types-error
   #:boolean-types-error
   #:output-size-types-error
   #:listing-status-types-error
   #:earnings-horizon-types-error
   #:news-topics-error
   #:sort-types-error
   #:series-types-error
   #:ma-types-error

   ;; overview
   #:overview
   #:ticker-of
   #:asset-type-of
   #:name-of
   #:description-of
   #:cik-of
   #:exchange-of
   #:currency-of
   #:country-of
   #:sector-of
   #:industry-of
   #:address-of
   #:fiscal-year-end-of
   #:latest-quarter-of
   #:market-capitalization-of
   #:ebitda-of
   #:pe-ratio-of
   #:peg-ratio-of
   #:book-value-of
   #:dividend-per-share-of
   #:dividend-yield-of
   #:eps-of
   #:revenue-per-share-ttm-of
   #:profit-margin-of
   #:operating-margin-ttm-of
   #:return-on-assets-ttm-of
   #:return-on-equity-ttm-of
   #:revenue-ttm-of
   #:gross-profit-ttm-of
   #:diluted-eps-ttm-of
   #:quarterly-earnings-growth-yoy-of
   #:quarterly-revenue-growth-yoy-of
   #:analyst-target-price-of
   #:trailing-pe-of
   #:forward-pe-of
   #:price-to-sales-ratio-ttm-of
   #:price-to-book-ratio-of
   #:ev-to-revenue-of
   #:ev-to-ebitda-of
   #:beta-of
   #:52-week-high-of
   #:52-week-low-of
   #:50-day-moving-average-of
   #:200-day-moving-average-of
   #:shares-outstanding-of
   #:dividend-date-of
   #:ex-dividend-date-of

   ;; fundamental time-series common
   #:report-period-of
   #:fiscal-date-ending-of
   #:reported-currency-of

   ;; income-statement
   #:gross-profit-of
   #:total-revenue-of
   #:cost-of-revenue-of
   #:cost-of-goods-and-services-sold-of
   #:operating-income-of
   #:selling-general-and-administrative-of
   #:research-and-development-of
   #:operating-expenses-of
   #:investment-income-net-of
   #:net-interest-income-of
   #:interest-income-of
   #:interest-expense-of
   #:non-interest-income-of
   #:other-non-operating-income-of
   #:depreciation-of
   #:depreciation-and-amortization-of
   #:income-before-tax-of
   #:income-tax-expense-of
   #:interest-and-debt-expense-of
   #:net-income-from-continuing-operations-of
   #:comprehensive-income-net-of-tax-of
   #:ebit-of
   #:ebitda-of
   #:net-income-of

   ;; balance-sheet
   #:total-assets-of
   #:total-current-assets-of
   #:cash-and-cash-equivalents-at-carrying-value-of
   #:cash-and-short-term-investments-of
   #:inventory-of
   #:current-net-receivables-of
   #:total-non-current-assets-of
   #:property-plant-equipment-of
   #:accumulated-depreciation-amortization-ppe-of
   #:intangible-assets-of
   #:intangible-assets-excluding-goodwill-of
   #:goodwill-of
   #:investments-of
   #:long-term-investments-of
   #:short-term-investments-of
   #:other-current-assets-of
   #:other-non-current-assets-of
   #:total-liabilities-of
   #:total-current-liabilities-of
   #:current-accounts-payable-of
   #:deferred-revenue-of
   #:current-debt-of
   #:short-term-debt-of
   #:total-non-current-liabilities-of
   #:capital-lease-obligations-of
   #:long-term-debt-of
   #:current-long-term-debt-of
   #:long-term-debt-noncurrent-of
   #:short-long-term-debt-total-of
   #:other-current-liabilities-of
   #:other-non-current-liabilities-of
   #:total-shareholder-equity-of
   #:treasury-stock-of
   #:retained-earnings-of
   #:common-stock-of
   #:common-stock-shares-outstanding-of

   ;; cash-flow
   #:operating-cashflow-of
   #:payments-for-operating-activities-of
   #:proceeds-from-operating-activities-of
   #:change-in-operating-liabilities-of
   #:change-in-operating-assets-of
   #:depreciation-depletion-and-amortization-of
   #:capital-expenditures-of
   #:change-in-receivables-of
   #:change-in-inventory-of
   #:profit-loss-of
   #:cashflow-from-investment-of
   #:cashflow-from-financing-of
   #:proceeds-from-repayments-of-short-term-debt-of
   #:payments-for-repurchase-of-common-stock-of
   #:payments-for-repurchase-of-equity-of
   #:payments-for-repurchase-of-preferred-stock-of
   #:dividend-payout-of
   #:dividend-payout-common-stock-of
   #:dividend-payout-preferred-stock-of
   #:proceeds-from-issuance-of-common-stock-of
   #:proceeds-from-issuance-of-long-term-debt-and-capital-securities-net-of
   #:proceeds-from-issuance-of-preferred-stock-of
   #:proceeds-from-repurchase-of-equity-of
   #:proceeds-from-sale-of-treasury-stock-of
   #:change-in-cash-and-cash-equivalents-of
   #:change-in-exchange-rate-of
   #:net-income-of

   ;; earnings
   #:reported-eps-of

   #:make-overview
   #:make-income-statement
   #:make-balance-sheet
   #:make-cash-flow
   #:make-earnings

   ;; time-series
   #:timestamp-of
   #:value-of
   #:ta-values-of

   ;; time-series-ohcl / quote-snapshot common
   #:open-price-of
   #:high-price-of
   #:low-price-of
   #:close-price-of
   #:volume-of
   #:price-of
   #:previous-close-price-of
   #:change-of
   #:change-percent-of

   ;; crypto-time-series-ohcl
   #:open-price-usd-of
   #:high-price-usd-of
   #:low-price-usd-of
   #:close-price-usd-of
   #:market-cap-usd-of

   ;; fx-quote-snapshot
   #:from-ccy-code-of
   #:from-ccy-name-of
   #:to-ccy-code-of
   #:to-ccy-name-of
   #:exchange-rate-of
   #:bid-price-of
   #:ask-price-of
   #:timezone-of

   ;; symbol-search
   #:instrument-type-of
   #:region-of
   #:market-open-of
   #:market-close-of
   #:ccy-of
   #:match-score-of

   #:get-overview
   #:do-time-series
   #:get-time-series
   #:get-income-statement-series
   #:get-balance-sheet-series
   #:get-cash-flow-series
   #:get-earnings-series

   ;; parquet
   #:save-to-parquet

   ;; core stock api
   #:time-series-intraday
   #:time-series-daily
   #:time-series-daily-adjusted
   #:time-series-weekly
   #:time-series-weekly-adjusted
   #:time-series-monthly
   #:time-series-monthly-adjusted
   #:global-quote
   #:symbol-search
   #:market-status

   ;; fundamental data
   #:overview
   #:income-statement
   #:balance-sheet
   #:cash-flow
   #:earnings
   #:listing-status
   #:earnings-calendar
   #:ipo-calendar

   ;; forex
   #:currency-exchange-rate
   #:fx-intraday
   #:fx-daily
   #:fx-weekly
   #:fx-monthly

   ;; crypto
   #:crypto-intraday
   #:crypto-daily
   #:crypto-weekly
   #:crypto-monthly
   #:digital-currency-daily
   #:digital-currency-weekly
   #:digital-currency-monthly

   ;; commodities
   #:wti
   #:brent
   #:natural-gas
   #:copper
   #:aluminum
   #:wheat
   #:corn
   #:cotton
   #:sugar
   #:coffee
   #:all-commodities

   ;; economic indicators
   #:real-gdp
   #:real-gdp-per-capita
   #:treasury-yield
   #:federal-funds-rate
   #:cpi
   #:inflation
   #:retail-sales
   #:durables
   #:unemployment
   #:nonfarm-payroll

   ;; technical indicators
   #:sma
   #:ema
   #:wma
   #:dema
   #:tema
   #:trima
   #:kama
   #:mama
   #:vwap
   #:t3
   #:macd
   #:macdext
   #:stoch
   #:stochf
   #:rsi
   #:stochrsi
   #:willr
   #:adx
   #:adxr
   #:apo
   #:ppo
   #:mom
   #:bop
   #:cci
   #:cmo
   #:roc
   #:rocr
   #:aroon
   #:aroonosc
   #:mfi
   #:trix
   #:ultosc
   #:dx
   #:minus-di
   #:plus-di
   #:minus-dm
   #:plus-dm
   #:bbands
   #:midpoint
   #:midprice
   #:sar
   #:trange
   #:atr
   #:natr
   #:ad
   #:adosc
   #:obv
   #:ht-trendline
   #:ht-sine
   #:ht-trendmode
   #:ht-dcperiod
   #:ht-dcphase
   #:ht-phasor))
