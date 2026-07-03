---
name: Ethnos & Echo Light
colors:
  surface: '#f8faf7'
  surface-dim: '#d9dad8'
  surface-bright: '#f8faf7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f2'
  surface-container: '#edeeec'
  surface-container-high: '#e7e9e6'
  surface-container-highest: '#e1e3e1'
  on-surface: '#191c1b'
  on-surface-variant: '#404944'
  inverse-surface: '#2e3130'
  inverse-on-surface: '#f0f1ef'
  outline: '#717974'
  outline-variant: '#c0c8c3'
  surface-tint: '#396756'
  primary: '#00261b'
  on-primary: '#ffffff'
  primary-container: '#0a3d2e'
  on-primary-container: '#78a894'
  inverse-primary: '#a0d1bc'
  secondary: '#855324'
  on-secondary: '#ffffff'
  secondary-container: '#febc83'
  on-secondary-container: '#79491b'
  tertiary: '#351900'
  on-tertiary: '#ffffff'
  tertiary-container: '#542a00'
  on-tertiary-container: '#ea841b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bbedd7'
  primary-fixed-dim: '#a0d1bc'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#204f3f'
  secondary-fixed: '#ffdcc1'
  secondary-fixed-dim: '#fbb980'
  on-secondary-fixed: '#2e1500'
  on-secondary-fixed-variant: '#693c0e'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#ffb77d'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6e3900'
  background: '#f8faf7'
  on-background: '#191c1b'
  surface-variant: '#e1e3e1'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
---

## Brand & Style

This design system is defined by a sophisticated balance of heritage and modernity, shifting from a nocturnal aesthetic to a bright, editorial-focused light mode. It targets high-end cultural platforms, travel archives, and boutique lifestyle applications. The brand personality is grounded, intellectual, and serene.

The design style utilizes **Modern Minimalism** with **Tonal Layering**. It avoids heavy shadows in favor of subtle shifts in background values and precise line-work, creating an interface that feels like a premium print publication. The atmosphere is intentional, airy, and high-contrast, ensuring that cultural content remains the focal point against a clean, structured canvas.

## Colors

The color palette is anchored by a deepened "Cultural Green" (Primary), adjusted for optimal legibility and presence on white backgrounds. It evokes a sense of permanence and nature.

- **Primary (#0A3D2E):** Used for key actions, brand headers, and active states.
- **Secondary (#704214):** A rich, earthy sienna used for supporting elements, categories, and accents that require a warm contrast to the green.
- **Tertiary (#D97706):** A vibrant ochre for highlighting, interactive notifications, and call-outs.
- **Surface & Neutral:** The background architecture uses `#FFFFFF` for the base and `#F4F6F5` for containers to create soft depth without relying on shadows. Typography is set in a near-black `#111413` to maintain maximum accessibility and a premium editorial feel.

## Typography

Typography is the core of the design system. **Manrope** provides a geometric yet warm typeface that bridges the gap between technical precision and human touch. 

- **Display & Headlines:** Utilize tighter letter-spacing and heavier weights to command attention. Use Primary Green for headlines to establish brand presence.
- **Body Text:** Maintains a generous line-height to ensure comfort during long-form reading. 
- **Labels:** Utilize slightly increased letter spacing and semi-bold weights to ensure visibility at small sizes.
- **Scale:** Large display styles scale down on mobile to prevent awkward line breaks while maintaining their visual weight.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy for desktop to maintain an editorial "page" feel, and a **Fluid Grid** for mobile devices.

- **Grid System:** A 12-column grid is used for desktop (1280px max width). On mobile, this collapses to a 4-column grid.
- **Spacing Rhythm:** Based on an 8px base unit. 
- **Vertical Spacing:** Content blocks should be separated by large, airy margins (64px+) to reflect the minimalist aesthetic. 
- **Reflow:** On tablet, gutters remain consistent but side margins compress to 32px.

## Elevation & Depth

This design system avoids traditional heavy shadows. Depth is communicated through **Tonal Layers** and **Low-Contrast Outlines**.

- **Surface Levels:** The base level is pure white (#FFFFFF). Elevated elements like cards or navigation bars use the Surface-Container (#F4F6F5) or a 1px border (#E2E8E5) to distinguish themselves.
- **Interactive Depth:** On hover, elements may transition to a slightly darker tonal shift or receive a very soft, high-diffusion shadow (0px 4px 20px rgba(0,0,0,0.04)).
- **Overlays:** Modals and menus utilize a backdrop blur (12px) over a semi-transparent white wash to maintain the "glass" quality of the interface without darkening the screen excessively.

## Shapes

The shape language is friendly yet structured. The "Rounded" setting (0.5rem base) provides a modern, approachable feel that softens the high-contrast typography.

- **Small Components:** Checkboxes and small tags use the base 0.5rem.
- **Main Components:** Buttons and input fields use `rounded-lg` (1rem) to feel more tactile and distinctive.
- **Large Containers:** Cards and image containers use `rounded-xl` (1.5rem) to frame content elegantly.

## Components

- **Buttons:** Primary buttons are solid Primary Green with White text. Secondary buttons use a Primary Green outline with a subtle #F4F6F5 fill on hover.
- **Inputs:** Fields use a 1px border (#E2E8E5). On focus, the border thickens to 2px in Primary Green. Labels are always positioned above the field in `label-md` style.
- **Cards:** Cards are styled with the Surface-Container background and no border. They utilize `rounded-xl` for a soft, premium look. 
- **Chips/Tags:** Small labels with Secondary Sienna or Tertiary Ochre backgrounds at 10% opacity, featuring solid text of the same color for high legibility.
- **Lists:** Clean, border-bottom separators (#E2E8E5) with generous padding (16px top/bottom).
- **Additional Components:** Include "Archive Sliders" for cultural content and "Narrative Dividers" which use subtle iconography to break long vertical scrolls.