ui_print "*****************************************"
ui_print " TECNO KJ6 Auto-Brightness Fix (KernelSU) "
ui_print " by MEBUGO "
ui_print "*****************************************"
ui_print "- Model: TECNO KJ6 (MT6789)"
ui_print "- Setting file permissions..."
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/autobrightness.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/config.conf" 0 0 0644
ui_print "- KernelSU Hardware Auto-Brightness Daemon: OK"
ui_print "- Transsion Backlight PWM Scaling: OK"
ui_print "- Installation completed successfully!"
