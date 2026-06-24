---
name: Field Ethos
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#414846'
  inverse-surface: '#303030'
  inverse-on-surface: '#f2f0f0'
  outline: '#717976'
  outline-variant: '#c1c8c4'
  surface-tint: '#45655c'
  primary: '#001813'
  on-primary: '#ffffff'
  primary-container: '#0d2e27'
  on-primary-container: '#76978d'
  inverse-primary: '#abcec3'
  secondary: '#47645e'
  on-secondary: '#ffffff'
  secondary-container: '#c9e9e1'
  on-secondary-container: '#4d6a64'
  tertiary: '#0e1611'
  on-tertiary: '#ffffff'
  tertiary-container: '#222b25'
  on-tertiary-container: '#89928b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c7eadf'
  primary-fixed-dim: '#abcec3'
  on-primary-fixed: '#00201a'
  on-primary-fixed-variant: '#2d4d45'
  secondary-fixed: '#c9e9e1'
  secondary-fixed-dim: '#aecdc6'
  on-secondary-fixed: '#02201c'
  on-secondary-fixed-variant: '#2f4c47'
  tertiary-fixed: '#dbe5dc'
  tertiary-fixed-dim: '#bfc9c0'
  on-tertiary-fixed: '#151d18'
  on-tertiary-fixed-variant: '#404942'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1440px
  gutter: 24px
  margin-edge: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is tailored for the meticulous and respectful world of linguistic fieldwork. The brand personality is **Academic, Rooted, and Reliable**, bridging the gap between high-precision data management and the organic nature of cultural preservation. It aims to evoke a sense of calm focus, ensuring that the technology remains a silent partner to the researcher.

The design style is **Modern Corporate with a Tactile twist**. It utilizes a structured, high-density layout necessary for complex data, but softens the digital edge through a warm, earthy color palette and gentle surface transitions. The interface prioritizes clarity and legibility, using subtle tonal layering to organize information without the "coldness" often associated with enterprise software.

## Colors

The palette is inspired by natural field environments—forests, soil, and archival paper.

- **Primary (Forest Green):** A deep, authoritative green used for primary actions, navigation headers, and critical branding elements.
- **Secondary (Muted Teal):** Used for secondary actions, iconography, and decorative accents that require a professional yet softer touch.
- **Tertiary (Sage Mist):** A functional color for subtle backgrounds, hover states, and structural dividers.
- **Background & Surface:** The core workspace uses a soft cream (`#F8F9F5`) to reduce eye strain during long data-entry sessions, while cards and interactive surfaces use pure white for maximum contrast.
- **Warm Accents:** Soft browns and ochres are reserved for status indicators related to "Draft" or "In Progress" states, providing a visual link to organic materials.

## Typography

The system utilizes **Hanken Grotesk** as its primary typeface. It is a highly legible, contemporary sans-serif that maintains its character across various weights, making it ideal for the dense information hierarchies required in linguistic research.

For technical metadata, timestamps, and linguistic coding (such as IPA or phonetic notes), **JetBrains Mono** is employed. Its monospaced nature ensures that character spacing is consistent, which is vital for comparative analysis and data auditing.

- **Headlines:** Set with tight tracking and bold weights to provide clear section anchors.
- **Body:** Optimized for readability with a generous 1.5x line height.
- **Labels:** Monospaced and uppercase for metadata tags, ensuring they are clearly distinguished from narrative content.

## Layout & Spacing

The design system employs a **Fixed-Fluid Hybrid Grid**. On desktop, the main content area is capped at 1440px to prevent excessively long line lengths for text-heavy field notes.

- **Grid System:** A 12-column grid with 24px gutters.
- **Density:** The system defaults to a "Comfortable" density for general browsing, but allows for a "Compact" data table view where vertical padding is reduced to 8px to maximize information density.
- **Sidebar:** A fixed 280px navigation sidebar persists on the left, housing primary modules (Archive, Phonetics, Lexicon, Media).
- **Rhythm:** All spacing is based on a 4px baseline grid to ensure perfect alignment of iconography and typography.

## Elevation & Depth

To maintain an academic and grounded feel, the system avoids heavy, dramatic shadows. Instead, it uses **Tonal Layering** and **Low-Contrast Outlines**.

- **Level 0 (Background):** The soft cream base (`#F8F9F5`).
- **Level 1 (Cards/Containers):** Pure white surfaces with a 1px border in a muted sage (`#D9E3DA`). No shadow.
- **Level 2 (Interactive Elements):** Buttons and active cards feature a very soft, highly diffused shadow (4px blur, 5% opacity) to suggest clickability without breaking the flat, professional aesthetic.
- **Modals:** Use a heavy background blur (backdrop-filter: blur(8px)) with a semi-transparent dark overlay to keep focus on the data entry while maintaining context.

## Shapes

The shape language is **Soft and Precise**. 

- **Primary UI Elements:** Buttons, inputs, and tags use a 4px (`0.25rem`) corner radius. This conveys a professional, slightly architectural feel.
- **Containers:** Content cards and detail panels use an 8px (`0.5rem`) radius to provide a gentler framing for large blocks of data.
- **Status Badges:** These are fully pill-shaped to differentiate them clearly from interactive buttons.

## Components

### Data Tables
Tables are the backbone of the system. Rows feature a subtle hover state (`#F1F4F1`). Column headers use **JetBrains Mono** in all-caps to denote technical categories. Cells containing linguistic data should support right-to-left (RTL) text and special phonetic characters.

### Detail Cards
Information is grouped into "Artifact Cards." These feature a secondary background color in the header to group related metadata (e.g., Speaker Name, Location, Date).

### Status Badges
Used for transcription status:
- `Verified`: Solid Primary Green with white text.
- `Pending`: Warm Gray border with primary text.
- `Flagged/Review`: Muted Terracotta background with dark text.

### Media Players
The audio player is integrated directly into the data view. It uses a minimalist waveform visualization. Controls (Play, Pause, Scrub) are styled as subtle icons without heavy enclosures to keep the interface clean.

### Input Fields
Inputs use a "contained" style with a 1px border. On focus, the border thickens to 2px and shifts to the primary Forest Green. Supporting text and validation errors use a smaller Hanken Grotesk weight.