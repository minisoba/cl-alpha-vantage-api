(in-package :alpha-vantage.test)

(defun run-tests ()
  "Run all test suites."
  (let ((*api-token* "demo"))
    (run! 'end-point-tests))
  (run! 'request-tests))
