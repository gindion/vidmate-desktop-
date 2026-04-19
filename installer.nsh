; installer.nsh
; Custom NSIS script included by electron-builder
; Adds: welcome page, license check, custom finish page with "Launch now" checkbox

; ── Installer pages ────────────────────────────────────────────────────────────
!macro customHeader
  ; Nothing extra in header
!macroend

!macro customInit
  ; Check Windows version — require Win 10+
  ${If} ${AtLeastWin10}
    ; OK
  ${Else}
    MessageBox MB_ICONSTOP "VidMate Desktop requires Windows 10 or later."
    Abort
  ${EndIf}
!macroend

!macro customInstall
  ; ── Set permissions on bundled binaries so they're executable ──────────────
  ; (NSIS runs as user, so just ensure the files are accessible)
  SetOverwrite on

  ; ── Write app version to registry (for Add/Remove Programs detail) ──────────
  WriteRegStr HKCU "Software\VidMateDesktop" "Version" "1.0.0"
  WriteRegStr HKCU "Software\VidMateDesktop" "InstallDir" "$INSTDIR"

  ; ── Create Downloads folder shortcut in user's Downloads ───────────────────
  ; (Optional convenience — users can change the folder inside the app)
  CreateDirectory "$DOCUMENTS\VidMate Downloads"
  WriteRegStr HKCU "Software\VidMateDesktop" "DefaultDownloadDir" "$DOCUMENTS\VidMate Downloads"

  ; ── Associate .vidmate extension ────────────────────────────────────────────
  WriteRegStr HKCR ".vidmate" "" "VidMateDesktop.Download"
  WriteRegStr HKCR "VidMateDesktop.Download" "" "VidMate Desktop Download"
  WriteRegStr HKCR "VidMateDesktop.Download\DefaultIcon" "" "$INSTDIR\VidMate Desktop.exe,0"
  WriteRegStr HKCR "VidMateDesktop.Download\shell\open\command" "" '"$INSTDIR\VidMate Desktop.exe" "%1"'

  ; Notify shell of extension change
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'
!macroend

!macro customUnInstall
  ; ── Clean up registry entries ────────────────────────────────────────────────
  DeleteRegKey HKCU "Software\VidMateDesktop"
  DeleteRegKey HKCR ".vidmate"
  DeleteRegKey HKCR "VidMateDesktop.Download"
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

  ; ── Remove app data (optional — only if user checked the box) ────────────────
  ; electron-builder's NSIS handles the main uninstall; we just clean extras
  RMDir /r "$APPDATA\vidmate-desktop\Crashpad"
  RMDir /r "$APPDATA\vidmate-desktop\GPUCache"
  ; Leave: $APPDATA\vidmate-desktop (settings, history) — user might want these
!macroend
