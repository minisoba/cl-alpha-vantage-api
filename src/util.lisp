(in-package :cl-alpha-vantage-api)

(defvar *http-headers*)
(defvar *http-status-code*)
(defvar *http-reason-phrase*)

(defun http-request (end-point)
  "Send HTTP request to ALPHA-VANTAGE END-POINT and transform a JSON response data into HASH-TABLE."
  (let ((yason:*parse-object-as* :hash-table))
    (flet ((parse-stream (stream content-type)
             (destructuring-bind (type &rest encoding) (cl-ppcre:split ";\\s*" content-type)
               (declare (ignore encoding))
               (alexandria:switch (type :test #'equal)
                 ("application/json"
                  (yason:parse stream))))))
      (multiple-value-bind (stream status-code headers uri stream- must-close reason-phrase)
          (drakma:http-request end-point :method :get :want-stream t)
        (declare (ignore uri stream- must-close))
        (setf *http-headers*       headers
              *http-status-code*   status-code
              *http-reason-phrase* reason-phrase)
        (unless (= status-code 200)
          (error 'http-request-error
                 :status status-code
                 :reason reason-phrase
                 :text   (format nil "~a" end-point)))
        (when stream
          (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
          (let ((content-type (assoc :content-type *http-headers*)))
            (parse-stream stream (cdr content-type))))))))

(defun %parse-integer (x)
  "Parse X as an integer. Return 0 for the string \"None\"."
  (cond ((numberp x)         x)
        (t
         (if (string= x "None")
             0
             (parse-integer x)))))

(defun %parse-float (x)
  "Parse X as a float. Strip trailing '%' if present. Return 0.0 for lone '.'."
  (cond ((string= x ".") 0.0)
        ((position #\% x)
         (parse-float:parse-float (remove #\% x)))
        (t
         (parse-float:parse-float x))))

(defun %parse-timestamp (x)
  "Parse X as a LOCAL-TIME:TIMESTAMP using space as the date-time separator."
  (local-time:parse-timestring x :date-time-separator #\Space))

(defun %convert-type (obj slot val)
  "Convert VAL to match the type of SLOT in OBJ."
  (typecase (slot-value obj slot)
    (integer       (%parse-integer val))
    (single-float  (%parse-float val))
    (local-time:timestamp (%parse-timestamp val))
    (t             val)))

(defmacro make-instance-from-hash-table (name hash-table)
  "Create an instance of class NAME, populating slots from HASH-TABLE keys."
  (alexandria:with-unique-names (obj slot value)
    `(let ((,obj (make-instance ',name)))
       (loop for key being the hash-keys in ,hash-table do
         (let ((,slot (intern (string-upcase (cl-change-case:param-case key))
                              (symbol-package ',name)))
               (,value (gethash key ,hash-table)))
           (when (slot-exists-p ,obj ,slot)
             (setf (slot-value ,obj ,slot)
                   (%convert-type ,obj ,slot ,value)))))
       ,obj)))
