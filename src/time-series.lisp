(in-package :cl-alpha-vantage-api)

(defclass time-series ()
  ((value     :accessor value-of     :initform 0.0)
   (timestamp :accessor timestamp-of :initform (local-time:universal-to-timestamp 0))))

(defun make-time-series (hash-table)
  "Create a TIME-SERIES instance from HASH-TABLE."
  (make-instance-from-hash-table time-series hash-table))

(defclass time-series-ohcl ()
  ((open-price  :accessor open-price-of  :initform 0.0)
   (high-price  :accessor high-price-of  :initform 0.0)
   (low-price   :accessor low-price-of   :initform 0.0)
   (close-price :accessor close-price-of :initform 0.0)
   (volume      :accessor volume-of      :initform 0)
   (timestamp   :accessor timestamp-of   :initform (local-time:universal-to-timestamp 0))))

(defun make-time-series-ohcl (hash-table)
  "Create a TIME-SERIES-OHCL instance from HASH-TABLE."
  (make-instance-from-hash-table time-series-ohcl hash-table))

(defclass fx-time-series-ohcl ()
  ((open-price  :accessor open-price-of  :initform 0.0)
   (high-price  :accessor high-price-of  :initform 0.0)
   (low-price   :accessor low-price-of   :initform 0.0)
   (close-price :accessor close-price-of :initform 0.0)
   (timestamp   :accessor timestamp-of   :initform (local-time:universal-to-timestamp 0))))

(defun make-fx-time-series-ohcl (hash-table)
  "Create an FX-TIME-SERIES-OHCL instance from HASH-TABLE."
  (make-instance-from-hash-table fx-time-series-ohcl hash-table))

(defclass crypto-time-series-ohcl ()
  ((open-price      :accessor open-price-of      :initform 0.0)
   (open-price-usd  :accessor open-price-usd-of  :initform 0.0)
   (high-price      :accessor high-price-of      :initform 0.0)
   (high-price-usd  :accessor high-price-usd-of  :initform 0.0)
   (low-price       :accessor low-price-of       :initform 0.0)
   (low-price-usd   :accessor low-price-usd-of   :initform 0.0)
   (close-price     :accessor close-price-of     :initform 0.0)
   (close-price-usd :accessor close-price-usd-of :initform 0.0)
   (volume          :accessor volume-of          :initform 0.0)
   (market-cap-usd  :accessor market-cap-usd-of  :initform 0.0)
   (timestamp       :accessor timestamp-of       :initform (local-time:universal-to-timestamp 0))))

(defun make-crypto-time-series-ohcl (hash-table)
  "Create a CRYPTO-TIME-SERIES-OHCL instance from HASH-TABLE."
  (make-instance-from-hash-table crypto-time-series-ohcl hash-table))

(defclass ta-time-series ()
  ((ta-values :accessor ta-values-of :initform nil)
   (timestamp :accessor timestamp-of :initform (local-time:universal-to-timestamp 0))))

(defun make-ta-time-series (hash-table)
  "Create a TA-TIME-SERIES instance from HASH-TABLE."
  (make-instance-from-hash-table ta-time-series hash-table))

(defclass quote-snapshot ()
  ((ticker               :accessor ticker-of               :initform nil)
   (open-price           :accessor open-price-of           :initform 0.0)
   (high-price           :accessor high-price-of           :initform 0.0)
   (low-price            :accessor low-price-of            :initform 0.0)
   (price                :accessor price-of                :initform 0.0)
   (volume               :accessor volume-of               :initform 0)
   (timestamp            :accessor timestamp-of            :initform (local-time:universal-to-timestamp 0))
   (previous-close-price :accessor previous-close-price-of :initform 0.0)
   (change               :accessor change-of               :initform 0.0)
   (change-percent       :accessor change-percent-of       :initform 0.0)))

(defun make-quote-snapshot (hash-table)
  "Create a QUOTE-SNAPSHOT instance from HASH-TABLE."
  (make-instance-from-hash-table quote-snapshot hash-table))

(defclass fx-quote-snapshot ()
  ((from-ccy-code :accessor from-ccy-code-of :initform nil)
   (from-ccy-name :accessor from-ccy-name-of :initform nil)
   (to-ccy-code   :accessor to-ccy-code-of   :initform nil)
   (to-ccy-name   :accessor to-ccy-name-of   :initform nil)
   (exchange-rate :accessor exchange-rate-of :initform 0.0)
   (timezone      :accessor timezone-of      :initform nil)
   (timestamp     :accessor timestamp-of     :initform (local-time:universal-to-timestamp 0))
   (bid-price     :accessor bid-price-of     :initform 0.0)
   (ask-price     :accessor ask-price-of     :initform 0.0)))

(defun make-fx-quote-snapshot (hash-table)
  "Create an FX-QUOTE-SNAPSHOT instance from HASH-TABLE."
  (make-instance-from-hash-table fx-quote-snapshot hash-table))
