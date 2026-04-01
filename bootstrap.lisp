(in-package :cl-user)

(require 'asdf)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload '(:alexandria
                  :cl-change-case
                  :cl-ppcre
                  :drakma
                  :local-time
                  :parse-float
                  :yason)))

(pushnew (make-pathname :directory (pathname-directory *load-truename*)) asdf:*central-registry*)
(asdf:load-system "cl-alpha-vantage-api")
(alpha-vantage:set-api-token (uiop:getenv "ALPHA_VANTAGE_API_TOKEN"))
