;;; config/markdown.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Markdown Mode & Friends
;;------------------------------------------------------------------------------

;;------------------------------
;; Grip: GitHub-Flavored Markdown Previewer
;;------------------------------
(use-package! grip-mode
  ;; :after markdown

  ;;--------------------
  :init
  ;;--------------------
  ;; Check if 'grip' Python module is installed?
  ;;   - Don't know a good way to do this cross-platform.
  ;;   - Linux only: python -m pip show 'netaddr' >/dev/null 2>&1;
  ;; pip install grip
  (let ((buffer/stdout (get-buffer-create "*Python 'grip' Check: output*"))
        (buffer/stderr (get-buffer-create "*Python 'grip' Check: errors*")))
    ;; Check for 'grip' module. Non-zero return means it wasn't found.
    (unless (= 0
               (with-output-to-temp-buffer buffer/stdout
                 (shell-command "python -m pip show 'grip'"
                                buffer/stdout
                                buffer/stderr)))
      (mis0/init/warning "(use-package! grip-mode)"
                         (mapconcat #'identity
                                    '("Required Python module 'grip' is not installed!"
                                      "Install with:"
                                      "  `python -m pip install grip`"
                                      "Then you might need these:"
                                      "  (setenv \"PATH\" (concat \"/home/%1$s/.local/bin\" \":\" (getenv \"PATH\")))"
                                      "  (setq exec-path (append '(\"/home/%1$s/.local/bin\") exec-path)")
                                    "\n")
                         user-login-name))
    ;; Delete the temp buffers.
    (kill-buffer buffer/stdout)
    (kill-buffer buffer/stderr))

    ;; Will Emacs pick up the new path after I reboot or something?
    ;; Updated my '~/.bashrc' but it doesn't have it after restarting Emacs...
    ;; (let ((dir (format "/home/%s/.local/bin" user-login-name)))
    ;;   (setenv "PATH" (concat dir  ":" (getenv "PATH")))
    ;;   (setq exec-path (append (list dir) exec-path)))

  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization:
  ;;--------------------
  ;; Using a personal-access-token avoids any "GitHub Rate Limit Reached" issues.
  ;;   https://github.com/seagle0128/grip-mode#faq
  (customize-set-variable 'grip-github-user (plist-get secret:keys:github :id))
  (customize-set-variable 'grip-github-pass (plist-get secret:keys:github :secret))

  (customize-set-variable 'grip-update-after-change t
                          "Live updating preview instead of only after saves.")

  (customize-set-variable 'grip-preview-use-webkit nil
                          (concat "Use Emacs' embedded browser. "
                                  "Requires Emacs version >= 26, built with the `--with-xwidgets` flag.")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'markdown)
