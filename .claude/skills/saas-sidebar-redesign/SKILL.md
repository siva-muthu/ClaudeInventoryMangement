---
name: saas-sidebar-redesign
description: Redesign the Vue 3 app layout from a top nav bar to a dark vertical sidebar (SaaS style) with SVG icons
---

# SaaS Sidebar Redesign

## What This Skill Does

Transforms `client/src/App.vue` from a horizontal sticky top nav bar (70px) into a modern SaaS-style layout with a **dark vertical sidebar** (240px wide) fixed on the left. All 7 navigation links get inline SVG icons. The content area (FilterBar + router-view) moves to the right of the sidebar.

**Only one file is modified:** `client/src/App.vue`

---

## Target Layout

```
┌──────────────────────────────────────────────────────────────┐
│ ┌──────────┐ ┌────────────────────────────────────────────┐  │
│ │  SIDEBAR │ │  CONTENT AREA                              │  │
│ │ #0f172a  │ │  ┌─ FilterBar ─────────────────────────┐  │  │
│ │          │ │  └─────────────────────────────────────┘  │  │
│ │ [Logo]   │ │  ┌─ <router-view> ────────────────────┐  │  │
│ │ [Title]  │ │  │                                     │  │  │
│ │──────────│ │  │   Page content                      │  │  │
│ │ ⊞ Overview│ │  │                                     │  │  │
│ │ □ Inventory│ │  └─────────────────────────────────────┘  │  │
│ │ ≡ Orders │ │                                            │  │
│ │ $ Finance│ └────────────────────────────────────────────┘  │
│ │ ↗ Demand │                                                 │
│ │ ↺ Restock│                                                 │
│ │ ≡ Reports│                                                 │
│ │──────────│                                                 │
│ │ [Lang]   │                                                 │
│ │ [Profile]│                                                 │
│ └──────────┘                                                 │
└──────────────────────────────────────────────────────────────┘
```

---

## Design Tokens

| Token              | Value                        |
|--------------------|------------------------------|
| Sidebar background | `#0f172a`                    |
| Sidebar text       | `#94a3b8` (inactive)         |
| Active text        | `#ffffff`                    |
| Active bg          | `rgba(255,255,255,0.08)`     |
| Active left border | `#2563eb` (3px)              |
| Hover bg           | `rgba(255,255,255,0.05)`     |
| Brand border       | `rgba(255,255,255,0.08)`     |
| Sidebar width      | `240px`                      |
| Content bg         | `#f8fafc` (unchanged)        |

---

## New App.vue Template

Replace the entire `<template>` block with:

```html
<template>
  <div class="app-layout">
    <aside class="sidebar">
      <!-- Brand -->
      <div class="sidebar-brand">
        <h1 class="brand-name">{{ t('nav.companyName') }}</h1>
        <span class="brand-subtitle">{{ t('nav.subtitle') }}</span>
      </div>

      <!-- Navigation -->
      <nav class="sidebar-nav">
        <router-link to="/" :class="{ active: $route.path === '/' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="1" y="1" width="6" height="6" rx="1"/><rect x="9" y="1" width="6" height="6" rx="1"/>
            <rect x="1" y="9" width="6" height="6" rx="1"/><rect x="9" y="9" width="6" height="6" rx="1"/>
          </svg>
          {{ t('nav.overview') }}
        </router-link>
        <router-link to="/inventory" :class="{ active: $route.path === '/inventory' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M8 1L14 4.5V11.5L8 15L2 11.5V4.5L8 1Z"/>
            <path d="M8 1V15M2 4.5L8 8L14 4.5M8 8V15"/>
          </svg>
          {{ t('nav.inventory') }}
        </router-link>
        <router-link to="/orders" :class="{ active: $route.path === '/orders' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="1" width="10" height="14" rx="1"/>
            <path d="M6 1V3H10V1M5 7H11M5 10H11M5 13H8"/>
          </svg>
          {{ t('nav.orders') }}
        </router-link>
        <router-link to="/spending" :class="{ active: $route.path === '/spending' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="1" y="9" width="3" height="6" rx="0.5"/>
            <rect x="6" y="5" width="3" height="10" rx="0.5"/>
            <rect x="11" y="1" width="3" height="14" rx="0.5"/>
          </svg>
          {{ t('nav.finance') }}
        </router-link>
        <router-link to="/demand" :class="{ active: $route.path === '/demand' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M1 12L5 7L8 10L11 5L15 2"/>
            <path d="M11 2H15V6"/>
          </svg>
          {{ t('nav.demandForecast') }}
        </router-link>
        <router-link to="/restocking" :class="{ active: $route.path === '/restocking' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13.5 8A5.5 5.5 0 1 1 8 2.5"/>
            <path d="M14 2L14 6L10 6"/>
            <path d="M14 2L8 2.5"/>
          </svg>
          {{ t('nav.restocking') }}
        </router-link>
        <router-link to="/reports" :class="{ active: $route.path === '/reports' }">
          <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="2" y="1" width="12" height="14" rx="1"/>
            <path d="M5 5H11M5 8H11M5 11H8"/>
          </svg>
          Reports
        </router-link>
      </nav>

      <!-- Footer: language + profile -->
      <div class="sidebar-footer">
        <LanguageSwitcher />
        <ProfileMenu
          @show-profile-details="showProfileDetails = true"
          @show-tasks="showTasks = true"
        />
      </div>
    </aside>

    <div class="content-wrapper">
      <FilterBar />
      <main class="main-content">
        <router-view />
      </main>
    </div>

    <ProfileDetailsModal
      :is-open="showProfileDetails"
      @close="showProfileDetails = false"
    />

    <TasksModal
      :is-open="showTasks"
      :tasks="tasks"
      @close="showTasks = false"
      @add-task="addTask"
      @delete-task="deleteTask"
      @toggle-task="toggleTask"
    />
  </div>
</template>
```

