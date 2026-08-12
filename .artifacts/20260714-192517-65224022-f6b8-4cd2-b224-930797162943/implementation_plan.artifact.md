# Progress Feature Alignment Plan

Align the Flutter `ProgressScreen` with the React `InBodyProgress.tsx` to ensure feature parity, including the next scan booking scenario and enhanced data visualization.

## User Review Required

- **Radar Chart**: Flutter doesn't have a built-in Radar chart in standard `CustomPaint` without a lot of boilerplate. I will implement a simplified version or a placeholder if I can't find a lightweight way to draw it, but I'll try to implement it with `CustomPaint` for maximum fidelity.
- **Booking Flow**: I will reuse the same multi-step pattern from the Booking feature for the "Book Next Scan" sheet.

## Proposed Changes

### Progress Feature

#### [progress_screen.dart](file:///C:/Users/tiger/StudioProjects/truefit_users/lib/features/progress/presentation/screens/progress_screen.dart)

- **State Management**: Add local state to control the visibility of the "Book Next Scan" bottom sheet.
- **Latest Scan Summary**:
    - Update layout to match the React gradient card (LATEST SCAN title, date, grid of metrics with trending icons).
- **Key Metrics Grid**:
    - Add the 3-column grid (Weight Lost, Muscle Gain, Body Fat %).
- **Next Scan Section**:
    - [NEW] Add the call-to-action card at the bottom of the scroll view.
    - Implement `_showBookScanSheet` which will open a multi-step booking modal.
- **Booking Flow (`_BookScanSheet`)**:
    - Step 1: Info card (15 min · Free for members).
    - Step 2: Date Picker (using `SCAN_SLOTS` data).
    - Step 3: Time Picker.
    - Step 4: Summary & Confirm.
    - Step 5: Success message.

#### [progress_charts.dart](file:///C:/Users/tiger/StudioProjects/truefit_users/lib/features/progress/presentation/widgets/progress_charts.dart)

- **Radar Chart**:
    - [NEW] Implement `BodyCompositionRadar` using `CustomPaint`.
    - It will visualize "Current" vs "Ideal" across: Muscle, Body Fat, Hydration, Bone Mass, Protein.
- **Existing Charts**:
    - Ensure `LineChartPainter` and `BarChart` match the React data and styling (colors, grid lines).

#### [translations.dart](file:///C:/Users/tiger/StudioProjects/truefit_users/lib/core/intl/translations.dart)

- Add missing translation keys:
    - `bookInBodyScan`, `bodyCompAnalysis`, `weightTrend`, `bodyFatPct`, `muscleMassGrowth`, `bodyCompAnalysisTitle`, `nextInBodyScan`, `scheduleNextScan`, `bookNextScan`, `scanBookedSuccess`, `scanReminder`.

## Verification Plan

### Manual Verification
- **Booking Flow**:
    - Click "Book Next Scan".
    - Navigate through Date/Time selection.
    - Confirm booking and verify success state.
- **UI Fidelity**:
    - Compare the latest scan card with React.
    - Verify the 3-column metrics grid.
    - Verify Radar Chart rendering (labels and two data series).
- **RTL Support**: Switch to Arabic and verify layout direction.
