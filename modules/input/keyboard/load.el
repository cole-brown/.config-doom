;;; input/keyboard/load.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Loading Files...                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                               PC LOAD LETTER                               ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst input//kl:dir/root (dir!)
  "Absolute path to `:input/keyboard' root directory.")


(defconst input//kl:dir/layout/prefix "+"
  "Layout dirs must start with a '+'.")


;;------------------------------------------------------------------------------
;; Basic Load Functions
;;------------------------------------------------------------------------------

(defun input//kl:file/exists? (relative-path)
  "Returns non-nil if RELATIVE-PATH exists relative to this file's directory."
  (file-exists-p (concat (file-name-as-directory input//kl:dir/root) relative-path)))
;; (input//kl:file/exists? "layout/spydez/init.el")


(defun input//kl:loading-for (layout)
  "Returns non-nil if loading (or developing/debugging) for the LAYOUT.

LAYOUT can be the flag symbol or keyword (see `input//kl:normalize->keyword').

E.g. if `:dvorak' is our desired layout, this returns non-nil for LAYOUT
`:dvorak', and nil for others."
  (and input//kl:layout/desired
       layout
       (eq input//kl:layout/desired
           (input//kl:normalize->keyword layout))))
;; (input//kl:loading-for :spydez)
;; (input//kl:loading-for :qwerty)


(defun input:keyboard/layout:load-file (layout load-name &optional directory)
  "Load LOAD-NAME file if its LAYOUT directory and LOAD-NAME file exists on the
filesystem.

DIRECTORY, if nil, will be FLAG minus its '+' prefix (e.g. `+dvorak' is
'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  ;; Allow keyword or flag.
  (let* ((directory (or directory
                        (input//kl:normalize->string layout)))
         (path (concat (file-name-as-directory "layout")
                       ;; Add the required '+'.
                       input//kl:dir/layout/prefix
                       (file-name-as-directory directory)
                       load-name)))
    ;; Is it ok for some files to not exist, maybe?
    ;; Perhaps a layout has an init.el but not a config.el right now?..
    (when (input//kl:file/exists? (concat path ".el"))
      (load! path))
    ;; If not, switch back to this:
    ;; (if (input//kl:file/exists? (concat path ".el"))
    ;;     (load! path)
    ;;   (warn (input//kl:error-message "input:keyboard/layout:load-file"
    ;;                                  "Could not find "
    ;;                                  "'%s' file for '%s'. path: %s")
    ;;         load-name
    ;;         flag
    ;;         (concat path ".el")))
    ))
;; (input:keyboard/layout:load-file :spydez "config")


;;------------------------------------------------------------------------------
;; Load Active Layout Functions
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:load-active (layout load-name &optional directory)
  "Load LAYOUT if it is the desired layout according to `input//kl:loading-for'
and if its LOAD-NAME file exists on the filesystem.

DIRECTORY, if nil, will be FLAG minus its default prefix (e.g. `+layout/dvorak'
is 'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  (when (input//kl:loading-for layout)
    (input:keyboard/layout:load-file layout load-name directory)))
;; (input:keyboard/layout:load-active :spydez "config")


(defun input:keyboard/layout:find-and-load-active (file)
  "Find/load active layout's FILE.

Search relative to directory the caller is in. For each directory
found, load file name FILE /only if/ it is the directory name matches the active
layout.

FILE should /not/ have its extension so that the .elc can be used if it exists."
  ;; Find all files/dirs in this file's directory that:
  ;;   - Are not "." or "..".
  ;;   - And have at least one character in their name.
  ;; Get their attributes too so we can filter down to just directories.
  (let* ((file-path-this (if load-in-progress
                             (file-name-directory load-file-name)
                           (buffer-file-name)))
         (directory-path (directory-file-name
                          (file-name-directory file-path-this)))
         ;; Layout dirs must have '+' in front of them and must be our direct children.
         (files-and-attrs (directory-files-and-attributes directory-path
                                                          nil
                                                          (rx string-start
                                                              "+"
                                                              (one-or-more print)
                                                              string-end))))
    ;; Iterate through what was found and figure out if its a directory.
    (dolist (file-and-attr files-and-attrs)
      (let ((name (car file-and-attr))
            (dir? (file-attribute-type (cdr file-and-attr))))
        ;; `file-attribute-type' returns t for a directory, so skip any
        ;; non-directories like so.
        (when dir?
          ;; Our keyboard layout directories are named such that they can be
          ;; passed into `input:keyboard/layout:load-active'.
          (input:keyboard/layout:load-active name file))))))
;; (input:keyboard/layout:find-and-load-active "config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
