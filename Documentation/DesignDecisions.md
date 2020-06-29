# Design Decisions

## Contents

- [Design Decisions](#design-decisions)
  - [Contents](#contents)
  - [Starting Points](#starting-points)
    - [Accessibility](#accessibility)
    - [Ease of Use](#ease-of-use)
    - [Native Development](#native-development)
  - [Screen Designs](#screen-designs)
    - [Zwaai Person Screen](#zwaai-person-screen)

## Starting Points

### Accessibility

TODO

### Ease of Use

TODO: widget, quick actions, siri actions, etc. (Watch app?)

### Native Development

TODO: explain (mainly available capabilities, no requirements dictating cross-platform)

## Screen Designs

### Zwaai Person Screen

This screen allows a user to scan another user's QR code. When scanning this
way, the users have to point the screens of their phones towards each other. The
(front-facing) camera that is used for scanning is near the top of the device,
so for that reason the QR code is displayed first in the UI. This way it is best
aligned to the other user's camera. However, in the accessibility tree the
explanation text below the QR code comes first. This means that VoiceOver will
first read the text, and then the QR code, even though the order on screen is
reversed.
