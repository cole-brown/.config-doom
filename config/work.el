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


(defun spy:cmd:buffer:kill/magit (&optional timestamp)
  "Delete all magit buffers."
  (interactive)
  (message "[%s] Kill 'magit' buffers..."
           timestamp)
  ;; Magit buffers shouldn't stick around. They get in the way of saving
  ;; workspaces and can easily be reopened.
  (spy:buffer/kill.matching ".*magit.*"
                            :internal
                            :modified
                            :process))


(defun spy:cmd:buffer:kill/deadgrep (&optional timestamp)
  "Delete all deadgrep buffers."
  (interactive)
  (message "[%s] Kill 'deadgrep' buffers..."
           timestamp)
  (spy:buffer/kill.matching ".*deadgrep.*"
                            :internal
                            :modified
                            :process))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'work)
