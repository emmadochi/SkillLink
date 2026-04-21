# Design System Specification: High-End Service Editorial

## 1. Overview & Creative North Star: "The Trusted Curator"
This design system moves away from the rigid, boxed-in nature of traditional utility apps. Instead, we are building **"The Trusted Curator."** The goal is to blend the authoritative precision of a logistics giant like Uber with the bespoke, tactile feel of a high-end editorial magazine. 

To achieve this, we prioritize **Intentional Asymmetry** and **Tonal Depth**. We reject the "template" look by using exaggerated white space, overlapping elements (e.g., an artisan's portrait breaking the bounds of a container), and a high-contrast typography scale that guides the user’s eye through hierarchy rather than borders. In emerging markets, trust is built through clarity and professional polish; we achieve this by making the UI feel like a series of layered, premium materials rather than a flat digital screen.

---

## 2. Colors & Tonal Architecture
The palette is rooted in a "Deep Sea" primary and a "Golden Hour" accent. This creates a psychological balance of professional stability and high-energy value.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning or containment. 
Boundaries must be defined solely through:
1.  **Background Shifts:** Placing a `surface-container-lowest` card on a `surface-container-low` background.
2.  **Tonal Transitions:** Using the subtle difference between `surface` (#f6fafe) and `surface-variant` (#dfe3e7).

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of materials. 
*   **Base:** `surface` (#f6fafe) is your canvas.
*   **Sections:** Use `surface-container-low` to define large content areas.
*   **Interactive Cards:** Use `surface-container-lowest` (#ffffff) to create a "lifted" effect.
*   **Nested Elements:** If a card needs a secondary internal area (like a price breakdown), use `surface-container-high`.

### The "Glass & Gradient" Rule
To elevate the platform beyond a standard utility:
*   **Hero Sections:** Use a subtle linear gradient from `primary` (#000c47) to `primary-container` (#001b7a) at a 135-degree angle. This adds "soul" and depth.
*   **Floating Navigation:** Use Glassmorphism. Apply `surface` with 80% opacity and a `20px` backdrop-blur. This ensures the artisan's workspace or map is always visible beneath the UI, creating a sense of environmental immersion.

---

## 3. Typography: The Editorial Voice
We use a two-font system to balance character with readability.

*   **Display & Headlines (Plus Jakarta Sans):** This is our "Editorial" voice. It is modern, geometric, and premium. Use `display-lg` and `headline-lg` with tight letter-spacing (-0.02em) to create an authoritative, "Uber-style" hero presence.
*   **Body & Labels (Inter):** This is our "Functional" voice. Inter is chosen for its exceptional legibility in emerging markets on lower-resolution screens. 

**Hierarchy as Navigation:** 
Use `title-lg` in `primary` color for service names to make them unmissable. Use `label-md` in `outline` (#74777e) for secondary metadata (e.g., "5 mins away") to create a clear visual "quiet zone" around high-importance data.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are often messy. In this design system, we use **Ambient Depth**.

*   **The Layering Principle:** A `surface-container-lowest` card sitting on a `surface-container-low` background creates a soft, natural lift. This is our preferred method of elevation.
*   **Ambient Shadows:** When a floating action button (FAB) or a high-priority modal is required, use a shadow with a blur of `24px`, an offset of `y: 8px`, and an opacity of `6%`. The shadow color must be a tint of `primary` (e.g., #000c47 at 6% alpha) rather than pure black, to simulate natural light reflecting off the deep blue brand color.
*   **The Ghost Border Fallback:** If a container requires more definition for accessibility (e.g., in high-glare outdoor environments), use the `outline-variant` (#c3c6ce) at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons
*   **Primary:** Pill-shaped (`rounded-full`). Background is `primary` (#000c47), text is `on-primary` (#ffffff). For "Golden Path" actions (Book Now, Pay), use a gradient from `primary` to `primary-container`.
*   **Tertiary (Accent):** Use `tertiary-fixed` (#ffddb8) with `on-tertiary-fixed` (#2a1700) for high-urgency notifications or "Special Offer" buttons.
*   **State:** On hover/tap, the `surface-tint` (#2c4de1) should appear as a 10% overlay.

### Cards (The "Artisan Profile")
*   **Rounding:** Always use `xl` (1.5rem) for external containers.
*   **Structure:** No dividers. Separate the Artisan’s name (`title-md`) from their craft (`body-sm`) using 4px of vertical spacing. Separate the profile section from the pricing section using a background shift to `surface-container-low`.

### Input Fields
*   **Style:** Minimalist. Use `surface-container-highest` as the background with a `md` (0.75rem) corner radius. 
*   **Focus State:** Instead of a heavy border, the background should shift to `surface-container-lowest` and a `1px` "Ghost Border" of `primary` at 40% opacity should appear.

### Selection & Filtering (Chips)
*   **Filter Chips:** Use `secondary-container` (#bfddfe) for the selected state. This soft blue keeps the UI feeling "Modern" and "Clean" without the visual weight of the deep primary blue.

### The "Service Progress" Tracker (Platform Specific)
*   Instead of a standard progress bar, use a series of `surface-container-highest` pill shapes. The active state should be a `primary` pill that "glows" with a soft 4% shadow of the same color.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use `display-lg` typography for empty states or landing hero sections to create an editorial feel.
*   **Do** use `surface-container` shifts to group related information instead of drawing lines.
*   **Do** prioritize `primary` (#000c47) for "Trust" elements like verified badges and secure payment icons.
*   **Do** use `rounded-xl` for images to maintain the "Soft Minimalist" aesthetic.

### Don’t:
*   **Don’t** use pure black (#000000) for text. Always use `on-surface` (#171c1f) to maintain a premium, slightly softer contrast.
*   **Don’t** use "Standard" 4px or 8px rounding for main cards; it looks like a generic template. Use `xl` (1.5rem).
*   **Don’t** use `error` (#ba1a1a) for anything other than critical system failures. For "low funds" or "artisan busy," use `secondary` tones to keep the user calm.
*   **Don’t** crowd the edges. If a component feels tight, double the spacing. Modern, high-end design is defined by its "wasteful" (generous) use of space.