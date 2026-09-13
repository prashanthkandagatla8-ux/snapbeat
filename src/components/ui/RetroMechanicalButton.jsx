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
  children,
  ...props
}) {
  const [isPressed, setIsPressed] = useState(false);

  const isRedVariant =
    variant === "redMaster" ||
    variant === "red" ||
    variant === "red_button" ||
    variant === "redButton";

  const handleKeyDown = (e) => {
    if (disabled) return;
    if (e.key === " " || e.key === "Enter") {
      setIsPressed(true);
    }
  };

  const handleKeyUp = (e) => {
    if (disabled) return;
    if (e.key === " " || e.key === "Enter") {
      setIsPressed(false);
    }
  };

  if (isRedVariant) {
    return (
      <button
        type="button"
        disabled={disabled}
        onClick={onClick}
        onMouseDown={() => !disabled && setIsPressed(true)}
        onMouseUp={() => setIsPressed(false)}
        onMouseLeave={() => setIsPressed(false)}
        onTouchStart={() => !disabled && setIsPressed(true)}
        onTouchEnd={() => setIsPressed(false)}
        onKeyDown={handleKeyDown}
        onKeyUp={handleKeyUp}
        onBlur={() => setIsPressed(false)}
        className={`relative inline-flex items-center justify-center transition-all transform duration-75 select-none focus:outline-none ${
          disabled
            ? "opacity-40 cursor-not-allowed filter grayscale"
            : "cursor-pointer active:scale-95 hover:brightness-105"
        } ${className}`}
        title={title || "Master Control"}
        aria-label={title || "Master Control Button"}
        aria-disabled={disabled}
        {...props}
      >
        <img
          src={
            isPressed
              ? "/assets/images/red_button_pressed.png"
              : "/assets/images/red_button_unpressed.png"
          }
          alt={title || (isPressed ? "Pressed Master Red Button" : "Master Red Button")}
          style={{
            height: height !== "auto" ? height : undefined,
            width: width !== "auto" ? width : undefined,
          }}
          className={`h-auto max-h-24 w-auto object-contain drop-shadow-[0_8px_16px_rgba(0,0,0,0.5)] transition-transform duration-75 select-none pointer-events-none ${
            isPressed ? "scale-95 translate-y-1 brightness-95" : "scale-100"
          }`}
          draggable={false}
        />
        {/* Hidden preload for instant tactile swap */}
        <img
          src="/assets/images/red_button_pressed.png"
          className="hidden"
          alt=""
          aria-hidden="true"
        />
        {children}
      </button>
    );
  }

  const asset = BUTTON_ASSETS[variant] || BUTTON_ASSETS.render;

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      onMouseDown={() => !disabled && setIsPressed(true)}
      onMouseUp={() => setIsPressed(false)}
      onMouseLeave={() => setIsPressed(false)}
      onTouchStart={() => !disabled && setIsPressed(true)}
      onTouchEnd={() => setIsPressed(false)}
      onKeyDown={handleKeyDown}
      onKeyUp={handleKeyUp}
      onBlur={() => setIsPressed(false)}
      className={`group relative inline-flex items-center justify-center transition-all transform duration-75 select-none focus:outline-none ${
        disabled
          ? "opacity-40 cursor-not-allowed filter grayscale"
          : "cursor-pointer hover:brightness-110 active:scale-95"
      } ${className}`}
      title={title || asset.label}
      aria-label={title || asset.label}
      aria-disabled={disabled}
      {...props}
    >
      <img
        src={asset.src}
        alt={asset.alt}
        style={{
          height: height !== "auto" ? height : undefined,
          width: width !== "auto" ? width : undefined,
        }}
        className={`object-contain transition-transform duration-75 select-none pointer-events-none ${
          isPressed ? "scale-95 translate-y-0.5" : "scale-100"
        }`}
        draggable={false}
      />
      {children}
    </button>
  );
}
