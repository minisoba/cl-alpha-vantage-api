(defsystem cl-alpha-vantage-api
  :name    "cl-alpha-vantage-api"
  :author  "Y. IGUCHI"
  :license "MIT"
  :depends-on (:alexandria
               :cl-change-case
               :cl-ppcre
               :closer-mop
               :drakma
               :duckdb
               :local-time
               :parse-float
               :yason)
  :components ((:file "src/package")
               (:file "src/specials")
               (:file "src/util")
               (:file "src/end-point-schema")
               (:file "src/condition")
               (:file "src/end-point-builder")
               (:file "src/end-points")
               (:file "src/symbol-search")
               (:file "src/time-series")
               (:file "src/fundamentals")
               (:file "src/requests")
               (:file "src/api")
               (:file "src/parquet"))
  :in-order-to ((asdf:test-op
                 (asdf:test-op :cl-alpha-vantage-api-test)))
  :description "Alpha Vantage API for Common Lisp")
