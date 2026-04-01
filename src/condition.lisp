(in-package :cl-alpha-vantage-api)

(define-condition alpha-vantage-error (error) ())

(define-condition parameter-error (alpha-vantage-error)
  ((argument :reader argument :initarg :argument))
  (:report (lambda (condition stream)
             (format stream "Missing required parameter: ~a" (argument condition)))))

(define-condition http-request-error (alpha-vantage-error)
  ((status :reader status :initarg :status)
   (reason :reader reason :initarg :reason)
   (text   :reader text   :initarg :text))
  (:report (lambda (condition stream)
             (format stream "HTTP Error ~a ~a: ~a"
                     (status condition)
                     (reason condition)
                     (text   condition)))))

(defmacro defcondition (name &key error-message (valid-types "()"))
  "Define a simple condition class named NAME under ALPHA-VANTAGE-ERROR."
  `(define-condition ,name (alpha-vantage-error)
     ((argument :reader argument :initarg :argument))
     (:report (lambda (condition stream)
                (format stream "~a: ~a, valid-types=~a"
                        ,error-message
                        (argument condition)
                        ,valid-types)))))

(defcondition invalid-api-call
  :error-message "Error Message")

(defcondition end-point-group-error
  :error-message "Invalid end-point-group")

(defcondition data-type-error
  :error-message "Invalid data type")

(defcondition interval-0-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-0-types+)

(defcondition interval-1-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-1-types+)

(defcondition interval-2-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-2-types+)

(defcondition interval-3-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-3-types+)

(defcondition interval-4-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-4-types+)

(defcondition interval-5-types-error
  :error-message "Invalid interval type"
  :valid-types   +interval-5-types+)

(defcondition treasury-maturity-types-error
  :error-message "Invalid treasury maturity type"
  :valid-types   +treasury-maturity-types+)

(defcondition boolean-types-error
  :error-message "Invalid boolean type"
  :valid-types   +boolean-types+)

(defcondition output-size-types-error
  :error-message "Invalid output size type"
  :valid-types   +output-size-types+)

(defcondition listing-status-types-error
  :error-message "Invalid listing status type"
  :valid-types   +listing-status-types+)

(defcondition earnings-horizon-types-error
  :error-message "Invalid earnings horizon type"
  :valid-types   +earnings-horizon-types+)

(defcondition sort-types-error
  :error-message "Invalid sort type"
  :valid-types   +sort-types+)

(defcondition series-types-error
  :error-message "Invalid series type"
  :valid-types   +series-types+)

(defcondition ma-types-error
  :error-message "Invalid moving average type"
  :valid-types   +ma-types+)
