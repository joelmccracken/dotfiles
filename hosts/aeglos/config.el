;; aeglos/

;; [[file:../../workstation.org::*aeglos/][aeglos/:1]]
(after! org
  (jnm/org-common-config "~/EF/" )

  (setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
  (setq org-mobile-files (org-agenda-files))
  (setq org-mobile-inbox-for-pull "~/EF/inbox-mobile.org"))
;; aeglos/:1 ends here
