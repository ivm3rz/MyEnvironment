;;; infotecs-c-style.el --- Infotecs's C/C++ style for c-mode

;; Author: Merzlyakov Igor <Igor.Merzlyakov@infotecs.ru>
;; Keywords: c, tools

;;; Commentary:

;; Provides the infotecs C/C++ coding style. You may wish to add
;; `infotecs-set-c-style' to your `c-mode-common-hook' after requiring this
;; file. For example:
;;
;;    (add-hook 'c-mode-common-hook 'infotecs-set-c-style)
;;


;;; Code:

;; For some reason 1) c-backward-syntactic-ws is a macro and 2)  under Emacs 22
;; bytecode cannot call (unexpanded) macros at run time:
(eval-when-compile (require 'cc-defs))

;; Wrapper function needed for Emacs 21 and XEmacs (Emacs 22 offers the more
;; elegant solution of composing a list of lineup functions or quantities with
;; operators such as "add")
(defun infotecs-c-lineup-expression-plus-5 (langelem)
  "Indents to the beginning of the current C expression plus 5 spaces.

This implements title \"Function Declarations and Definitions\"
of the Infotecs C++ Style Guide for the case where the previous
line ends with an open parenthese.

\"Current C expression\", as per the Infotecs Style Guide and as
clarified by subsequent discussions, means the whole expression
regardless of the number of nested parentheses, but excluding
non-expression material such as \"if(\" and \"for(\" control
structures.

Suitable for inclusion in `c-offsets-alist'."
    (save-excursion
      (back-to-indentation)
      ;; Go to beginning of *previous* line:
      (c-backward-syntactic-ws)
      (back-to-indentation)
      (cond
       ;; We are making a reasonable assumption that if there is a control
       ;; structure to indent past, it has to be at the beginning of the line.
       ((looking-at "\\(\\(if\\|for\\|while\\)\\s *(\\)")
        (goto-char (match-end 1)))
       ;; For constructor initializer lists, the reference point for line-up is
       ;; the token after the initial colon.
       ((looking-at ":\\s *")
        (goto-char (match-end 0))))
      (vector (+ 5 (current-column)))))

;;;###autoload
(defconst infotecs-c-style
  `((c-recognize-knr-p . nil)
    (c-enable-xemacs-performance-kludge-p . t) ; speed up indentation in XEmacs
    (c-basic-offset . 5)
    (indent-tabs-mode . nil)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist . ((defun-open after)
                               (defun-close before after)
                               (class-open after)
                               (class-close before after)
                               (inexpr-class-open after)
                               (inexpr-class-close before)
                               (namespace-open after)
                               (inline-open after)
                               (inline-close before after)
                               (block-open after)
                               (block-close . c-snug-do-while)
                               (extern-lang-open after)
                               (extern-lang-close after)
                               (statement-case-open after)
                               (substatement-open after)))
    (c-hanging-colons-alist . ((case-label)
                               (label after)
                               (access-label after)
                               (member-init-intro before)
                               (inher-intro)))
    (c-hanging-semi&comma-criteria
     . (c-semi&comma-no-newlines-for-oneline-inliners
        c-semi&comma-inside-parenlist
        c-semi&comma-no-newlines-before-nonblanks))
    (c-indent-comments-syntactically-p . t)
    (comment-column . 40)
    (c-indent-comment-alist . ((other . (space . 2))))
    (c-cleanup-list . (brace-else-brace
                       brace-elseif-brace
                       brace-catch-brace
                       empty-defun-braces
                       defun-close-semi
                       list-close-comma
                       scope-operator))
    (c-offsets-alist . ((arglist-intro infotecs-c-lineup-expression-plus-5)
                        (func-decl-cont . ++)
                        (member-init-intro . +)
                        (inher-intro . ++)
                        (comment-intro . 0)
                        (arglist-close . c-lineup-arglist)
                        (topmost-intro-cont . 0)
                        (block-open . 0)
                        (inline-open . 0)
                        (substatement-open . 0)
                        (statement-cont
                         .
                         (,(when (fboundp 'c-no-indent-after-java-annotations)
                             'c-no-indent-after-java-annotations)
                          ,(when (fboundp 'c-lineup-assignments)
                             'c-lineup-assignments)
                          ++))
                        (label . /)
                        (case-label . +)
                        (statement-case-open . +)
                        (statement-case-intro . +) ; case w/o {
                        (access-label . -)
                        (innamespace . 0))))
  "Infotecs C/C++ Programming Style.")


(defun infotecs/c-style-mode-hook()
    "Set the current buffer's c-style to InfoTeCS C/C++ Programming Style.
    Meant to be added to `c-mode-common-hook'."
    (interactive)
    (make-local-variable 'c-tab-always-indent)
    (setq c-tab-always-indent t)
    (c-add-style "infotecs" infotecs-c-style t))

(provide 'infotecs-c-style)

;;; infotecs-c-style.el ends here
