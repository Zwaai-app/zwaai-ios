# Manual Testing

## Contents

- [Manual Testing](#manual-testing)
  - [Contents](#contents)
  - [Introduction](#introduction)
  - [Accessibility](#accessibility)
    - [A.1 - VoiceOver](#a1---voiceover)
    - [A.2 - Full Keyboard Access](#a2---full-keyboard-access)

## Introduction

This document describes the minimum of manual testing that needs to be
performed to validate the app.

## Accessibility

### A.1 - VoiceOver

Make sure that all functionality of the app can be performed without looking
at the screen: scanning another person's QR code, checking in at a space,
checking out again, viewing history, controlling settings. Specific attention
should be given to:

- On the screen where another person's QR code is scanned, the QR code is
  displayed at the top, because this facilitates better scanning (see
  [design-decisions]). Right below that QR code is a text explaining what to do.
  When using VoiceOver, this text should be read _before_ the QR code.

TODO: describe how to activate and use VoiceOver

### A.2 - Full Keyboard Access

Make sure that all functionality of the app can be performed using a keyboard.

TODO: describe how to activate and use full keyboard access

[design-decisions]: ./DesignDecisions.md
