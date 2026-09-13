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
  height = "auto",
  width = "auto",
  title,
}) {
  const [isPressed, setIsPressed] = useState(false);

  if (variant === "redMaster") {
    return (
      <button
        type="button"
        disabled={disabled}
        onClick={onClick}
        onMouseDown={() => setIsPressed(true)}
        onMouseUp={() => setIsPressed(false)}
        onMouseLeave={() => setIsPressed(false)}
        onTouchStart={() => setIsPressed(true)}
        onTouchEnd={() => setIsPressed(false)}
        className={`relative inline-flex items-center justify-center transition-all transform duration-75 select-none focus:outline-none ${
          disabled ? "opacity-40 cursor-not-allowed filter grayscale" : "cursor-pointer active:scale-95 hover:brightness-105"
        } ${className}`}
        title={title}
      >
        <img
          src={isPressed ? "/assets/images/red_button_pressed.png" : "/assets/images/red_button_unpressed.png"}
          alt="Master Button"
          className="h-auto max-h-24 w-auto object-contain drop-shadow-[0_8px_16px_rgba(0,0,0,0.5)]"
        />
      </button>
    );
  }

  const asset = BUTTON_ASSETS[variant] || BUTTON_ASSETS.render;

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      onMouseDown={() => setIsPressed(true)}
      onMouseUp={() => setIsPressed(false)}
      onMouseLeave={() => setIsPressed(false)}
      onTouchStart={() => setIsPressed(true)}
      onTouchEnd={() => setIsPressed(false)}
      className={`group relative inline-flex items-center justify-center transition-all transform duration-75 select-none focus:outline-none ${
        disabled
          ? "opacity-40 cursor-not-allowed filter grayscale"
          : "cursor-pointer hover:brightness-110 active:scale-95"
      } ${className}`}
      title={title || asset.label}
    >
      <img
        src={asset.src}
        alt={asset.alt}
        style={{ height, width }}
        className={`object-contain transition-transform duration-75 ${
          isPressed ? "scale-95" : "scale-100"
        }`}
      />
    </button>
  );
}