---

## New Global CSS

In the `<style>` block, **remove** the following selectors entirely:
- `.app` (replace with `.app-layout`)
- `.top-nav`
- `.nav-container`
- `.nav-container > .nav-tabs`
- `.nav-container > .language-switcher`
- `.logo`
- `.logo h1`
- `.subtitle`
- `.nav-tabs`
- `.nav-tabs a`
- `.nav-tabs a:hover`
- `.nav-tabs a.active`
- `.nav-tabs a.active::after`
- `.main-content` (replace with updated version)

**Add** these new CSS blocks (insert after the `body` block):

```css
/* ── SaaS Layout ───────────────────────────────────────────── */
.app-layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  min-height: 100vh;
}

.sidebar {
  background: #0f172a;
  width: 240px;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  z-index: 100;
}

.content-wrapper {
  margin-left: 240px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* ── Brand ─────────────────────────────────────────────────── */
.sidebar-brand {
  padding: 1.5rem 1.25rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.brand-name {
  font-size: 1rem;
  font-weight: 700;
  color: #ffffff;
  letter-spacing: -0.015em;
}

.brand-subtitle {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 0.25rem;
  display: block;
}

/* ── Nav Links ─────────────────────────────────────────────── */
.sidebar-nav {
  flex: 1;
  padding: 0.75rem 0;
}

.sidebar-nav a {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 1.25rem;
  color: #94a3b8;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  border-left: 3px solid transparent;
  transition: all 0.15s ease;
}

.sidebar-nav a:hover {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.05);
}

.sidebar-nav a.active {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.08);
  border-left-color: #2563eb;
}

.sidebar-nav svg {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

/* ── Footer ────────────────────────────────────────────────── */
.sidebar-footer {
  padding: 1rem 1.25rem;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

/* ── Content ───────────────────────────────────────────────── */
.main-content {
  flex: 1;
  padding: 1.5rem 2rem;
  max-width: 100%;
}
```

All other global utility classes (`.card`, `.badge`, `.stat-card`, `.table-container`, `.page-header`, `.stats-grid`, `.loading`, `.error`, etc.) remain **unchanged**.

---

## SVG Icon Reference

All icons use `viewBox="0 0 16 16"`, `fill="none"`, `stroke="currentColor"`, `stroke-width="1.5"`, `stroke-linecap="round"`, `stroke-linejoin="round"`.

| Route        | Icon         | Description                                       |
|--------------|--------------|---------------------------------------------------|
| `/`          | grid         | 4 rectangles in a 2×2 grid (4 `<rect>` elements) |
| `/inventory` | box          | Hexagonal 3D box / package outline                |
| `/orders`    | clipboard    | Rect with notch at top, 3 horizontal lines        |
| `/spending`  | bar-chart    | 3 vertical bars of increasing height              |
| `/demand`    | trending-up  | Angled line going up-right + arrow head           |
| `/restocking`| refresh      | Circular arrow loop                               |
| `/reports`   | file-text    | Rectangle with 3 horizontal lines inside          |

---

## Delegation Instructions

**MANDATORY**: Delegate all changes to `App.vue` to the `vue-expert` agent.

Provide the vue-expert agent with:
1. The full new `<template>` block (from the "New App.vue Template" section above)
2. The CSS changes — which selectors to remove and which new blocks to add
3. The `<script>` block is **unchanged** — do not modify it
4. Instruct the agent to write the complete updated `App.vue`

---

## Verification Steps

After implementation, use Playwright MCP tools to verify at `http://localhost:3000`:

1. **Sidebar visible** — dark left panel (#0f172a), 240px wide, no top nav bar
2. **Brand section** — company name + subtitle at top of sidebar
3. **All 7 nav links** — each with SVG icon and label text
4. **Active state** — current page link has white text + blue left border (3px, #2563eb)
5. **Hover state** — hovering a link shows slight white tint background
6. **Content area** — FilterBar appears above router-view content on the right
7. **Footer** — LanguageSwitcher and ProfileMenu visible at sidebar bottom
8. **Page navigation** — clicking each link loads the correct page without breaking layout
