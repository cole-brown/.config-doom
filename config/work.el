;;; config/work.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                WORK STUFF                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Start of the Workday
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; End of the Workday
;;------------------------------------------------------------------------------


(defun spy:cmd:buffer:kill/magit ()
  "Delete all magit buffers."
  (interactive)
  (message "[%s] Kill 'magit' buffers..."
           (spy:datetime/string.get 'iso-8601 'long))
  ;; Magit buffers shouldn't stick around. They get in the way of saving
  ;; workspaces and can easily be reopened.
  (spy:buffer/kill.matching ".*magit.*"
                            :internal
                            :modified
                            :process))


(defun spy:cmd:buffer:kill/deadgrep ()
  "Delete all deadgrep buffers."
  (interactive)
  (message "[%s] Kill 'deadgrep' buffers..."
           (spy:datetime/string.get 'iso-8601 'long))
  (spy:buffer/kill.matching ".*deadgrep.*"
                            :internal
                            :modified
                            :process))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'work)
