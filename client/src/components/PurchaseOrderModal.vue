<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="isOpen && backlogItem" class="modal-overlay" @click="close">
        <div class="modal-container" @click.stop>
          <div class="modal-header">
            <h3 class="modal-title">
              {{ mode === 'view' ? 'Purchase Order Details' : 'Create Purchase Order' }}
            </h3>
            <button class="close-button" @click="close">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </button>
          </div>

          <div class="modal-body">
            <!-- Item summary header -->
            <div class="item-header">
              <div class="item-icon">
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                  <rect x="4" y="8" width="24" height="18" rx="2" stroke="currentColor" stroke-width="2"/>
                  <path d="M10 8V6a2 2 0 014 0v2M18 8V6a2 2 0 014 0v2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  <path d="M10 16h12M10 20h8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                </svg>
              </div>
              <div class="item-title-section">
                <h4 class="item-name">{{ backlogItem.item_name }}</h4>
                <div class="item-meta">
                  <span class="item-sku">SKU: {{ backlogItem.item_sku }}</span>
                  <span class="meta-divider">|</span>
                  <span class="item-order">Order: {{ backlogItem.order_id }}</span>
                </div>
              </div>
              <span class="priority-badge" :class="backlogItem.priority?.toLowerCase()">
                {{ backlogItem.priority }} Priority
              </span>
            </div>

            <!-- Shortage info cards -->
            <div class="shortage-summary">
              <div class="summary-card danger">
                <div class="summary-label">Shortage</div>
                <div class="summary-value">{{ shortage }} units</div>
              </div>
              <div class="summary-card warning">
                <div class="summary-label">Days Delayed</div>
                <div class="summary-value">{{ backlogItem.days_delayed }}</div>
              </div>
            </div>

            <!-- View mode: display existing PO -->
            <template v-if="mode === 'view'">
              <template v-if="existingPO">
                <div class="section-title">Purchase Order Information</div>
                <div class="info-grid">
                  <div class="info-item">
                    <div class="info-label">PO ID</div>
                    <div class="info-value po-id">{{ existingPO.id }}</div>
                  </div>
                  <div class="info-item">
                    <div class="info-label">Supplier</div>
                    <div class="info-value">{{ existingPO.supplier || 'N/A' }}</div>
                  </div>
                  <div class="info-item">
                    <div class="info-label">Quantity Ordered</div>
                    <div class="info-value">{{ existingPO.quantity }} units</div>
                  </div>
                  <div class="info-item">
                    <div class="info-label">Expected Delivery</div>
                    <div class="info-value">{{ formatDate(existingPO.expected_delivery) }}</div>
                  </div>
                </div>
                <div v-if="existingPO.notes" class="notes-display">
                  <div class="info-label">Notes</div>
                  <div class="notes-text">{{ existingPO.notes }}</div>
                </div>
              </template>
              <div v-else class="no-po-message">
                No purchase order found for this item.
              </div>
            </template>

            <!-- Create mode: form -->
            <template v-else>
              <div class="section-title">Order Details</div>
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label" for="po-sku">Item SKU</label>
                  <input
                    id="po-sku"
                    class="form-input readonly"
                    type="text"
                    :value="backlogItem.item_sku"
                    readonly
                  />
                </div>
                <div class="form-group">
                  <label class="form-label" for="po-order-id">Order ID</label>
                  <input
                    id="po-order-id"
                    class="form-input readonly"
                    type="text"
                    :value="backlogItem.order_id"
                    readonly
                  />
                </div>
                <div class="form-group">
                  <label class="form-label" for="po-quantity">
                    Quantity to Order <span class="required">*</span>
                  </label>
                  <input
                    id="po-quantity"
                    v-model.number="form.quantity"
                    class="form-input"
                    type="number"
                    min="1"
                    :class="{ 'input-error': formErrors.quantity }"
                  />
                  <span v-if="formErrors.quantity" class="error-text">{{ formErrors.quantity }}</span>
                </div>
                <div class="form-group">
                  <label class="form-label" for="po-supplier">
                    Supplier <span class="required">*</span>
                  </label>
                  <input
                    id="po-supplier"
                    v-model="form.supplier"
                    class="form-input"
                    type="text"
                    placeholder="Enter supplier name"
                    :class="{ 'input-error': formErrors.supplier }"
                  />
                  <span v-if="formErrors.supplier" class="error-text">{{ formErrors.supplier }}</span>
                </div>
                <div class="form-group">
                  <label class="form-label" for="po-delivery">
                    Expected Delivery <span class="required">*</span>
                  </label>
                  <input
                    id="po-delivery"
                    v-model="form.expected_delivery"
                    class="form-input"
                    type="date"
                    :class="{ 'input-error': formErrors.expected_delivery }"
                  />
                  <span v-if="formErrors.expected_delivery" class="error-text">{{ formErrors.expected_delivery }}</span>
                </div>
                <div class="form-group form-group-full">
                  <label class="form-label" for="po-notes">Notes (optional)</label>
                  <textarea
                    id="po-notes"
                    v-model="form.notes"
                    class="form-textarea"
                    rows="3"
                    placeholder="Add any notes about this purchase order..."
                  />
                </div>
              </div>
            </template>
          </div>

          <div class="modal-footer">
            <button class="btn-secondary" @click="close">
              {{ mode === 'view' ? 'Close' : 'Cancel' }}
            </button>
            <button
              v-if="mode === 'create'"
              class="btn-primary"
              @click="confirmOrder"
            >
              Confirm Order
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  },
  backlogItem: {
    type: Object,
    default: null
  },
  mode: {
    type: String,
    default: 'create'
  }
})

