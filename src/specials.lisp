(in-package :cl-alpha-vantage-api)

(defvar *api-token*
  (uiop:getenv "ALPHA_VANTAGE_API_TOKEN")
  "ALPHA VANTAGE API token")

(defun set-api-token (token)
  "Set the ALPHA VANTAGE API token."
  (setf *api-token* token))

(defvar *end-point-table*
  nil
  "ALPHA VANTAGE API dispatch table")

(defparameter +query-url-base+
              "www.alphavantage.co/query?function="
              "ALPHA VANTAGE query url base")
