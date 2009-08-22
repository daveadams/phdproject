;; kill all phd buffers
(dolist (buffer (buffer-list))
  (if (string-match "^/home/da1/per/phd" (or (buffer-file-name buffer) ""))
      (save-excursion
        (message (format "Buffer %s (%s)" buffer (buffer-file-name buffer)))
        (set-buffer buffer)
        (save-buffer)
        (kill-buffer buffer))))
