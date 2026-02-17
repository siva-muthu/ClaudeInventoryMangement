---
name: vue-component-analyzer
description: Analyze Vue 3 component structure and suggest optimizations for performance and code reuse. Use this skill when asked to audit, review, or optimize Vue components.
---

# Vue Component Analyzer

Perform a structured analysis of all Vue 3 components in `client/src/` and produce a prioritized report of performance improvements and code reuse opportunities.

---

## Step 1 — Scan the Codebase

Use the **Explore** agent to read every `.vue` file in:
- `client/src/views/*.vue` (8 view components)
- `client/src/components/*.vue` (9 reusable components)
- `client/src/App.vue` (root layout)

Also read `client/src/api.js` to understand how data is fetched.

---

## Step 2 — Performance Analysis

For each component, check for the following anti-patterns:

### 2a. Computed vs Method for Derived Data
Flag any `methods` that:
- Take no arguments
- Are called in the template with `()`
- Return a value derived from reactive state

**Why it matters:** Methods re-run on every render. Computed properties cache until dependencies change.

**Signal:** `methods: { filteredItems() { return this.items.filter(...) } }` called as `filteredItems()` in template.

### 2b. Expensive Logic Directly in Templates
Flag template expressions that contain:
- `.filter()`, `.map()`, `.reduce()`, `.sort()` inline in `:` bindings or `v-for`
- Ternary chains longer than one level
- String concatenation with multiple variables

**Why it matters:** These re-evaluate on every render tick. Move to `computed`.

### 2c. `v-for` Without Stable Keys
Flag any `v-for` that uses:
- `:key="index"` — index keys break list diffing on reorder/delete
- No `:key` at all

**Why it matters:** Vue's virtual DOM reconciliation relies on stable, unique keys. Use business-identity keys (`sku`, `id`, `order_number`, etc.).

**Per CLAUDE.md rule:** "Use unique keys in v-for (not `index`) — use `sku`, `month`, etc."

### 2d. Watchers That Should Be Computed
Flag `watch` entries that:
- Only update another `ref`/`data` property based on a source
- Do not trigger side effects (no API calls, no DOM manipulation, no `emit`)

**Why it matters:** A watcher that sets `B = f(A)` is always replaceable with `computed B = f(A)`.

### 2e. Missing `shallowRef` / `shallowReactive` for Large Objects
Flag `ref([...])` or `reactive({...})` holding large arrays (inventory, orders, transactions) where deep reactivity is not needed.

**Why it matters:** Deep reactive proxies on large arrays add overhead on every mutation.

### 2f. Repeated API Calls on the Same Data
Flag components that call the same API endpoint that another component on the same page also calls (compare `api.js` call sites across sibling components).

**Why it matters:** Duplicate requests waste network and make data inconsistent.

### 2g. Missing `v-once` for Static Content
Flag elements that render pure static strings or constants with no reactive bindings.

**Why it matters:** `v-once` skips re-rendering for truly static subtrees.

---

## Step 3 — Code Reuse Analysis

### 3a. Duplicated Loading/Error State Patterns
Flag components that each declare their own:
```js
const loading = ref(false)
const error = ref(null)
```
with identical try/catch/finally fetch wrappers.

**Opportunity:** Extract a `useAsyncData(fetchFn)` composable in `client/src/composables/useAsyncData.js`.

### 3b. Duplicated Filter-Driven Data Fetching
Flag views that each independently watch `filters` (from `FilterBar`) and re-fetch on change with the same boilerplate pattern.

**Opportunity:** Extract a `useFilteredFetch(apiFn, filters)` composable.

### 3c. Repeated Status Badge Markup
Flag templates containing repeated inline badge patterns like:
```html
<span :class="['badge', `badge-${status.toLowerCase()}`]">{{ status }}</span>
```
appearing in more than two components.

**Opportunity:** Extract a `<StatusBadge :status="status" />` component.

### 3d. Duplicated Table Structure
Flag views that each render a `<table>` with the same header/row skeleton (SKU, Item Name, Category, etc.) across Inventory, Orders, and Dashboard shortages tables.

**Opportunity:** Identify shared column sets and consider a generic `<DataTable :columns="cols" :rows="rows" />` component for the most-duplicated tables.

### 3e. Repeated Currency / Number Formatting
Flag components that each define their own `formatCurrency`, `formatNumber`, or `formatPercent` helper inline.

**Opportunity:** Move to `client/src/utils/format.js` and import once.

### 3f. Repeated Date Parsing Guards
Per CLAUDE.md: "Validate dates before `.getMonth()` calls." Flag components that each duplicate the same date-validation guard.

**Opportunity:** Extract to `client/src/utils/date.js`.

---

## Step 4 — Output Format

Produce the report in this exact structure:

```
## Vue Component Analysis Report

### Summary
- X performance issues found across Y files
- Z code reuse opportunities found

---

### Performance Issues  (sorted: High → Medium → Low)

#### [HIGH] <Issue Title>
- **File:** `client/src/views/Example.vue:42`
- **Problem:** <1-2 sentence description>
- **Fix:**
  ```js
  // Before
  ...
  // After
  ...
  ```

---

### Code Reuse Opportunities  (sorted by impact)

#### [HIGH] Extract `useAsyncData` composable
- **Affects:** `Dashboard.vue`, `Inventory.vue`, `Orders.vue`, `Spending.vue` (4 files)
- **Problem:** Each component duplicates loading/error state and fetch boilerplate.
- **Proposed composable:** `client/src/composables/useAsyncData.js`
  ```js
  // Suggested API
  const { data, loading, error } = useAsyncData(() => api.getInventory(filters))
  ```

---

### Quick Wins  (changes under 5 minutes each)
1. ...
2. ...

### Recommended Implementation Order
1. ...
2. ...
```

---

## Step 5 — Delegation Rules

- **Read-only analysis only** — do not edit any files unless the user explicitly asks after seeing the report.
- Use the **Explore** agent for the initial full codebase scan to avoid filling the context window.
- After the Explore agent returns findings, do the detailed analysis yourself using targeted `Read` calls on flagged files.
- Reference exact file paths and line numbers in every finding (format: `file:line`).
- Do not flag issues that are already handled correctly — only report genuine problems.
- If a pattern appears in only one place, it is not a reuse opportunity — require at least **two** occurrences before flagging duplication.

---

## Project-Specific Context

- **Views:** `client/src/views/` — Dashboard, Inventory, Orders, Spending, Demand, Restocking, Reports, Backlog
- **Components:** `client/src/components/` — modals, FilterBar, LanguageSwitcher, ProfileMenu
- **API:** `client/src/api.js` — all fetch calls go through this module
- **Filters:** 4 global filters (Time Period, Warehouse, Category, Order Status) passed as query params
- **Reactivity pattern:** Raw data in `ref` (`allOrders`, `inventoryItems`), derived data in `computed`
- **Known issue to skip:** `PurchaseOrderModal` is referenced but not yet implemented — do not flag this as a code issue
