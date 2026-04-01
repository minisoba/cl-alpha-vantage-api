(in-package :cl-alpha-vantage-api)

(defparameter +enum-type-validators+
  `((:interval-0-types        ,+interval-0-types+        interval-0-types-error)
    (:interval-1-types        ,+interval-1-types+        interval-1-types-error)
    (:interval-2-types        ,+interval-2-types+        interval-2-types-error)
    (:interval-3-types        ,+interval-3-types+        interval-3-types-error)
    (:interval-4-types        ,+interval-4-types+        interval-4-types-error)
    (:interval-5-types        ,+interval-5-types+        interval-5-types-error)
    (:treasury-maturity-types ,+treasury-maturity-types+ treasury-maturity-types-error)
    (:boolean-types           ,+boolean-types+           boolean-types-error)
    (:output-size-types       ,+output-size-types+       output-size-types-error)
    (:listing-status-types    ,+listing-status-types+    listing-status-types-error)
    (:earnings-horizon-types  ,+earnings-horizon-types+  earnings-horizon-types-error)
    (:sort-types              ,+sort-types+              sort-types-error)
    (:series-types            ,+series-types+            series-types-error)
    (:ma-types                ,+ma-types+                ma-types-error))
  "Mapping from enumerated type keywords to (valid-values error-condition).")

(defun check-parameter-type (key opt typ val)
  "Validate that VAL is acceptable for parameter KEY of type TYP.
OPT is :required or :optional."
  (when (and (eq opt :required) (null val))
    (error 'parameter-error :argument key))
  (let ((enum (assoc typ +enum-type-validators+)))
    (if enum
        (destructuring-bind (_ valid-values error-condition) enum
          (declare (ignore _))
          (unless (member val valid-values :test #'equal)
            (error error-condition :argument val)))
        (ecase typ
          (:string
           (unless (stringp val)
             (error 'data-type-error :argument val)))
          (:float
           (unless (or (floatp val) (integerp val))
             (error 'data-type-error :argument val)))
          (:integer
           (unless (integerp val)
             (error 'data-type-error :argument val)))
          (:date
           (typep (local-time:parse-timestring val) 'local-time:timestamp))
          (:iso-ccy
           (unless (and (stringp val) (= (length val) 3))
             (error 'data-type-error :argument val))))))
  t)

(defun %hyphen-to-underscore (string)
  "Replace hyphens with underscores in STRING."
  (substitute #\_ #\- string))

(defun %format-param-value (value)
  "Format VALUE for use in a query URL parameter."
  (cond ((member value +ma-types+) (convert-ma-type value))
        ((symbolp value)            (string-downcase (symbol-name value)))
        ((listp value)              (string-downcase (format nil "~{~a~^,~}" value)))
        (t                          value)))

(defun %find-end-point (name)
  "Find the end-point schema entry for NAME in +END-POINTS+."
  (find name +end-points+ :test 'equal :key 'caar))

(defun %find-end-point-group (name)
  "Return the end-point group keyword for NAME."
  (cadar (%find-end-point name)))

(defmacro defendpoint (name)
  "Define an Alpha Vantage API end-point function for NAME.
Looks up the parameter schema from +END-POINTS+ and generates a function
that builds a query URL with parameter validation."
  (let* ((end-point (%find-end-point name))
         (schema (cdr end-point))
         (keys (mapcar #'car schema))
         (fn-name (%hyphen-to-underscore (string name))))
    `(defun ,name (&key ,@keys)
       (when (null *api-token*)
         (error "*API-TOKEN* cannot be NIL"))
       (let ((query (format nil "https://~a~a"
                            +query-url-base+
                            ,fn-name)))
         ,@(loop for (key opt typ) in schema
                 for url-key = (%hyphen-to-underscore
                                (string-downcase (symbol-name key)))
                 collect
                 (if (eq opt :required)
                     `(progn
                        (check-parameter-type ',key ',opt ',typ ,key)
                        (setf query (format nil "~a&~a=~a" query ,url-key
                                            (%format-param-value ,key))))
                     `(when ,key
                        (check-parameter-type ',key ',opt ',typ ,key)
                        (setf query (format nil "~a&~a=~a" query ,url-key
                                            (%format-param-value ,key))))))
         (setf query (format nil "~a&apikey=~a" query *api-token*))
         query))))
