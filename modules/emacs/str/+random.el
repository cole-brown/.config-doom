;;; emacs/str/+random.el -*- lexical-binding: t; -*-

;; Some of this is derived from:
;;   - http://ergoemacs.org/emacs/elisp_insert_random_number_string.html
;;   - http://ergoemacs.org/emacs/elisp_generate_uuid.html


(imp:require :str 'string)


;; TODO: Move out of "str/+random.el".
(defun num:random:big (limit)
  "Returns a random integer between 0 and LIMIT.

Emacs' `random' only handles integers up to `most-positive-fixnum' if called
with a limit. This extends that range to cover `bignums'."
  (cond ((not (integerp limit))
         (error "num:random:big: LIMIT must be an integer!"))

        ;; LIMIT is within `fixnum' range - allow `random' to just do its thing.
        ((> most-positive-fixnum limit)
         (random limit))

        ;; LIMIT is a `bignum' - run random a few times to get the properly sized `bignum'.
        (t
         ;; Figure out how many "mask & shift" operations will cover this max LIMIT.
         (let* ((bits:required (ceiling (log limit 2)))         ;; Total random bits needed.
                (bits:per      (logcount most-positive-fixnum)) ;; An iteration will be this many random bits.
                (iterations    (ceiling (/ (float bits:required) bits:per))) ;; Force float math so iterations will be correct.
                (rand:small 0)
                (rand:big   0))
           (dotimes (i iterations)
             ;; Calculate a random `fixnum'.
             (setq rand:small (random most-positive-fixnum))

             ;; Update our random `bignum'.
             (setq rand:big (logior rand:big
                                    (lsh rand:small (* bits:per i))))
             (message (mapconcat #'identity
                                 '("rand:"
                                   "  bits:required: %d"
                                   "  bits:per:      %d"
                                   "  iterations:    %d"
                                   "  i:             %d"
                                   "  rand:small:    %d"
                                   "  rand:big:      %d"
                                   "  limit:         %d"
                                   "  lim > r:b:     %s")
                                 "\n")
                      bits:required
                      bits:per
                      iterations
                      i
                      rand:small
                      rand:big
                      limit
                      (> limit rand:big))
             )

           (while (> rand:big limit)
             (setq rand:big (lsh rand:big -1))
             (message "shrink rand:big... %d"
                      rand:big))
           rand:big))))
;; For a 40 character hex string:
;;   (num:random:big (1- (expt 16 40)))


;;------------------------------------------------------------------------------
;; Random: Insert
;;------------------------------------------------------------------------------

(defun str:random:number/insert (length)
  "Insert LENGTH random digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-05-24"
  (interactive "P")
  (let ((charset "1234567890" )
        (charset.length 10))
    (dotimes (_ (if (numberp length) (abs length) 5 ))
      (insert (elt charset (num:random:big charset.length))))))
;; (str:random:number/insert 10)


(defun str:random:hex/insert (length)
  "Insert LENGTH random hexadecimal digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-08-03"
  (interactive "P")
  (let ((n (if (numberp length) (abs length) 5 )))
    (insert
     (format
      (concat "%0" (number-to-string n) "x")
      (num:random:big (1- (expt 16 n)))
      ))))
;; (str:random:hex/insert 10)
;; (str:random:hex/insert 20)
;; (str:random:hex/insert 40)


(defun str:random:string/insert (length)
  "Insert a random alphanumerics string of length 5.
The possible chars are: A to Z, a to z, 0 to 9.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2018-08-03"
  (interactive "P")
  (let* ((charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
         (charset.length (length charset)))
    (dotimes (_ (if (numberp length) (abs length) 5))
      (insert (elt charset (num:random:big charset.length))))))
;; (str:random:string/insert 10)


(defun str:random:uuid/insert ()
  "Insert a UUID.
This commands calls “uuidgen” on MacOS, Linux, and calls PowelShell on Microsoft Windows.

URL `http://ergoemacs.org/emacs/elisp_generate_uuid.html'
Version 2020-06-04"
  (interactive)
  (cond
   ((string-equal system-type "windows-nt")
    (shell-command "pwsh.exe -Command [guid]::NewGuid().toString()" t))
   ((string-equal system-type "darwin") ; Mac
    (shell-command "uuidgen" t))
   ((string-equal system-type "gnu/linux")
    (shell-command "uuidgen" t))
   (t
    ;; Code here by Christopher Wellons, 2011-11-18.
    ;; and editted Hideki Saito further to generate all valid variants for "N" in xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx format.
    (let ((myStr (md5 (format "%s%s%s%s%s%s%s%s%s%s"
                              (user-uid)
                              (emacs-pid)
                              (system-name)
                              (user-full-name)
                              (current-time)
                              (emacs-uptime)
                              (garbage-collect)
                              (buffer-string)
                              (random)
                              (recent-keys)))))
      (insert (format "%s-%s-4%s-%s%s-%s"
                      (substring myStr 0 8)
                      (substring myStr 8 12)
                      (substring myStr 13 16)
                      (format "%x" (+ 8 (random 4)))
                      (substring myStr 17 20)
                      (substring myStr 20 32)))))))
;; (str:random:uuid/insert)


;;------------------------------------------------------------------------------
;; Random: String
;;------------------------------------------------------------------------------

(defun str:random:number/string (length)
  "Returns a string of LENGTH random digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-05-24"
  (interactive "P")
  (int<str>:str:insert->str #'str:random:number/insert length))
;; (str:random:number/string 10)


(defun str:random:hex/string (length)
  "Returns a string of LENGTH random hexadecimal digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-08-03"
  (interactive "P")
  (int<str>:str:insert->str #'str:random:hex/insert length))
;; (str:random:hex/string 10)


(defun str:random:string/string (length)
  "Returns a string of a random alphanumerics string of length 5.
The possible chars are: A to Z, a to z, 0 to 9.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2018-08-03"
  (interactive "P")
  (int<str>:str:insert->str #'str:random:string/insert length))
;; (str:random:string/string 10)


(defun str:random:uuid/string ()
  "Returns a string of a UUID.
This commands calls “uuidgen” on MacOS, Linux, and calls PowelShell on Microsoft Windows.

URL `http://ergoemacs.org/emacs/elisp_generate_uuid.html'
Version 2020-06-04"
  (interactive)
  (int<str>:str:insert->str #'str:random:uuid/insert length))
;; (str:random:uuid/string)



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :str '+random)
