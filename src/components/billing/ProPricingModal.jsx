"use client";

import React from "react";
import { RetroStoreModal } from "./RetroStoreModal";

/**
 * ProPricingModal acts as a compatible alias for RetroStoreModal to ensure
 * consistency across all entry points without design or pricing conflicts.
 */
export function ProPricingModal(props) {
  return <RetroStoreModal {...props} />;
}

export default ProPricingModal;
