# CDA3104-Project
Traffic light control system for a single-lane roadway using AVR assembly language

Objective
Design and implement a traffic light control system for a single-lane roadway using AVR assembly language. The system must include realistic light sequencing (Red → Green → Yellow), respond to a crosswalk button, and manage LED indicators for vehicle and pedestrian traffic. Additional features may be implemented for extra credit.

Specifications
Base Functionality – Max 89 Points
You must implement the following on your breadboard:

1. Single-Lane Traffic Light Control (35 pts)

Use Red, Yellow, and Green LEDs to simulate traffic lights.

Implement a realistic timed sequence:

Red (4–5s)

Green (4–5s)

Yellow (1–2s)

Cycle repeats indefinitely.

2. Crosswalk Button and Indicators (30 pts)

Add a momentary push-button input for pedestrian crossing.

When pressed, the next Red phase must include:

A Red LED for cars.

A White LED (Walk) for pedestrians for 4–6 seconds.

After crossing, resume normal light sequence.

3. Implement a Timer: Timer0 or Timer1 (5 pts)

4. Implement Interrupts: Timer and or buttons (5 pts)

5. Breadboard Layout & Documentation (14 pts)

Neatly wired circuit with labeled inputs/outputs.

Proper use of resistors for LEDs.

Include a wiring diagram and pinout in your submission.

Commented code explaining all registers and logic.

Extension Features (For up to 100 Points Total)
6. Crossing Lane of Traffic (6 pts) – up to 95 pts

Implement a second set of Red, Yellow, and Green LEDs.

Alternate flow between primary and crossing traffic.

Add an additional push-button for the second crosswalk.

Prevent both directions from showing Green at the same time.

7. Smart Crosswalk Enhancements (5 pts) – up to 100 pts Choose one of the following:

Smart Yellow Timing: When a crosswalk is requested, shorten the Yellow light before Red.

Blinking Walk LED: Make the White pedestrian LED blink during the second half of the walk cycle to warn that time is almost up.
