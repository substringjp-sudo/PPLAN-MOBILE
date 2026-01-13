# Flutter Migration Task List (PPLAN) - Design & Implementation Spec

This document outlines the **exact design specifications** and implementation tasks to replicate the PPLAN Next.js mobile web experience in Flutter.

## 0. Design System & Theming

### Colors (Mapped from `globals.css` & `DESIGN_SYSTEM.md`)
| Token | Hex ID | Flutter Code | Usage |
|-------|--------|--------------|-------|
| Primary | `#6366F1` | `Color(0xFF6366F1)` | Main Buttons, Active Icons, Brand |
| Secondary | `#EC4899` | `Color(0xFFEC4899)` | Accents, Like Buttons |
| Background (Dark) | `#111827` | `Color(0xFF111827)` | App Background (Scaffold) |
| Surface (Dark) | `#1F2937` | `Color(0xFF1F2937)` | Cards, Bottom Sheet |
| Text (White) | `#F9FAFB` | `Color(0xFFF9FAFB)` | Headings, Body Text |
| Muted Text | `#9CA3AF` | `Color(0xFF9CA3AF)` | Subtitles, Timestamps |
| Success | `#22C55E` | `Color(0xFF22C55E)` | Status Indicators |
| Error | `#EF4444` | `Color(0xFFEF4444)` | Delete Actions |

### Typography
- **Heading**: `GoogleFonts.outfit` (Bold/Black)
    - H1: 36px (Mobile), 48px (Tablet)
    - H2: 24px
- **Body**: `GoogleFonts.notoSansKr` (Regular/Medium)
    - Body: 16px, Height 1.5
    - Caption: 12px, Grey[400]
- **Handwriting**: `GoogleFonts.nanumPenScript` (for Notes/Canvas)

### Common Styling Constants
- **Border Radius**:
    - Cards: `24.0` (`rounded-[1.5rem]`) or `32.0` (`rounded-[2rem]`)
    - Buttons: `12.0` (`rounded-xl`)
    - Avatars: `Circle`
- **Shadows**:
    - Card Shadow: `BoxShadow(color: Colors.black.withOpacity(0.05), blur: 10, offset: 0, 4)`
    - Glow Effect: `BoxShadow(color: Primary.withOpacity(0.4), blur: 20)`

---

## 1. Project Foundation
- [x] **Initialize Flutter Project**
- [x] **Firebase Setup** (Auth, Firestore)
- [x] **State Management** (`flutter_riverpod`)
- [ ] **Configure Theme Data** (`lib/app/theme.dart`)
    - [ ] Create `AppColors` class with above palette.
    - [ ] Create `AppTextStyles` class.
    - [ ] Override `ThemeData.dark()` with `scaffoldBackgroundColor: AppColors.background`.

## 2. Navigation Shell (`MainNavigationScreen`)
- [x] **Bottom Navigation Bar**
    - Height: `60-80px`
    - Background: `Colors.white` (Light) or `Surface` (Dark)
    - Selected Item Color: `Primary (#6366F1)`
    - Unselected Item Color: `Grey[400]`
    - **Icons**: `LucideIcons` (Home, Map, Heart, User)
- [x] **Floating Action Button** (Center Docked)
    - Size: `64x64`
    - Background: `LinearGradient(topLeft: Indigo, bottomRight: Purple)`
    - Icon: `LucideIcons.pencil` (White, 28px)
    - Shadow: `Blur 10, Offset 0, 4` - Colored Glow.

## 3. Feature: Home / Feed (`src/app/[locale]/page.tsx`)
**Design Reference**: `src/consumer/ui/home/HomeContent.tsx`

### [ ] Home Header
- **Layout**: `Column`, Padding `20px`
- **Logo**: Row(`Icon(Bookmark, Indigo)`, `Text("PPLAN", Outfit, 24px)`)
- **Subtitle**: "다음 여행을 위한 멋진 장소를 발견해보세요" (`NotoSansKr`, 14px, `Grey[600]`)
- **Status**: [x] Implemented

### [ ] Post Card (`FeedTimelineItem.tsx`)
**Design Specs**:
- **Container**:
    - Margin: `bottom: 16`
    - Padding: `20`
    - Radius: `24`
    - Border: `Grey[200]` (Light Mode) / `White/5` (Dark Mode)
    - Bg: `White` / `White/5`
- **Header**:
    - Avatar: `32x32` (`w-8 h-8`), Radius `Circle`.
    - Name: `14px Bold`.
    - Timestamp: `10px Uppercase Bold Grey`.
    - Menu Icon: `LucideIcons.moreHorizontal`
- **Content**:
    - Title: `16px Bold #1E1B4B`
    - Description: `14px Grey[600]`, `maxLines: 2`.
    - **Visual Style**: Left Border `3px Solid Indigo`.
- **Attached Link (Google Maps)**:
    - Container: `Rounded 12`, `Border Grey[200]`.
    - Map Placeholder area: `Height 100px`.
    - Icon: `MapPin center Indigo`.
- **Footer**:
    - Like Button: `Icon(Heart)` - Pink if active.
    - "Read Story" Link: `Indigo Text + ArrowRight`.
- **Status**: [/] Basic layout done, needs specific styling refinements.

## 4. Feature: My Trip List (`src/consumer/ui/mytrip/TripList.tsx`)
**Design Specs**:
- **Grid Layout**: `SliverGrid` with 2 columns on Mobile.
- **Trip Card**:
    - Aspect Ratio: `3:4` (Portrait).
    - Cover Image: Full bleed, `BoxFit.cover`.
    - Overlay: Gradient `Black/60` -> Transparent (Bottom to Top).
    - **Info (Bottom)**:
        - Title: `White, Bold, 16px`.
        - Date: `White/80, 12px`.
        - Country Badge: `Glassmorphism (Blur 10, White/20)`.

## 5. Feature: Plan Detail (`src/consumer/ui/plan/LiteTimeline.tsx`)
**Design Specs (Daily Itinerary)**:
- **Header**:
    - Immersive Cover Image (`SliverAppBar`).
    - Expanded Title.
- **Timeline**:
    - Vertical Line: `Grey[300]`, dashed or solid (Left aligned).
    - **Day Header**:
        - "Day 1" Badge: `Indigo Background`, `White Text`, `Rounded Pill`.
        - Date Text: `14px Bold`.
- **Activity Item**:
    - **Time**: `12px Bold Grey` (Left column).
    - **Card**:
        - Layout: Row(Icon, Text).
        - Icon: Circle with Category Icon (Bed, Plane, Fork, Camera).
        - Bg: White (Shadow `sm`).

## 6. Feature: Auth (Login/Signup)
**Design Specs**:
- **Layout**: Center aligned, `maxWidth: 400`.
- **Input Fields**:
    - Bg: `Grey[100]` / `Grey[800]`.
    - Radius: `12`.
    - Padding: `16`.
- **Primary Button**:
    - Height: `56px`.
    - Bg: `Indigo`.
    - Text: `White, Bold, 16px`.
    - Width: `double.infinity`.

## 7. Migration Checklist
- [x] **Home Screen** (Basic UI)
- [ ] **My Trip Screen**
    - [ ] Create `TripCard` widget (Grid Item).
    - [ ] Create `MyTripList` listing (Firestore Query).
- [ ] **Trip Detail Screen**
    - [ ] `Sliver` Scroll View with Parallax Header.
    - [ ] `TimelineBuilder` widget.
- [ ] **Profile Screen**
    - [ ] User Stats (Trips, Following).
    - [ ] Grid of User's Travelogs.

