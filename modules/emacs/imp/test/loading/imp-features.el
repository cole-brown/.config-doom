;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/loading/imp-features.el

(imp:feature:at :loading
                '(((:loading load)
                   "load.el")
                  ((:loading dont-load)
                   "dont-load.el")))
