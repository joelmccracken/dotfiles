(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(safe-local-variable-values
   '((eval require 'ox-texinfo+ nil t)
     (eval require 'ol-info)
     (lsp-haskell-server-path . "~/bin/haskell-language-server-macOS-8.8.4")
     (lsp-haskell-formatting-provider . "stylish-haskell")
     (lsp-enable-file-watchers . t)
     (lsp-file-watch-threshold . 2000)
     (org-babel-noweb-wrap-start . "«")
     (org-babel-noweb-wrap-end . "»")
     (org-src-preserve-indentation)
     (eval progn
      (make-local-variable 'projectile-make-test-cmd)
      (setq projectile-ruby-test-cmd "rake"))
     (eval message "starting yaml-mode")
     (eval message "hello there")
     (eval progn
      (let*
          ((load-path
            (cons
             (locate-dominating-file default-directory "ef.el")
             load-path)))
        (require 'ef)))
     (jnm/in-ef-dir . t)
     (ef/files "actions.org" "projects-maintenance.org" "projects.org" "upcoming.org" "waiting.org"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
