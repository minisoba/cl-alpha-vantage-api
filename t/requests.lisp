(in-package :alpha-vantage.test)

(def-suite request-tests :in alpha-vantage-tests
  :description "Request tests")

(in-suite request-tests)

;;; ---- Helpers ----

(defun live-key-p ()
  "Return T if *api-token* is set to a non-demo API key."
  (and *api-token*
       (not (string= *api-token* "demo"))))

(defvar *request-test-delay* 13
  "Seconds to sleep between API calls to respect Alpha Vantage rate limits.")

(defun throttle ()
  "Sleep to respect Alpha Vantage rate limits (5 requests/minute for free tier)."
  (sleep *request-test-delay*))

;;; ---- Demo tests (work with apikey=demo) ----
;;; One representative endpoint per response-processing group.
;;; Demo endpoints require hardcoded parameters (e.g. symbol=IBM).

(test stock-daily-ohcl
  "Fetch TIME_SERIES_DAILY for IBM and verify OHCL structure."
  (unless *api-token* (setf *api-token* "demo"))
  (let ((result (get-time-series (time-series-daily :symbol "IBM"))))
    (is-true (listp result))
    (is-true (plusp (length result)))
    (let ((item (first result)))
      (is (typep item 'cl-alpha-vantage-api::time-series-ohcl))
      (is (typep (timestamp-of item) 'local-time:timestamp))
      (is (numberp (open-price-of item)))
      (is (numberp (high-price-of item)))
      (is (numberp (low-price-of item)))
      (is (numberp (close-price-of item))))))

(test global-quote-snapshot
  "Fetch GLOBAL_QUOTE for IBM and verify quote-snapshot structure."
  (throttle)
  (let ((result (cl-alpha-vantage-api::%get-data
                 (global-quote :symbol "IBM"))))
    (is (typep result 'cl-alpha-vantage-api::quote-snapshot))
    (is (stringp (ticker-of result)))
    (is (numberp (open-price-of result)))
    (is (numberp (price-of result)))
    (is (typep (timestamp-of result) 'local-time:timestamp))))

(test symbol-search-results
  "Search for 'tesco' and verify symbol-search list."
  (throttle)
  (let ((result (cl-alpha-vantage-api::%get-data
                 (symbol-search :keywords "tesco"))))
    (is-true (listp result))
    (is-true (plusp (length result)))
    (let ((item (first result)))
      (is (typep item 'cl-alpha-vantage-api::symbol-search))
      (is (stringp (ticker-of item)))
      (is (stringp (name-of item)))
      (is (stringp (region-of item))))))

(test commodity-time-series
  "Fetch WTI crude oil monthly data and verify time-series structure."
  (throttle)
  (let ((result (get-time-series (wti :interval :monthly))))
    (is-true (listp result))
    (is-true (plusp (length result)))
    (let ((item (first result)))
      (is (typep item 'cl-alpha-vantage-api::time-series))
      (is (typep (timestamp-of item) 'local-time:timestamp))
      (is (numberp (value-of item))))))

(test ta-sma-time-series
  "Fetch SMA for IBM and verify ta-time-series structure."
  (throttle)
  (let ((result (get-time-series
                 (sma :symbol "IBM"
                      :interval :weekly
                      :time-period 10
                      :series-type :open))))
    (is-true (listp result))
    (is-true (plusp (length result)))
    (let ((item (first result)))
      (is (typep item 'cl-alpha-vantage-api::ta-time-series))
      (is (typep (timestamp-of item) 'local-time:timestamp))
      (is (listp (ta-values-of item)))
      (is-true (plusp (length (ta-values-of item)))))))

;;; ---- Live tests (require a non-demo API key) ----
;;; Skipped when *api-token* is "demo".
;;; Set your own key via (set-api-token "YOUR_KEY") before running.

(test live-overview
  "Fetch OVERVIEW for IBM and verify overview object."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-overview "IBM")))
          (is (typep result 'cl-alpha-vantage-api::overview))
          (is (stringp (ticker-of result)))
          (is (stringp (name-of result)))
          (is (numberp (market-capitalization-of result)))
          (is (numberp (pe-ratio-of result)))))))

(test live-income-statement
  "Fetch INCOME_STATEMENT for IBM and verify fundamental series."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-income-statement-series "IBM")))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::income-statement))
            (is (typep (fiscal-date-ending-of item) 'local-time:timestamp))
            (is (stringp (reported-currency-of item)))
            (is (numberp (total-revenue-of item))))))))

(test live-balance-sheet
  "Fetch BALANCE_SHEET for IBM and verify fundamental series."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-balance-sheet-series "IBM")))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::balance-sheet))
            (is (typep (fiscal-date-ending-of item) 'local-time:timestamp))
            (is (numberp (total-assets-of item))))))))

(test live-cash-flow
  "Fetch CASH_FLOW for IBM and verify fundamental series."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-cash-flow-series "IBM")))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::cash-flow))
            (is (typep (fiscal-date-ending-of item) 'local-time:timestamp))
            (is (numberp (operating-cashflow-of item))))))))

(test live-earnings
  "Fetch EARNINGS for IBM and verify fundamental series."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-earnings-series "IBM")))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::earnings))
            (is (typep (fiscal-date-ending-of item) 'local-time:timestamp))
            (is (numberp (reported-eps-of item))))))))

(test live-fx-daily
  "Fetch FX_DAILY for EUR/USD and verify fx-time-series-ohcl structure."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-time-series
                       (fx-daily :from-symbol "EUR" :to-symbol "USD"))))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::fx-time-series-ohcl))
            (is (typep (timestamp-of item) 'local-time:timestamp))
            (is (numberp (open-price-of item)))
            (is (numberp (close-price-of item))))))))

(test live-fx-exchange-rate
  "Fetch CURRENCY_EXCHANGE_RATE for USD/JPY and verify fx-quote-snapshot."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (cl-alpha-vantage-api::%get-data
                       (currency-exchange-rate
                        :from-currency "USD"
                        :to-currency "JPY"))))
          (is (typep result 'cl-alpha-vantage-api::fx-quote-snapshot))
          (is (stringp (from-ccy-code-of result)))
          (is (stringp (to-ccy-code-of result)))
          (is (numberp (exchange-rate-of result)))))))

(test live-crypto-daily
  "Fetch DIGITAL_CURRENCY_DAILY for BTC/EUR and verify crypto OHCL structure."
  (if (not (live-key-p))
      (skip "Requires a live API key (set *api-token*)")
      (progn
        (throttle)
        (let ((result (get-time-series
                       (digital-currency-daily :symbol "BTC" :market "EUR"))))
          (is-true (listp result))
          (is-true (plusp (length result)))
          (let ((item (first result)))
            (is (typep item 'cl-alpha-vantage-api::crypto-time-series-ohcl))
            (is (typep (timestamp-of item) 'local-time:timestamp))
            (is (numberp (open-price-of item)))
            (is (numberp (open-price-usd-of item)))
            (is (numberp (close-price-of item))))))))