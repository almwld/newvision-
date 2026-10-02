# Architecture

## Layers
- Presentation (Flutter UI + Providers)
- Domain (Entities + UseCases + Repository Interfaces)
- Data (Repository Impl + DataSources)
- Platform (Native Android)

## Data Flow
Camera → MediaPipe → Iris Extract → Kalman → Calibration → ScreenPoint → Dwell → Touch
