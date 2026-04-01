(in-package :cl-user)

(defpackage :alpha-vantage.test
  (:use :cl :alpha-vantage :fiveam)
  (:export
   :run-tests
   :alpha-vantage-tests
   :end-point-tests
   :request-tests))

(in-package :alpha-vantage.test)

(def-suite alpha-vantage-tests
  :description "All alpha-vantage tests")
