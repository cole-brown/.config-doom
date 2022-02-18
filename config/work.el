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
  ;; Magit buffers shouldn't stick around. They get in the way of saving
  ;; workspaces and can easily be reopened.
  (spy:cmd:buffer/kill.matching ".*magit.*"
                                :internal
                                :no-ask
                                :delete-process))
;; (spy:workday:end/magit)


(defun spy:cmd:buffer:kill/deadgrep ()
  "Delete all deadgrep buffers."
  ;; Deadgrep buffers shouldn't stick around. They get in the way of saving
  ;; workspaces and can easily be reopened.
  (spy:cmd:buffer/kill.matching ".*deadgrep.*"
                                :internal
                                :no-ask
                                :delete-process))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'work)
