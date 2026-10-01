# Calibration

Calibration uses nine screen targets. Each valid target collects multiple non-blinking samples above the confidence threshold.

The current model is Ridge regression over four iris features plus a bias term. Lambda is 1.0 and the normal equations are solved using Cholesky decomposition.

Calibration data is versioned and persisted locally. The legacy Ridge model remains available for backward compatibility.

If calibration becomes inaccurate, clear it from Settings and run all nine targets again. Keep the head reasonably stable and look directly at each target.
