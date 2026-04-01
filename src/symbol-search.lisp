(in-package :cl-alpha-vantage-api)

(defclass symbol-search ()
  ((ticker          :accessor ticker-of          :initform nil)
   (name            :accessor name-of            :initform nil)
   (instrument-type :accessor instrument-type-of :initform nil)
   (region          :accessor region-of          :initform nil)
   (market-open     :accessor market-open-of     :initform nil)
   (market-close    :accessor market-close-of    :initform nil)
   (timezone        :accessor timezone-of        :initform nil)
   (ccy             :accessor ccy-of             :initform nil)
   (match-score     :accessor match-score-of     :initform 0.0)))

(defun make-symbol-search (hash-table)
  "Create a SYMBOL-SEARCH instance from HASH-TABLE."
  (make-instance-from-hash-table symbol-search hash-table))
