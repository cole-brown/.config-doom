;;; config/yasnippet.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Set Up
;;------------------------------------------------------------------------------

;;--------------------
;; Default Snippets Location
;;--------------------

;; Don't override if it was set in e.g. secrets init or system init or something.
(when (null (jerky/get 'emacs 'snippets))
  (jerky/set 'emacs 'snippets
             :value (spy:path/to-dir doom-private-dir "snippets")
             :docstr "Default path to snippets in doom private dir."))


;;--------------------
;; YASnippet Configuration
;;--------------------

;; Do yasnippet setup after doom loads it.
(after! yasnippet
  ;; Also indent the rest if indenting non-first, non-empty lines.
  (when yas-indent-line
    (setq yas-also-auto-indent-first-line t
          yas-also-indent-empty-lines t))

  ;; Allow snippet inside of snippets. Snippet inception.
  (setq yas-triggers-in-field t)

  (when-let ((dir/snippets (jerky/get 'emacs 'snippets)))
    (add-to-list 'yas-snippet-dirs dir/snippets))

  ;; TODO [2020-10-30]: Do I need this? It's probably bound somewhere else in
  ;; evil mode... But I might still not want it depending on where?
  ;; ;; Get rid of `yas-expand' binding on TAB. Cannot do this from the `:bind'
  ;; ;; section, annoyingly. And other annoyinglies as well. See:
  ;; ;;   (spydez/help/issue/visit "yasnippet" "unbind-tab.org")
  ;; ;; for more details.
  ;; (unbind-key "TAB" yas-minor-mode-map)
  ;; (unbind-key "<tab>" yas-minor-mode-map)

  ;; TODO [2020-10-30]: I use this in emacs. How else are yasnippets triggered?
  ;; I don't recall...
  ;; (yas-global-mode 1)

  ;; Don't let emacs stuff a newline into snippet files. Sometimes I want the
  ;; snippet flush up with what's below it.
  (add-hook! snippet-mode
    (setq require-final-newline nil)))


;;------------------------------------------------------------------------------
;; Snippet Helper Functions
;;------------------------------------------------------------------------------

;; TODO: move to mis, rename `mis:input//number-somethnig-or-other' or however private vars are...
(defvar sss:yas/number/parse-prevent-input-spam
  nil
  "For preventing yasnippet from spamming user too much during a snippet with `spy:yas/number/parse-or-default'.")


;; TODO: move to mis, rename `mis:input:clear' or something...
(defun spy:yas/number/clear ()
  "Resets `sss:yas/number/parse-prevent-input-spam' for a new snippet or after a snippet is done with it."
  (setq sss:yas/number/parse-prevent-input-spam nil)
  "")


;; TODO: move to mis, rename `mis:input:number'?
(defun spy:yas/number/parse-or-default (parse &optional default prompt)
  "Returns PARSE as a number if `string-to-number' returns non-zero.

If PARSE is `:input' keyword, prompts for the string via `read-number'.
  - Will use PROMPT if it is a string (e.g. \"Column Width: \")

If DEFAULT is non-nil and PARSE didn't parse to non-zero, returns DEFAULT.
  - Else returns zero.

If PARSE is not a string, returns DEFAULT/0.

Does some shenanigans with `sss:yas/number/parse-prevent-input-spam'
to prevent yas from calling too many times."
  (if sss:yas/number/parse-prevent-input-spam
      ;; User has already chosen - provide that choice.
      sss:yas/number/parse-prevent-input-spam

    ;; Get the number and save to prevent spamming for it again.
    (setq sss:yas/number/parse-prevent-input-spam
          (let ((fallback (if (numberp default)
                              default
                            0)))
            ;; Figure out what PARSE is.
            (cond ((eq parse :input)
                   (read-number (or prompt "Number: ")
                                ;; Use the fallback as default input if we have one.
                                (if (/= 0 fallback)
                                    fallback
                                  nil)))

                  ((numberp parse)
                   parse)

                  ((stringp parse)
                   (let ((parsed (string-to-number parse)))
                     ;; Return parsed result only if it succeeded.
                     (if (/= 0 parsed)
                         parsed
                       fallback)))

                  (t
                   fallback))))))
;; (spy:yas/number/parse-or-default "80")
;; (spy:yas/number/parse-or-default "jeff")
;; (spy:yas/number/parse-or-default "jeff" 80)
;; (spy:yas/number/parse-or-default :input 80)
;; (spy:yas/number/parse-or-default :input 80 "Width: ")
