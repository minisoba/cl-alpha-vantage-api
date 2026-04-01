(defsystem cl-alpha-vantage-api-test
  :author  "Y. IGUCHI"
  :license "MIT"
  :description "Unit tests for cl-alpha-vantage-api"
  :serial t
  :depends-on (:cl-alpha-vantage-api
               :cl-ppcre
               :fiveam)
  :components ((:file "t/package")
               (:file "t/end-points")
               (:file "t/requests")
               (:file "t/run-tests"))
  :perform (asdf:test-op
            (o s)
            (uiop:symbol-call
             :alpha-vantage.test '#:run-tests)))
