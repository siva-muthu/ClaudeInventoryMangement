---
name: create-architecture-ppt
description: Generates a PowerPoint presentation documenting the Factory Inventory Management System architecture. Use this skill when asked to create or update the architecture presentation.
---

# Create Architecture PowerPoint

Generate a professional PowerPoint file at `architecture.pptx` (project root) using `python-pptx` that documents the full architecture of the Factory Inventory Management System.

---

## Step 1 — Install python-pptx

```bash
pip install python-pptx
```

If `pip` is unavailable, try:
```bash
uv pip install python-pptx
```

---

## Step 2 — Generate the Presentation

Create a Python script at `scripts/gen_architecture_ppt.py` and run it. The script must build a 10-slide deck using the content and structure below.

### Script skeleton

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

# Design tokens (match app slate/gray palette)
COLOR_DARK   = RGBColor(0x0F, 0x17, 0x2A)   # #0f172a - headings
COLOR_MID    = RGBColor(0x64, 0x74, 0x8B)   # #64748b - body text
COLOR_LIGHT  = RGBColor(0xE2, 0xE8, 0xF0)   # #e2e8f0 - backgrounds
COLOR_ACCENT = RGBColor(0x3B, 0x82, 0xF6)   # #3b82f6 - blue accent
COLOR_WHITE  = RGBColor(0xFF, 0xFF, 0xFF)
COLOR_GREEN  = RGBColor(0x10, 0xB9, 0x81)   # #10b981
COLOR_AMBER  = RGBColor(0xF5, 0x9E, 0x0B)   # #f59e0b

prs = Presentation()
prs.slide_width  = Inches(13.33)
prs.slide_height = Inches(7.5)

def add_title_slide(prs, title, subtitle):
    """Blank layout with dark background."""
    ...

def add_content_slide(prs, title, bullet_points):
    """White slide with heading + bulleted body text."""
    ...

def add_two_column_slide(prs, title, left_heading, left_items, right_heading, right_items):
    """White slide split into two equal columns."""
    ...

# Build deck
add_title_slide(...)          # Slide 1 - Title
add_content_slide(...)        # Slide 2 - System Overview
add_two_column_slide(...)     # Slide 3 - Frontend
add_two_column_slide(...)     # Slide 4 - Backend
add_content_slide(...)        # Slide 5 - Data Layer
add_content_slide(...)        # Slide 6 - Data Flow
add_content_slide(...)        # Slide 7 - Filter System
add_content_slide(...)        # Slide 8 - API Endpoints
add_two_column_slide(...)     # Slide 9 - Pages / Views
add_content_slide(...)        # Slide 10 - Key Patterns

