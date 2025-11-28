# App Icon Design Guide

## Design Concept

Based on your logo, the app icon should be a simplified, recognizable version that works at all sizes.

---

## Recommended Design Option 1: Bold Orange Background

### Description
- **Background:** Solid vibrant orange (`#FF6B35`)
- **Foreground:** Two white "5"s stacked vertically
- **Accent:** Blue "X" (`#004E89`) crossing over the "5"s with slight transparency (80% opacity)

### Why This Works
- Highly recognizable at small sizes
- Orange background makes it stand out
- Simple design scales well
- Maintains brand identity

### Design Specifications
- **Canvas:** 1024x1024px
- **Background:** Solid fill `#FF6B35`
- **"5"s:** White, bold font, stacked vertically, centered
- **"X":** Blue `#004E89`, diagonal lines crossing the "5"s
- **Padding:** 10% margin on all sides

---

## Recommended Design Option 2: Minimal White Background

### Description
- **Background:** White or very light gray (`#F5F5F5`)
- **Foreground:** Two orange "5"s (`#FF6B35`) stacked vertically
- **Accent:** Blue "X" (`#004E89`) crossing over the "5"s
- **Border:** Optional thin orange border

### Why This Works
- Clean, professional look
- Good contrast
- Works well with iOS design language
- Orange "5"s are prominent

---

## Recommended Design Option 3: Simplified (For Small Sizes)

### Description
- **Background:** Orange gradient (from `#FF6B35` to `#FF8C5A`)
- **Foreground:** Single large white "5" in center
- **Accent:** Blue diagonal line crossing the "5" (simplified X)

### Why This Works
- Simplest design
- Works at very small sizes (20x20px)
- Still recognizable as your brand
- Modern, minimal aesthetic

---

## Design Tools

### Recommended Software
1. **Figma** (Free, web-based) - Best for design
2. **Sketch** (Mac only, paid)
3. **Adobe Illustrator** (Professional, paid)
4. **Canva** (Free, web-based) - Easiest for beginners

### Online Icon Generators
- **AppIcon.co** - Generates all sizes from one 1024x1024 image
- **IconKitchen** - Google's icon generator
- **MakeAppIcon** - Simple icon generator

---

## Step-by-Step: Creating the Icon

### Using Figma (Recommended)

1. **Create new file:**
   - File → New Design File
   - Set canvas to 1024x1024px

2. **Create background:**
   - Draw rectangle (1024x1024px)
   - Fill: `#FF6B35` (orange)
   - Lock the layer

3. **Add "5"s:**
   - Use Text tool
   - Font: SF Pro Display Bold (or similar bold sans-serif)
   - Size: ~400pt
   - Color: White
   - Type "5"
   - Duplicate and position second "5" below
   - Center both vertically and horizontally

4. **Add blue "X":**
   - Draw line from top-left to bottom-right
   - Stroke: `#004E89` (blue)
   - Width: ~80px
   - Opacity: 90%
   - Duplicate and rotate 90° for second line
   - Center both lines

5. **Export:**
   - Select all layers
   - Export as PNG
   - 1024x1024px
   - No transparency

### Using Canva (Easiest)

1. **Create custom size:**
   - Custom size: 1024x1024px

2. **Add background:**
   - Elements → Shapes → Rectangle
   - Fill: `#FF6B35`
   - Size: 1024x1024px

3. **Add text:**
   - Text → Add heading
   - Type "5"
   - Font: Bold, large size
   - Color: White
   - Duplicate and position

4. **Add lines:**
   - Elements → Lines
   - Color: `#004E89`
   - Draw diagonal lines

5. **Download:**
   - Download as PNG
   - 1024x1024px

---

## Testing Your Icon

### Test at Different Sizes
Before finalizing, test your icon at these sizes:
- **20x20px** - Notification badge
- **60x60px** - Home screen
- **1024x1024px** - App Store

### What to Check
- [ ] Is it recognizable at 20x20px?
- [ ] Do the "5"s read clearly?
- [ ] Is the blue "X" visible?
- [ ] Does it stand out on home screen?
- [ ] Is it distinct from other apps?

---

## Alternative: Hire a Designer

If you prefer professional help:
- **Fiverr** - $5-50 for app icon design
- **99designs** - Contest-based design
- **Dribbble** - Find professional designers
- **Upwork** - Hire freelance designers

---

## Quick Reference: Color Codes

- **Orange Primary:** `#FF6B35`
- **Blue Primary:** `#004E89`
- **White:** `#FFFFFF`
- **Background Gray:** `#F5F5F5`

---

## Next Steps

1. **Create the 1024x1024 icon** using one of the methods above
2. **Test at different sizes** to ensure it's recognizable
3. **Generate all required sizes** using AppIcon.co or similar
4. **Add to Xcode** in Assets.xcassets → AppIcon
5. **Test on device** to see how it looks on home screen

---

**Last Updated:** November 2025

