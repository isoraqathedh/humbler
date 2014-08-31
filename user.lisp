#|
 This file is a part of Humbler
 (c) 2014 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.tymoonnext.humbler)

(defvar *user/info* "https://api.tumblr.com/v2/user/info")
(defvar *user/dashboard* "https://api.tumblr.com/v2/user/dashboard")
(defvar *user/likes* "https://api.tumblr.com/v2/user/likes")
(defvar *user/following* "https://api.tumblr.com/v2/user/following")
(defvar *user/follow* "https://api.tumblr.com/v2/user/follow")
(defvar *user/unfollow* "https://api.tumblr.com/v2/user/unfollow")
(defvar *user/like* "https://api.tumblr.com/v2/user/like")
(defvar *user/unlike* "https://api.tumblr.com/v2/user/unlike")

(defun user/info ()
  (request *user/info* :oauth T))

(defun user/dashboard (&key (limit 20) (offset 0) type (since-id 0) reblog-info notes-info)
  (assert (member type '(NIL :text :quote :link :answer :video :audio :photo :chat))
          () "Type has to be one of (NIL :text :quote :link :answer :video :audio :photo :chat)")
  (assert (<= 1 limit 20)
          () "Limit must be between 1 and 20 (inclusive).")
  (assert (<= 0 offset)
          () "Offset must be positive.")
  (assert (<= 0 since-id)
          () "Since-ID must be positive.")
  (if reblog-info (setf reblog-info T))
  (if notes-info (setf notes-info T))
  (request *user/dashboard* :oauth T :parameters (prepare* limit offset type since-id reblog-info notes-info)))

(defun user/likes (&key (limit 20) (offset 0))
  (assert (<= 1 limit 20)
          () "Limit must be between 1 and 20 (inclusive).")
  (assert (<= 0 offset)
          () "Offset must be positive.")
  (request *user/likes* :oauth T :parameters (prepare* limit offset)))

(defun user/following (&key (limit 20) (offset 0))
  (assert (<= 1 limit 20)
          () "Limit must be between 1 and 20 (inclusive).")
  (assert (<= 0 offset)
          () "Offset must be positive.")
  (request *user/following* :oauth T :parameters (prepare* limit offset)))

(defun user/follow (username)
  (request *user/follow* :method :POST :oauth T :parameters `(("url" . ,(format NIL "~a.tumblr.com" username)))))

(defun user/unfollow (username)
  (request *user/unfollow* :method :POST :oauth T :parameters `(("url" . ,(format NIL "~a.tumblr.com" username)))))

(defun user/like (id reblog-key)
  (request *user/like* :method :POST :oauth T :parameters (prepare* id reblog-key)))

(defun user/unlike (id reblog-key)
  (request *user/unlike* :method :POST :oauth T :parameters (prepare* id reblog-key)))