;;; config/yasnippet.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Set Up
;;------------------------------------------------------------------------------

;;--------------------
;; Default Snippets Location
;;--------------------

;; Don't override if it was set in e.g. secrets init or system init or something.
(when (null (jerky/get "emacs/snippets"))
  (jerky/set "emacs/snippets"
             :value (spy/path/to-dir doom-private-dir "snippets")
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

  (when-let ((dir/snippets (jerky/get "emacs/snippets")))
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
;; My Snippets
;;------------------------------------------------------------------------------

;; Nothing to do - already told yasnippet where they were.
