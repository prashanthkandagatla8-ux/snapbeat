"use client";

import React, { useState } from "react";

const BUTTON_ASSETS = {
  render: {
    src: "/assets/images/btn_render.png",
    alt: "RENDER",
    label: "RENDER REEL",
  },
  play: {
    src: "/assets/images/btn_play.png",
    alt: "PLAY",
    label: "PLAY",
  },
  download: {
    src: "/assets/images/btn_download.png",
    alt: "DOWNLOAD",
    label: "DOWNLOAD",
  },
  share: {
    src: "/assets/images/btn_share.png",
    alt: "SHARE",
    label: "SHARE",
  },
  delete: {
    src: "/assets/images/btn_delete.png",
    alt: "DELETE",
    label: "DELETE",
  },
};

export default function RetroMechanicalButton({
  variant = "render",
  onClick,
  disabled = false,
  className = "",
  title,
  children,
  ...props
}) {
  const isRedVariant =
    variant === "redMaster" ||
    variant === "red" ||
    variant === "red_button" ||
    variant === "redButton";

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      className={`btn-gold-radiant px-6 py-3 rounded-full text-xs sm:text-sm font-black tracking-wide flex items-center justify-center gap-2 shadow-[0_10px_30px_rgba(245,158,11,0.5)] ${
        disabled
          ? "opacity-40 cursor-not-allowed filter grayscale"
          : "cursor-pointer hover:scale-105 active:scale-95"
      } ${className}`}
      title={title || "Start Action"}
      aria-label={title || "Action Button"}
      aria-disabled={disabled}
      {...props}
    >
      {children ? (
        children
      ) : isRedVariant ? (
        <span>▶ START CREATING</span>
      ) : (
        <span>▶ {variant.toUpperCase()}</span>
      )}
    </button>
  );
}