const emit = defineEmits(['close', 'po-created'])

// Computed: shortage amount
const shortage = computed(() => {
  if (!props.backlogItem) return 0
  return props.backlogItem.quantity_needed - props.backlogItem.quantity_available
})

// Computed: existing PO for view mode
const existingPO = computed(() => {
  if (!props.backlogItem) return null
  return props.backlogItem.purchase_order || null
})

// Form state
const form = ref({
  quantity: 0,
  supplier: '',
  expected_delivery: '',
  notes: ''
})

const formErrors = ref({
  quantity: '',
  supplier: '',
  expected_delivery: ''
})

// Reset form when modal opens or backlogItem changes
watch(
  () => [props.isOpen, props.backlogItem],
  ([open]) => {
    if (open && props.backlogItem && props.mode === 'create') {
      form.value = {
        quantity: shortage.value,
        supplier: '',
        expected_delivery: '',
        notes: ''
      }
      formErrors.value = { quantity: '', supplier: '', expected_delivery: '' }
    }
  },
  { immediate: true }
)

const validateForm = () => {
  let valid = true
  formErrors.value = { quantity: '', supplier: '', expected_delivery: '' }

  if (!form.value.quantity || form.value.quantity < 1) {
    formErrors.value.quantity = 'Quantity must be at least 1'
    valid = false
  }
  if (!form.value.supplier.trim()) {
    formErrors.value.supplier = 'Supplier is required'
    valid = false
  }
  if (!form.value.expected_delivery) {
    formErrors.value.expected_delivery = 'Expected delivery date is required'
    valid = false
  } else {
    const deliveryDate = new Date(form.value.expected_delivery)
    if (isNaN(deliveryDate.getTime())) {
      formErrors.value.expected_delivery = 'Invalid date'
      valid = false
    }
  }

  return valid
}

const generatePOId = () => {
  const timestamp = Date.now()
  return `PO-${timestamp}`
}

const confirmOrder = () => {
  if (!validateForm()) return

  const poData = {
    id: generatePOId(),
    backlog_item_id: props.backlogItem.id,
    item_name: props.backlogItem.item_name,
    item_sku: props.backlogItem.item_sku,
    order_id: props.backlogItem.order_id,
    quantity: form.value.quantity,
    supplier: form.value.supplier.trim(),
    expected_delivery: form.value.expected_delivery,
    notes: form.value.notes.trim(),
    created_at: new Date().toISOString()
  }

  emit('po-created', poData)
}

const close = () => {
  emit('close')
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return 'N/A'
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 1rem;
}

.modal-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #0f172a;
  letter-spacing: -0.025em;
}

.close-button {
  background: none;
  border: none;
  color: #64748b;
  cursor: pointer;
  padding: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition: all 0.15s ease;
}

.close-button:hover {
  background: #f1f5f9;
  color: #0f172a;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 2rem;
}

