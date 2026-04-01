(in-package :cl-alpha-vantage-api)

(defun get-time-series (query &optional (date-time-column 'timestamp-of))
  "Fetch and return a time series sorted by DATE-TIME-COLUMN from the Alpha Vantage QUERY URL."
  (sort (%get-data query) #'local-time:timestamp< :key date-time-column))

(defmacro do-time-series ((var query date-time-column) &body body)
  "Iterate over each element of a time series, binding each to VAR."
  `(loop for ,var in (get-time-series ,query ,date-time-column) do
         ,@body))

(defun get-overview (symbol)
  "Return an OVERVIEW of SYMBOL."
  (%get-data (overview :symbol symbol)))

(defun get-income-statement-series (symbol)
  "Return a time series of INCOME-STATEMENT of SYMBOL."
  (get-time-series (income-statement :symbol symbol) 'fiscal-date-ending-of))

(defun get-balance-sheet-series (symbol)
  "Return a time series of BALANCE-SHEET of SYMBOL."
  (get-time-series (balance-sheet :symbol symbol) 'fiscal-date-ending-of))

(defun get-cash-flow-series (symbol)
  "Return a time series of CASH-FLOW of SYMBOL."
  (get-time-series (cash-flow :symbol symbol) 'fiscal-date-ending-of))

(defun get-earnings-series (symbol)
  "Return a time series of EARNINGS of SYMBOL."
  (get-time-series (earnings :symbol symbol) 'fiscal-date-ending-of))
