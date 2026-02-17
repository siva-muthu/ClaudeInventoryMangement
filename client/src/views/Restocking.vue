<template>
  <div class="restocking">
    <div class="page-header">
      <h2>{{ t('restocking.title') }}</h2>
      <p>{{ t('restocking.description') }}</p>
    </div>

    <div v-if="loading" class="loading">{{ t('common.loading') }}</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <!-- Budget Section -->
      <div class="card budget-card">
        <div class="card-header">
          <h3 class="card-title">{{ t('restocking.budgetLabel') }}</h3>
          <div class="budget-display">
            <span class="budget-amount">${{ budget.toLocaleString() }}</span>
            <span :class="['budget-remaining', remainingBudgetClass]">
              {{ t('restocking.budgetRemaining') }}: ${{ remainingBudget.toLocaleString() }}
            </span>
          </div>
        </div>
        <input
          type="range"
          v-model.number="budget"
          min="0"
          max="50000"
          step="500"
          class="budget-slider"
        />
        <div class="budget-range-labels">
          <span>$0</span>
          <span>$50,000</span>
        </div>
      </div>

      <!-- Stats Row -->
      <div class="stats-grid">
        <div class="stat-card info">
          <div class="stat-label">{{ t('restocking.recommendedItems') }}</div>
          <div class="stat-value">{{ withinBudgetSkus.size }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">{{ t('restocking.totalCost') }}</div>
          <div class="stat-value">${{ totalSelectedCost.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 }) }}</div>
        </div>
        <div class="stat-card warning">
          <div class="stat-label">{{ t('restocking.overBudget') }}</div>
          <div class="stat-value">{{ recommendations.length - withinBudgetSkus.size }}</div>
        </div>
      </div>

      <!-- Success Message -->
      <div v-if="orderSuccess" class="success-banner">
        {{ t('restocking.orderPlaced') }}
      </div>

      <!-- Recommendations Table -->
      <div class="card">
        <div class="card-header">
          <h3 class="card-title">{{ t('restocking.recommendedItems') }} ({{ recommendations.length }})</h3>
        </div>
        <div v-if="recommendations.length === 0" class="empty-state">
          {{ t('restocking.noRecommendations') }}
        </div>
        <div v-else class="table-container">
          <table class="restock-table">
            <thead>
              <tr>
                <th class="col-check"></th>
                <th>{{ t('restocking.table.sku') }}</th>
                <th>{{ t('restocking.table.itemName') }}</th>
                <th>{{ t('restocking.table.category') }}</th>
                <th>{{ t('restocking.table.trend') }}</th>
                <th class="col-num">{{ t('restocking.table.currentDemand') }}</th>
                <th class="col-num">{{ t('restocking.table.forecastedDemand') }}</th>
                <th class="col-num">{{ t('restocking.table.demandGap') }}</th>
                <th class="col-num">{{ t('restocking.table.restockQty') }}</th>
                <th class="col-num">{{ t('restocking.table.unitCost') }}</th>
                <th class="col-num">{{ t('restocking.table.totalCost') }}</th>
                <th>{{ t('restocking.table.leadTime') }}</th>
                <th>{{ t('restocking.table.status') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in recommendations"
                :key="item.item_sku"
                :class="['restock-row', withinBudgetSkus.has(item.item_sku) ? 'row-within-budget' : 'row-over-budget']"
              >
                <td class="col-check">
                  <input
                    type="checkbox"
                    :checked="selectedSkus.has(item.item_sku)"
                    @change="toggleSku(item.item_sku)"
                  />
                </td>
                <td><code>{{ item.item_sku }}</code></td>
                <td class="item-name-cell">{{ item.item_name }}</td>
                <td>{{ item.category }}</td>
                <td>
                  <span :class="['badge', item.trend]">{{ item.trend }}</span>
                </td>
                <td class="col-num">{{ item.current_demand.toLocaleString() }}</td>
                <td class="col-num">{{ item.forecasted_demand.toLocaleString() }}</td>
                <td class="col-num">{{ item.demand_gap.toLocaleString() }}</td>
                <td class="col-num"><strong>{{ item.restock_quantity.toLocaleString() }}</strong></td>
                <td class="col-num">${{ item.unit_cost.toFixed(2) }}</td>
                <td class="col-num"><strong>${{ item.estimated_total_cost.toLocaleString() }}</strong></td>
                <td>{{ item.lead_time_days }}d</td>
                <td>
                  <span v-if="withinBudgetSkus.has(item.item_sku)" class="badge success">
                    {{ t('restocking.withinBudget') }}
                  </span>
                  <span v-else class="badge danger">
                    {{ t('restocking.overBudget') }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Place Order Button -->
        <div class="order-footer">
          <div class="order-summary">
            <span>{{ selectedItems.length }} items selected</span>
            <span class="order-total">Total: ${{ totalSelectedCost.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 }) }}</span>
          </div>
          <button
            class="btn-primary"
            :disabled="selectedItems.length === 0 || budget === 0 || submitting"
            @click="placeOrder"
          >
            {{ submitting ? t('common.loading') : t('restocking.placeOrder') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, onMounted } from 'vue'
import { api } from '../api'
import { useI18n } from '../composables/useI18n'

export default {
  name: 'Restocking',
  setup() {
    const { t } = useI18n()

    const budget = ref(10000)
    const recommendations = ref([])
    const selectedSkus = ref(new Set())
    const loading = ref(true)
    const error = ref(null)
    const submitting = ref(false)
    const orderSuccess = ref(false)

    const loadRecommendations = async () => {
      try {
        loading.value = true
        error.value = null
        recommendations.value = await api.getRestockingRecommendations()
      } catch (err) {
        error.value = 'Failed to load recommendations: ' + err.message
      } finally {
        loading.value = false
      }
    }

    // Greedy fill: which items fit in the budget (in priority order)
    const withinBudgetSkus = computed(() => {
      let remaining = budget.value
      const result = new Set()
      for (const item of recommendations.value) {
        if (item.estimated_total_cost <= remaining) {
          result.add(item.item_sku)
          remaining -= item.estimated_total_cost
        }
      }
      return result
    })

    // When budget changes, auto-select items that fit
    watch(withinBudgetSkus, (newSet) => {
      selectedSkus.value = new Set(newSet)
    })

    const toggleSku = (sku) => {
      const next = new Set(selectedSkus.value)
      if (next.has(sku)) {
        next.delete(sku)
      } else {
        next.add(sku)
      }
      selectedSkus.value = next
    }

    const selectedItems = computed(() =>
      recommendations.value.filter(i => selectedSkus.value.has(i.item_sku))
    )

    const totalSelectedCost = computed(() =>
      selectedItems.value.reduce((sum, i) => sum + i.estimated_total_cost, 0)
    )

    const remainingBudget = computed(() => budget.value - totalSelectedCost.value)

    const remainingBudgetClass = computed(() => {
      const pct = budget.value > 0 ? totalSelectedCost.value / budget.value : 0
      if (pct >= 1) return 'remaining-over'
      if (pct >= 0.8) return 'remaining-warn'
      return 'remaining-ok'
    })

    const placeOrder = async () => {
      submitting.value = true
      orderSuccess.value = false
      try {
        await api.createRestockingOrder({
          items: selectedItems.value.map(i => ({
            sku: i.item_sku,
            name: i.item_name,
            quantity: i.restock_quantity,
            unit_cost: i.unit_cost,
            category: i.category
          })),
          budget: budget.value,
          total_cost: totalSelectedCost.value
        })
        orderSuccess.value = true
        selectedSkus.value = new Set()
      } catch (err) {
        error.value = 'Failed to place order: ' + err.message
      } finally {
        submitting.value = false
      }
    }

    onMounted(loadRecommendations)

    return {
      t,
      budget,
      recommendations,
      selectedSkus,
      loading,
      error,
      submitting,
      orderSuccess,
      withinBudgetSkus,
      toggleSku,
      selectedItems,
      totalSelectedCost,
      remainingBudget,
      remainingBudgetClass,
      placeOrder
    }
  }
}
</script>

<style scoped>
.budget-card .card-header {
  flex-wrap: wrap;
  gap: 0.75rem;
}

.budget-display {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.budget-amount {
  font-size: 1.5rem;
  font-weight: 700;
  color: #0f172a;
}

.budget-remaining {
  font-size: 0.938rem;
  font-weight: 600;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
}

.remaining-ok {
  background: #d1fae5;
  color: #065f46;
}

.remaining-warn {
  background: #fed7aa;
  color: #92400e;
}

.remaining-over {
  background: #fecaca;
  color: #991b1b;
}

.budget-slider {
  width: 100%;
  margin: 1rem 0 0.25rem;
  accent-color: #2563eb;
  cursor: pointer;
}

.budget-range-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.success-banner {
  background: #d1fae5;
  border: 1px solid #6ee7b7;
  color: #065f46;
  padding: 0.875rem 1rem;
  border-radius: 8px;
  margin-bottom: 1.25rem;
  font-weight: 500;
}

.restock-table {
  width: 100%;
}

.col-check {
  width: 40px;
  text-align: center;
}

.col-num {
  text-align: right;
}

.item-name-cell {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.row-within-budget {
  background: #f0fdf4;
}

.row-within-budget:hover {
  background: #dcfce7;
}

.row-over-budget {
  opacity: 0.55;
}

.row-over-budget:hover {
  background: #fef2f2;
  opacity: 0.75;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  margin-top: 1rem;
  border-top: 1px solid #e2e8f0;
}

.order-summary {
  display: flex;
  gap: 1.5rem;
  color: #475569;
  font-size: 0.938rem;
}

.order-total {
  font-weight: 700;
  color: #0f172a;
}

.btn-primary {
  background: #2563eb;
  color: white;
  border: none;
  padding: 0.625rem 1.5rem;
  border-radius: 6px;
  font-size: 0.938rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background: #1d4ed8;
}

.btn-primary:disabled {
  background: #94a3b8;
  cursor: not-allowed;
}
</style>