/* Item header */
.item-header {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  margin-bottom: 1.5rem;
}

.item-icon {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.item-title-section {
  flex: 1;
  min-width: 0;
}

.item-name {
  font-size: 1.125rem;
  font-weight: 700;
  color: #0f172a;
  margin: 0 0 0.375rem 0;
}

.item-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #64748b;
}

.item-sku,
.item-order {
  font-family: 'Monaco', 'Courier New', monospace;
  color: #2563eb;
}

.meta-divider {
  color: #cbd5e1;
}

/* Priority badge */
.priority-badge {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  flex-shrink: 0;
}

.priority-badge.high {
  background: #fecaca;
  color: #991b1b;
}

.priority-badge.medium {
  background: #fed7aa;
  color: #92400e;
}

.priority-badge.low {
  background: #dbeafe;
  color: #1e40af;
}

/* Shortage summary cards */
.shortage-summary {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 2rem;
}

.summary-card {
  padding: 1.25rem;
  border-radius: 10px;
  border: 2px solid;
}

.summary-card.danger {
  border-color: #fecaca;
  background: #fef2f2;
}

.summary-card.warning {
  border-color: #fed7aa;
  background: #fffbeb;
}

.summary-label {
  font-size: 0.813rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748b;
  margin-bottom: 0.5rem;
}

.summary-value {
  font-size: 1.875rem;
  font-weight: 700;
  color: #0f172a;
}

.summary-card.danger .summary-value {
  color: #dc2626;
}

.summary-card.warning .summary-value {
  color: #f59e0b;
}

/* Section title */
.section-title {
  font-size: 0.875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748b;
  margin-bottom: 1rem;
}

/* View mode: info grid */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-label {
  font-size: 0.813rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748b;
}

.info-value {
  font-size: 0.938rem;
  color: #0f172a;
  font-weight: 500;
}

.info-value.po-id {
  font-family: 'Monaco', 'Courier New', monospace;
  color: #2563eb;
}

.notes-display {
  margin-top: 1rem;
}

.notes-text {
  margin-top: 0.5rem;
  font-size: 0.938rem;
  color: #334155;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.75rem 1rem;
  line-height: 1.6;
}

.no-po-message {
  padding: 2rem;
  text-align: center;
  color: #64748b;
  background: #f8fafc;
  border-radius: 10px;
  border: 1px dashed #cbd5e1;
  font-size: 0.938rem;
}

/* Create mode: form */
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group-full {
  grid-column: 1 / -1;
}

.form-label {
  font-size: 0.813rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #64748b;
}

.required {
  color: #dc2626;
}

.form-input {
  padding: 0.625rem 0.875rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.938rem;
  color: #0f172a;
  font-family: inherit;
  background: white;
  transition: border-color 0.15s ease, box-shadow 0.15s ease;
  outline: none;
}

.form-input:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-input.readonly {
  background: #f8fafc;
  color: #64748b;
  cursor: default;
  font-family: 'Monaco', 'Courier New', monospace;
}

.form-input.input-error {
  border-color: #ef4444;
}

.form-textarea {
  padding: 0.625rem 0.875rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.938rem;
  color: #0f172a;
  font-family: inherit;
  background: white;
  resize: vertical;
  transition: border-color 0.15s ease, box-shadow 0.15s ease;
  outline: none;
  line-height: 1.5;
}

.form-textarea:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.error-text {
  font-size: 0.8rem;
  color: #dc2626;
  font-weight: 500;
}

/* Footer */
.modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
}

.btn-secondary {
  padding: 0.625rem 1.25rem;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-weight: 500;
  font-size: 0.875rem;
  color: #334155;
  cursor: pointer;
  transition: all 0.15s ease;
  font-family: inherit;
}

.btn-secondary:hover {
  background: #e2e8f0;
  border-color: #cbd5e1;
}

.btn-primary {
  padding: 0.625rem 1.25rem;
  background: #2563eb;
  border: 1px solid #2563eb;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.875rem;
  color: white;
  cursor: pointer;
  transition: all 0.15s ease;
  font-family: inherit;
}

.btn-primary:hover {
  background: #1d4ed8;
  border-color: #1d4ed8;
}

/* Modal transition animations */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform 0.2s ease;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  transform: scale(0.95);
}
</style>
