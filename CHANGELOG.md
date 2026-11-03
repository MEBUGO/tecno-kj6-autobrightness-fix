# Changelog

All notable changes to this project will be documented in this file.

## [v1.0] - 2026-11-03

### Features
- **Native ALS Daemon (`autobrightness.sh`)**: Direct reading from `/sys/devices/virtual/hf_manager/hf_manager/als`.
- **Perceptual Curve**: Piecewise logarithmic spline mapping (0-255).
- **Hysteresis**: $\ge 4$ deadband filter to prevent flickering.
- **Power Efficiency**: Pauses during screen off. Zero wakelocks held.
- **Quick Settings Integration**: Forces auto-brightness toggle (`qs_show_auto_brightness = 1`).
- **Transsion PWM Scaling**: Preserves 12-bit (0-4095) hardware backlight range via `system.prop`.
- **User Config**: Easily tunable through `config.conf`.