prs.save("architecture.pptx")
print("Saved: architecture.pptx")
```

---

## Step 3 — Slide Content

Use the exact content below for each slide.

---

### Slide 1 — Title (dark background #0f172a)

- **Title**: Factory Inventory Management System
- **Subtitle**: Application Architecture Overview
- **Footer detail**: Vue 3 + FastAPI + In-Memory Data · Full-Stack Demo

---

### Slide 2 — System Overview

**Heading**: System Architecture Overview

**Bullets**:
- Full-stack web application for factory inventory management
- Three-tier architecture: Frontend · Backend API · Data Layer
- Frontend: Vue 3 (port 3000) served by Vite dev server
- Backend: Python FastAPI (port 8001) with Uvicorn
- Data: JSON flat files loaded into memory at startup — no database
- Communication: REST API via Axios HTTP client

---

### Slide 3 — Frontend (two columns)

**Heading**: Frontend — Vue 3 + Vite

**Left column — Stack**:
- Vue 3 Composition API (`<script setup>`)
- Vite build tool & dev server
- Vue Router for client-side navigation
- Axios for HTTP requests
- Scoped CSS — no external UI library
- Custom SVG charts (no chart library)

**Right column — Structure**:
- `client/src/views/` — 7 page-level components
- `client/src/components/` — Reusable UI components
- `client/src/composables/` — Shared reactive logic
- `client/src/api.js` — Centralised API client
- `client/src/App.vue` — Root layout + sidebar
- `client/src/main.js` — App entry point

---

### Slide 4 — Backend (two columns)

**Heading**: Backend — Python FastAPI

**Left column — Stack**:
- Python 3.11+ with FastAPI framework
- Uvicorn ASGI server
- Pydantic v2 for request/response validation
- CORS middleware (allows localhost:3000)
- In-memory data store — no ORM, no database
- uv for dependency management

**Right column — Structure**:
- `server/main.py` — FastAPI app + all route handlers
- `server/mock_data.py` — Data loading + filtering logic
- `server/data/*.json` — Raw data files (orders, inventory, etc.)
- `server/requirements.txt` — Python dependencies
- All data loaded once at startup into module-level variables

---

### Slide 5 — Data Layer

**Heading**: Data Layer — JSON + In-Memory

**Bullets**:
- No database — all data lives in `server/data/` as JSON files
- Files: `orders.json`, `inventory.json`, `backlog.json`, `demand.json`, `spending.json`
- `mock_data.py` reads files once at startup into Python lists/dicts
- Filtering is done in-memory using Python list comprehensions
- Pydantic models validate every API response before it leaves the server
- Data mutations (e.g., creating a PO) update in-memory state only — resets on restart

---

### Slide 6 — Data Flow

**Heading**: End-to-End Data Flow

**Bullets** (use → arrows to show progression):
- 1 · User changes a filter in the FilterBar (Vue reactive ref updates)
- 2 · `useFilters` composable broadcasts the change to all views via shared state
- 3 · Each view calls its `loadData()` function with current filter values
- 4 · `client/src/api.js` builds the query string and fires an Axios GET request
- 5 · FastAPI receives the request, extracts query params, passes to `mock_data.py`
- 6 · `mock_data.py` filters in-memory lists and returns matching records
- 7 · FastAPI validates the result through Pydantic models and serialises to JSON
- 8 · Axios resolves the promise; Vue stores raw data in `ref()` variables
- 9 · Computed properties derive display values; Vue re-renders reactively

---

### Slide 7 — Filter System

**Heading**: Global Filter System

**Bullets**:
- Four global filters apply across all pages simultaneously
- Time Period — month selector (Jan–Dec or All Months), maps to `month` query param
- Location — warehouse selector (San Francisco / London / Tokyo), maps to `warehouse`
- Category — product category, maps to `category`
- Order Status — Delivered / Shipped / Processing / Backordered, maps to `status`
- Filters are stored in `useFilters` composable — single source of truth
- Inventory endpoints ignore `month` filter (no time dimension on stock levels)
- Revenue goal adjusts automatically: $800K/month or $9.6M for full year

---

### Slide 8 — API Endpoints

**Heading**: REST API Endpoints (base: http://localhost:8001)

**Bullets**:
- GET /api/inventory — Stock levels · filters: warehouse, category
- GET /api/inventory/{id} — Single item detail
- GET /api/orders — Order list · filters: warehouse, category, status, month
- GET /api/orders/{id} — Single order detail
- GET /api/dashboard/summary — KPI aggregates · all 4 filters
- GET /api/demand — Demand forecast data · no filters
- GET /api/backlog — Shortage/backlog items · no filters
- GET /api/spending/summary — Spend overview · no filters
- GET /api/spending/monthly — Monthly spend breakdown
- GET /api/spending/categories — Spend by category
- GET /api/spending/transactions — Transaction list

---

### Slide 9 — Pages / Views (two columns)

**Heading**: Application Pages

**Left column — Pages**:
- Overview (Dashboard) — `/`
- Inventory — `/inventory`
- Orders — `/orders`
- Finance — `/spending`
- Demand Forecast — `/demand`
- Restocking — `/restocking`
- Reports — `/reports`

**Right column — Dashboard sections**:
- KPI cards (turnover rate, fill rate, revenue, processing time)
- Order health donut chart + metrics
- Inventory value by category bar chart
- Order trend line chart (monthly)
- Inventory shortages table with Create PO actions
- Top products by revenue table

---

### Slide 10 — Key Design Patterns

**Heading**: Key Design Patterns

**Bullets**:
- Composable pattern — `useFilters`, `useAuth`, `useI18n` share state across components
- Ref / Computed split — raw API data in `ref()`, derived display values in `computed()`
- Centralised API client — all HTTP calls go through `client/src/api.js`, never directly from components
- Filter propagation — `watch([...filters], loadData)` triggers reload on any filter change
- Unique v-for keys — always use `sku`, `order_id`, `month` (never array index)
- Date validation — every `new Date(str)` call guarded with `isNaN(date.getTime())`
- Modal pattern — `<Teleport to="body">` + `<Transition>` for all overlay dialogs
- No external UI component library — custom scoped CSS with slate/gray design tokens

---

## Step 4 — Helper Functions

Implement these helpers inside the script for clean, consistent slides:

```python
def set_font(run, size_pt, bold=False, color=None):
    run.font.size = Pt(size_pt)
    run.font.bold = bold
    if color:
        run.font.color.rgb = color

def add_filled_rect(slide, left, top, width, height, fill_color):
    shape = slide.shapes.add_shape(
        MSO_SHAPE_TYPE.RECTANGLE,  # or use 1 (MSO_AUTO_SHAPE_TYPE.RECTANGLE)
        Inches(left), Inches(top), Inches(width), Inches(height)
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = fill_color
    shape.line.fill.background()  # no border
    return shape

def add_text_box(slide, text, left, top, width, height,
                 font_size=14, bold=False, color=None, align=PP_ALIGN.LEFT):
    txBox = slide.shapes.add_textbox(
        Inches(left), Inches(top), Inches(width), Inches(height)
    )
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    set_font(run, font_size, bold=bold, color=color or COLOR_DARK)
    return txBox
```

---

## Step 5 — Run and Verify

```bash
python scripts/gen_architecture_ppt.py
```

Confirm `architecture.pptx` exists in the project root and opens correctly. Report the slide count and file size to the user.

---

## Output

- File: `architecture.pptx` (project root)
- Script: `scripts/gen_architecture_ppt.py` (keep for future regeneration)
- 10 slides total
- Widescreen 16:9 format (13.33 × 7.5 inches)
