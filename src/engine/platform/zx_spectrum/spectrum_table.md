# ZX Spectrum Screen Table

The ZX Spectrum's screen is designed to be addressed in a way that allows you to sequentially write a full character without having to do it one row at a time. This table explains how the addressing works. It's copied from _Mastering Machine Code on Your ZX Spectrum_ for convenience.

```
 0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F
┌───────────────────────────────┬───────────────────────────────┐
│  40                  0        │  40                  1        │
│ (58)                 2        │ (58)                 3        │
│                      4        │                      5        │
│                      6        │                      7        │
│                      8        │                      9        │
│                      A        │                      B        │
│                      C        │                      D        │
│                      E        │                      F        │
├───────────────────────────────┼───────────────────────────────┤
│  48                  0        │  48                  1        │
│ (59)                 2        │ (59)                 3        │
│                      4        │                      5        │
│                      6        │                      7        │
│                      8        │                      9        │
│                      A        │                      B        │
│                      C        │                      D        │
│                      E        │                      F        │
├───────────────────────────────┼───────────────────────────────┤
│  50                  0        │  50                  1        │
│ (5A)                 2        │ (5A)                 3        │
│                      4        │                      5        │
│                      6        │                      7        │
│                      8        │                      9        │
│                      A        │                      B        │
│                      C        │                      D        │
│                      E        │                      F        │
└───────────────────────────────┴───────────────────────────────┘
```

This divides the screen up into the 32x24 character grid. The start address in pixel screen memory of each character is as follows:

- The first byte is one of the three regions, which are labeled in the boxes. The top number is the bitmap address, and the number in parentheses is the attribute address.
- The first nibble of the second byte is the row, but it'll have an even index if it's on the left half of the screen, and an odd index if it's on the right.
- The final nibble is the last nibble of the column value.


