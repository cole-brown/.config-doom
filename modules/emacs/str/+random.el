;;; emacs/str/+random.el -*- lexical-binding: t; -*-

;; Some of this is derived from:
;;   - http://ergoemacs.org/emacs/elisp_insert_random_number_string.html
;;   - http://ergoemacs.org/emacs/elisp_generate_uuid.html


(imp:require :str 'string)


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
    (message "str:random:number/insert(%S)" length)
    (dotimes (_ (if (numberp length) (abs length) 5 ))
      (insert (elt charset (random charset.length))))))
;; (str:random:number/insert 10)


(defun str:random:hex/insert (length)
  "Insert LENGTH random hexadecimal digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-08-03"
  (interactive "P")
  (let ((n (if (numberp length) (abs length) 5 )))
    (insert (format  (concat "%0" (number-to-string n) "x" ) (random (1- (expt 16 n)))))))
;; (str:random:hex/insert 10)


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
      (insert (elt charset (random charset.length))))))
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
  (int<str>:insert->str #'str:random:number/insert length))
;; (str:random:number/string 10)


(defun str:random:hex/string (length)
  "Returns a string of LENGTH random hexadecimal digits. LENGTH default to 5.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2017-08-03"
  (interactive "P")
  (int<str>:insert->str #'str:random:hex/insert length))
;; (str:random:hex/string 10)


(defun str:random:string/string (length)
  "Returns a string of a random alphanumerics string of length 5.
The possible chars are: A to Z, a to z, 0 to 9.

Call `universal-argument' before for different count.

URL `http://ergoemacs.org/emacs/elisp_insert_random_number_string.html'
Version 2018-08-03"
  (interactive "P")
  (int<str>:insert->str #'str:random:string/insert length))
;; (str:random:string/string 10)


(defun str:random:uuid/string ()
  "Returns a string of a UUID.
This commands calls “uuidgen” on MacOS, Linux, and calls PowelShell on Microsoft Windows.

URL `http://ergoemacs.org/emacs/elisp_generate_uuid.html'
Version 2020-06-04"
  (interactive)
  (int<str>:insert->str #'str:random:uuid/insert length))
;; (str:random:uuid/string)



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :str '+random)
