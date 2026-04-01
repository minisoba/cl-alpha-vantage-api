(in-package :cl-alpha-vantage-api)

(defun %extract-function-name (query)
  "Extract the Alpha Vantage function name from a QUERY URL string."
  (intern
   (string-upcase
    (cl-change-case:param-case 
     (cl-ppcre:regex-replace
      "&.+$"
      (cl-ppcre:regex-replace "^.+function=" query "")
      "")))
   #.*package*))

(defun %rename-hash-key (old-key new-key hash-table)
  "Rename OLD-KEY to NEW-KEY in HASH-TABLE, preserving the value."
  (alexandria:when-let (val (gethash old-key hash-table))
    (setf (gethash new-key hash-table) val)
    (remhash old-key hash-table)))

(defun %process-time-series (hash-table)
  "Process HASH-TABLE from a commodities/economic indicator response into a list of TIME-SERIES objects."
  (let (series)
    (dolist (row (gethash "data" hash-table) (nreverse series))
      (%rename-hash-key "date" "timestamp" row)
      (push (make-time-series row) series))))

(defun %process-time-series-ohcl (hash-table query &optional (key "Time Series") (fn #'make-time-series-ohcl))
  "Process HASH-TABLE from a stock time series response into a list of OHCL objects using FN."
  (let* ((name (%extract-function-name query))
         (interval (cl-change-case:pascal-case
                    (car (last (cl-ppcre:split "-" (string name))))))
         (full-key (format nil "~a (~a)" key interval))
         (data (gethash full-key hash-table))
         (series '()))
    (loop for ts-key being the hash-keys in data do
      (let ((row (gethash ts-key data)))
        (setf (gethash "timestamp" row) ts-key)
        (%rename-hash-key "1. open" "open-price" row)
        (%rename-hash-key "2. high" "high-price" row)
        (%rename-hash-key "3. low" "low-price" row)
        (%rename-hash-key "4. close" "close-price" row)
        (when (gethash "5. volume" row)
          (%rename-hash-key "5. volume" "volume" row))
        (push (funcall fn row) series)))
    series))

(defun %process-fx-time-series-ohcl (hash-table query)
  "Process HASH-TABLE from an FX time series response into a list of FX-TIME-SERIES-OHCL objects."
  (%process-time-series-ohcl hash-table query "Time Series FX" #'make-fx-time-series-ohcl))

(defun %process-ta-time-series (hash-table query)
  "Process HASH-TABLE from a technical indicator response into a list of TA-TIME-SERIES objects."
  (let* ((name (cl-ppcre:regex-replace
                "&.+$"
                (cl-ppcre:regex-replace "^.+function=" query "")
                ""))
         (full-key (format nil "Technical Analysis: ~a" name))
         (data (gethash full-key hash-table))
         (series '()))
    (loop for ts-key being the hash-keys in data do
      (let ((row (gethash ts-key data)))
        (setf (gethash "ta-values" row)
              (loop for k being the hash-keys in row
                    collect (list (intern k "KEYWORD")
                                  (%parse-float (gethash k row)))))
        (setf (gethash "timestamp" row) ts-key)
        (push (make-ta-time-series row) series)))
    series))

(defun %process-fundamental-time-series (hash-table query)
  "Process HASH-TABLE from a fundamental data response into a list of fundamental objects."
  (let* ((name (%extract-function-name query))
         (fn-name (intern (string-upcase (format nil "MAKE-~a" name))))
         (series '()))
    (loop for key being the hash-keys in hash-table
          unless (cl-ppcre:scan key "symbol") do
            (dolist (v (gethash key hash-table))
              (setf (gethash "report-period" v) (cl-change-case:param-case key))
              (push (funcall fn-name v) series)))
    series))

(defun %process-crypto-time-series-ohcl (hash-table query)
  "Process HASH-TABLE from a crypto time series response into a list of CRYPTO-TIME-SERIES-OHCL objects."
  (flet ((%hash-key (str ccy)
           (format nil "~a (~a)" str ccy)))
    (let* ((name (%extract-function-name query))
           (interval (cl-change-case:pascal-case
                      (third (cl-ppcre:split "-" (string name)))))
           (full-key (format nil "Time Series (Digital Currency ~a)" interval))
           (ccy (subseq (cl-ppcre:regex-replace ".+market=" query "") 0 3))
           (data (gethash full-key hash-table))
           (series '()))
      (loop for ts-key being the hash-keys in data do
        (let ((row (gethash ts-key data)))
          (setf (gethash "timestamp" row) ts-key)
          (%rename-hash-key (%hash-key "1a. open" ccy) "open-price" row)
          (%rename-hash-key (%hash-key "2a. high" ccy) "high-price" row)
          (%rename-hash-key (%hash-key "3a. low" ccy) "low-price" row)
          (%rename-hash-key (%hash-key "4a. close" ccy) "close-price" row)
          (%rename-hash-key "1b. open (USD)" "open-price-usd" row)
          (%rename-hash-key "2b. high (USD)" "high-price-usd" row)
          (%rename-hash-key "3b. low (USD)" "low-price-usd" row)
          (%rename-hash-key "4b. close (USD)" "close-price-usd" row)
          (%rename-hash-key "5. volume" "volume" row)
          (%rename-hash-key "6. market cap (USD)" "market-cap-usd" row)
          (push (make-crypto-time-series-ohcl row) series)))
      series)))

(defun %process-global-quote (hash-table)
  "Process HASH-TABLE from a Global Quote response into a QUOTE-SNAPSHOT object."
  (setf hash-table (gethash "Global Quote" hash-table))
  (%rename-hash-key "01. symbol" "ticker" hash-table)
  (%rename-hash-key "02. open" "open-price" hash-table)
  (%rename-hash-key "03. high" "high-price" hash-table)
  (%rename-hash-key "04. low"  "low-price" hash-table)
  (%rename-hash-key "05. price" "price" hash-table)
  (%rename-hash-key "06. volume" "volume" hash-table)
  (%rename-hash-key "07. latest trading day" "timestamp" hash-table)
  (%rename-hash-key "08. previous close" "previous-close-price" hash-table)
  (%rename-hash-key "09. change" "change" hash-table)
  (%rename-hash-key "10. change percent" "change-percent" hash-table)
  (make-quote-snapshot hash-table))

(defun %process-fx-real-time (hash-table)
  "Process HASH-TABLE from a Realtime Currency Exchange Rate response into an FX-QUOTE-SNAPSHOT object."
  (setf hash-table (gethash "Realtime Currency Exchange Rate" hash-table))
  (%rename-hash-key "1. From_Currency Code" "from-ccy-code" hash-table)
  (%rename-hash-key "2. From_Currency Name" "from-ccy-name" hash-table)
  (%rename-hash-key "3. To_Currency Code" "to-ccy-code" hash-table)
  (%rename-hash-key "4. To_Currency Name" "to-ccy-name" hash-table)
  (%rename-hash-key "5. Exchange Rate" "exchange-rate" hash-table)
  (%rename-hash-key "6. Last Refreshed" "timestamp" hash-table)
  (%rename-hash-key "7. Time Zone" "timezone" hash-table)
  (%rename-hash-key "8. Bid Price" "bid-price" hash-table)
  (%rename-hash-key "9. Ask Price" "ask-price" hash-table)
  (make-fx-quote-snapshot hash-table))

(defun %process-symbol-search (data)
  "Process DATA from a Symbol Search response into a list of SYMBOL-SEARCH objects."
  (let (series)
    (dolist (row (gethash "bestMatches" data) (nreverse series))
      (%rename-hash-key "1. symbol" "ticker" row)
      (%rename-hash-key "2. name" "name" row)
      (%rename-hash-key "3. type" "type" row)
      (%rename-hash-key "4. region" "region" row)
      (%rename-hash-key "5. marketOpen" "market-open" row)
      (%rename-hash-key "6. marketClose" "market-close" row)
      (%rename-hash-key "7. timezone" "timezone" row)
      (%rename-hash-key "8. currency" "ccy" row)
      (%rename-hash-key "9. matchScore" "match-score" row)
      (push (make-symbol-search row) series))))

(defun %process-market-status (data)
  "Process DATA from a Market Status response. (Not yet implemented.)"
  (declare (ignore data))
  )

(defun %process-overview (hash-table)
  "Process HASH-TABLE from an Overview response into an OVERVIEW object."
  (%rename-hash-key "Symbol" "ticker" hash-table)
  (%rename-hash-key "DilutedEPSTTM" "diluted-eps-ttm" hash-table)
  (make-overview hash-table))

(defun %process-download (data)
  "Process DATA from a CSV download response. (Not yet implemented.)"
  (declare (ignore data))
  )

(defun %process-data (data query)
  "Dispatch DATA processing based on the end-point group derived from QUERY."
  (let* ((name (%extract-function-name query))
         (group (%find-end-point-group name)))
    (case group
      (:global-quote
       (%process-global-quote data))
      (:fx-real-time
       (%process-fx-real-time data))
      (:time-series
       (%process-time-series data))
      (:time-series-ohcl
       (%process-time-series-ohcl data query))
      (:fx-time-series-ohcl
       (%process-fx-time-series-ohcl data query))
      (:crypto-time-series-ohcl
       (%process-crypto-time-series-ohcl data query))
      (:ta-time-series
       (%process-ta-time-series data query))
      (:market-status
       (%process-market-status data))
      (:overview
       (%process-overview data))
      (:fundamental-time-series
       (%process-fundamental-time-series data query))
      (:symbol-search
       (%process-symbol-search data))
      (:download
       (%process-download data))
      (otherwise
       (error 'end-point-group-error :argument query)))))

(defun %get-data (query)
  "Send an HTTP request for QUERY and process the response into domain objects."
  (alexandria:when-let (data (http-request query))
    (let ((err-msg (gethash "Error Message" data)))
      (cond (err-msg
             (error 'invalid-api-call :argument err-msg))
            (t
             (%process-data data query))))))
