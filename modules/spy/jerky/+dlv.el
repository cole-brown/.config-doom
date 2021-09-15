;;; spy/jerky/+dlv.el -*- lexical-binding: t; -*-

;; Jerky Directory Local Variable support for auto-namespaces.

(imp:require :dlv)


;;------------------------------------------------------------------------------
;; Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Auto-Namespacing
;;------------------------------

(defvar jerky//dlv/namespace.local nil
  "Directory Local Variable for holding the directory's namespace.")

;; Mark our DLV variable as safe for DLV use.
(dlv:var:safe.predicate 'jerky//dlv/namespace.local #'jerky//namespace/valid)


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

(defun jerky/dlv/namespace.set (directory namespace)
  "Sets Jerky's local NAMESPACE for the DIRECTORY."
  (jerky//debug "jerky//dlv/namespace.set" "\n  dir: %s \n  ns:  %S"
                directory namespace)

  (if (not (jerky/namespace/has namespace))
      (error "jerky/dlv/namespace.set: No known namespace called '%s'" namespace)

    (jerky//debug "jerky//dlv/namespace.set" "  -> `jerky//dlv/namespace.local'")
    (dlv:set (dlv:class:symbol.create :jerky
                                      namespace
                                      dlv:const:class:separator
                                      directory)
             directory
             nil ;; global mode
             (list 'jerky//dlv/namespace.local
                   namespace
                   :safe))

    (mis0/init/message (concat "jerky/dlv/namespace.set: \n"
                               "  directory:  %S\n"
                               "  namespace:  %S")
                       directory
                       namespace)))
;; (jerky/get 'path 'org 'journal :namespace :work)
;;   -> "d:/home/spydez/.lily.d/logbook/work/"
;; (jerky/dlv/namespace.set "d:/home/work/.lily.d/logbook/work/" :work)
