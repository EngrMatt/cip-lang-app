---
name: Ethnos & Echo
colors:
  surface: '#111413'
  surface-dim: '#111413'
  surface-bright: '#373a39'
  surface-container-lowest: '#0c0f0e'
  surface-container-low: '#191c1b'
  surface-container: '#1d201f'
  surface-container-high: '#282b29'
  surface-container-highest: '#323534'
  on-surface: '#e1e3e1'
  on-surface-variant: '#c1c8c3'
  inverse-surface: '#e1e3e1'
  inverse-on-surface: '#2e3130'
  outline: '#8b928e'
  outline-variant: '#414845'
  surface-tint: '#adcec0'
  primary: '#adcec0'
  on-primary: '#18362c'
  primary-container: '#06261d'
  on-primary-container: '#6f8f83'
  inverse-primary: '#466559'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#321c00'
  on-tertiary-container: '#be7900'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c8eadb'
  primary-fixed-dim: '#adcec0'
  on-primary-fixed: '#012018'
  on-primary-fixed-variant: '#2f4d42'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#111413'
  on-background: '#e1e3e1'
  surface-variant: '#323534'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.1em
  waveform-timestamp:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '400'
    lineHeight: 12px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  gutter: 16px
  stack-sm: 12px
  stack-lg: 32px
---

## Brand & Style

This design system establishes a "Cultural Tech" aesthetic, specifically tailored for field researchers documenting indigenous languages. The brand personality is **scholarly yet pioneering**, bridging the gap between ancient oral traditions and modern digital preservation. 

The visual style is a fusion of **Corporate Minimalism** and **Glassmorphism**. It utilizes a deep, grounded color palette inspired by nature, punctuated by high-vibrancy "tech" accents that signify the app's powerful processing capabilities. Layouts prioritize focus and clarity, using generous whitespace to respect the complexity of the data being collected. To evoke a sense of heritage, abstract geometric patterns—inspired by traditional textiles—are used as subtle background textures or frost-layered masks, ensuring the tool feels culturally resonant without becoming decorative.

## Colors

The palette is anchored by **Deep Forest Green (#06261D)**, serving as the primary surface color to provide a restful, high-contrast environment for long-form research. 

- **Primary:** Deep Forest Green for deep backgrounds and primary containers.
- **Secondary (Emerald Tech):** A vibrant emerald used for primary actions, success states, and interactive waveforms.
- **Tertiary (Soft Gold):** An earthy, metallic gold used sparingly for highlights, high-priority tags, or "archival" indicators.
- **Neutral:** A range of desaturated, warm-tinted grays to maintain the "earthy" feel in text and borders.
- **Glass Effects:** Surfaces use a 12% opacity white or primary-tinted overlay with a 20px backdrop blur to create depth and sophistication.

## Typography

Typography is selected for its high legibility across diverse character sets (essential for phonetic transcriptions). 

**Manrope** provides a modern, balanced feel for headlines, feeling professional and tech-forward. **Be Vietnam Pro** is used for body copy due to its open apertures and excellent readability at smaller sizes. **JetBrains Mono** is introduced as a functional utility font for technical metadata, timestamps, and audio coordinates, reinforcing the "scientific tool" aspect of the app.

## Layout & Spacing

The layout follows a **fluid grid** model with a specific focus on vertical rhythm. 

- **Mobile:** 4-column grid with 24px side margins. 
- **Desktop/Tablet:** 12-column grid with a maximum content width of 1200px to prevent line lengths from becoming unreadable.
- **Rhythm:** An 8px base unit governs all spacing. Generous 32px gaps are used between major content sections to maintain the premium, "un-cluttered" feel requested. 

Cards and list items use internal padding of 20px to 24px to ensure the rounded corners do not encroach on the content.

## Elevation & Depth

Hierarchy is achieved through **Glassmorphic Tonal Layers** rather than traditional heavy shadows.

- **Level 0 (Floor):** Pure Primary color (#06261D).
- **Level 1 (Cards):** Translucent emerald-tinted overlays (8-12% opacity) with a 1px soft border (#FFFFFF10) and a subtle 24px blur.
- **Level 2 (Modals/Popovers):** Higher opacity glass (20%) with a soft, diffused "glow" shadow using the secondary emerald color at 10% opacity.
- **Audio Components:** Waveforms appear "etched" into the surface using inner shadows, while the playhead acts as a glowing, elevated element.

## Shapes

The shape language is defined by **Sleek Roundedness**. All primary containers and cards use a **24px radius** (rounded-xl) to create a soft, modern, and friendly approachable feel. 

Buttons and input fields utilize **Pill-shaped** (full radius) geometry to contrast against the large rectangular cards, making them immediately identifiable as interactive elements. Chips/Tags use a smaller 12px radius to maintain a distinct visual language from buttons.

## Components

### Buttons
Primary buttons feature a smooth linear gradient from Emerald (#10B981) to Teal (#14B8A6). Text is high-contrast white or deep green. Secondary buttons are "Ghost" style with a 1.5px emerald border.

### Bottom Navigation
A floating glass bar with a 32px radius. Active states are indicated by a soft gold dot below the icon and a slight emerald glow behind the icon vector.

### Waveform Audio
Interactive waveforms are rendered as vertical bars. Unplayed segments are low-opacity white; played segments are solid Emerald. The playhead is a vertical gold line with a timestamp label in JetBrains Mono.

### Input Fields
Floating labels are mandatory. The border is a subtle white-translucent line that "glows" Emerald when focused. Error states use a soft terracotta red rather than a harsh bright red to maintain the earthy palette.

### List Cards
Each card includes a category chip in the top-right and a chevron for navigation. Cards should support background "weaving" patterns at 5% opacity to add texture without distracting from text.