#|
 This file is a part of Humbler
 (c) 2014 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.tymoonnext.humbler)

(defun to-keyword (string)
  "Turns a key into a keyword.
Replaces _ with - and uppercases the string, then interns it
into the keyword package. This is useful to parse the request
responses into an alist."
  (let ((name (cl-ppcre:regex-replace-all "_" (string-upcase string) "-")))
    (or (find-symbol name "KEYWORD") (intern name "KEYWORD"))))

(defun from-keyword (keyword)
  "Turns a keyword into a key.
Replaces - with _ and downcases the keyword as a string.
This is useful to parse the request parameters from the
lisp representation into the api representation."
  (cl-ppcre:regex-replace-all "-" (string-downcase keyword) "_"))

(defun raw-request (url &key (method :get) parameters oauth (redirect 10))
  (if oauth
      (south:signed-request url :parameters parameters :method method :drakma-params `(:redirect ,redirect))
      (let ((drakma:*text-content-types* (cons '("application" . "json")
                                               (cons '("text" . "json")
                                                     (cons '("application" . "x-www-form-urlencoded")
                                                           drakma:*text-content-types*)))))
        (drakma:http-request url :method method :parameters parameters :redirect redirect))))

(defun request (url &key (method :get) parameters oauth (redirect 10))
  (let ((data (multiple-value-list (raw-request url :method method :parameters parameters :oauth oauth :redirect redirect))))
    (destructuring-bind (body status headers &rest dont-care) data
      (declare (ignore dont-care))
      (when (>= status 400)
        (error "Error during request: ~s" data))
      (let ((content-type (cdr (assoc :content-type headers))))
        (cond
          ((search "json" content-type)
           (values-list (cons (cdr (assoc :response (yason:parse body :object-as :alist :object-key-fn #'to-keyword)))
                              (cdr data))))
          (T (values-list data)))))))

(defun prepare (parameters)
  "Filters out empty key-value pairs and turns all values
into strings, ready to be sent out as request parameters.
This function is DESTRUCTIVE."
  (mapc #'(lambda (pair)
            (setf (car pair) (from-keyword (car pair)))
            (setf (cdr pair) (typecase (cdr pair)
                               (string (cdr pair))
                               (boolean "true")
                               (t (princ-to-string (cdr pair))))))
        (delete () parameters :key #'cdr)))

(defmacro prepare* (&rest parameter-names)
  "Creates a PREPARE statement out of the provided variables."
  `(prepare (list ,@(mapcar #'(lambda (a)
                                (if (consp a)
                                    `(cons ,(from-keyword (car a)) ,(cdr a))
                                    `(cons ,(from-keyword a) ,a)))
                            parameter-names))))

(defvar *unix-epoch-difference*
  (encode-universal-time 0 0 0 1 1 1970 0))

(defun get-unix-time ()
  (- (get-universal-time) *unix-epoch-difference*))