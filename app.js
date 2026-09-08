/**
 * SnapBeat Web Application — Client Logic
 * Full retro pop editing experience: audio trimming, photo reordering,
 * 22-preset templates, title card designer with live canvas preview, and video rendering.
 */

(() => {
  // ─── State ──────────────────────────────────────────────────────────
  const state = {
    serverUrl: localStorage.getItem('snapbeat_server_url') || (window.location.protocol.startsWith('http') ? window.location.origin : 'http://localhost:8000'),
    isDarkMode: localStorage.getItem('snapbeat_theme') !== 'light',
    isProMode: false,
    musicFile: null,
    musicDuration: 0,
    isFullTrack: true,
    audioStart: 0,
    audioEnd: 0,
    photos: [], // Array of { id: string, file: File|Blob, previewUrl: string }
    currentJobId: null,
    pollingTimer: null,
  };

  // ─── DOM References ──────────────────────────────────────────────────
  const dom = {
    // Switches
    switchMode: document.getElementById('switchMode'),
    labelBasic: document.getElementById('labelBasic'),
    labelPro: document.getElementById('labelPro'),
    switchTheme: document.getElementById('switchTheme'),
    labelDark: document.getElementById('labelDark'),
    labelLight: document.getElementById('labelLight'),
    
    // Server status
    btnOpenSettings: document.getElementById('btnOpenSettings'),
    statusDot: document.getElementById('statusDot'),
    lblServerStatus: document.getElementById('lblServerStatus'),
    modalSettings: document.getElementById('modalSettings'),
    btnCloseSettings: document.getElementById('btnCloseSettings'),
    inputServerUrl: document.getElementById('inputServerUrl'),
    btnTestConnection: document.getElementById('btnTestConnection'),
    btnSaveServerUrl: document.getElementById('btnSaveServerUrl'),
    serverTestFeedback: document.getElementById('serverTestFeedback'),

    // Pro Section
    cardPro: document.getElementById('cardPro'),
    selectTemplate: document.getElementById('selectTemplate'),
    switchDropIt: document.getElementById('switchDropIt'),
    selectAspectRatio: document.getElementById('selectAspectRatio'),
    inputTitleText: document.getElementById('inputTitleText'),
    selectTitleFont: document.getElementById('selectTitleFont'),
    selectTitleStyle: document.getElementById('selectTitleStyle'),
    selectTitleFrame: document.getElementById('selectTitleFrame'),
    radioTitleBgs: document.querySelectorAll('input[name="titleBg"]'),
    colorPickerContainer: document.getElementById('colorPickerContainer'),
    titleColorPicker: document.getElementById('titleColorPicker'),
    titleColorHex: document.getElementById('titleColorHex'),
    seekTitleDuration: document.getElementById('seekTitleDuration'),
    lblTitleDuration: document.getElementById('lblTitleDuration'),
    canvasTitlePreview: document.getElementById('canvasTitlePreview'),

    // Music Card
    inputMusicFile: document.getElementById('inputMusicFile'),
    btnSampleMusic: document.getElementById('btnSampleMusic'),
    tvMusicStatus: document.getElementById('tvMusicStatus'),
    audioPlayer: document.getElementById('audioPlayer'),
    audioTrimSection: document.getElementById('audioTrimSection'),
    rbAudioFull: document.getElementById('rbAudioFull'),
    rbAudioTrim: document.getElementById('rbAudioTrim'),
    trimSlidersContainer: document.getElementById('trimSlidersContainer'),
    lblTrimSummary: document.getElementById('lblTrimSummary'),
    lblAudioStart: document.getElementById('lblAudioStart'),
    seekAudioStart: document.getElementById('seekAudioStart'),
    lblAudioEnd: document.getElementById('lblAudioEnd'),
    seekAudioEnd: document.getElementById('seekAudioEnd'),

    // Photos Card
    inputPhotoFiles: document.getElementById('inputPhotoFiles'),
    photoDropZone: document.getElementById('photoDropZone'),
    tvPhotosStatus: document.getElementById('tvPhotosStatus'),
    photoStackList: document.getElementById('photoStackList'),

    // Render & Preview Card
    btnRender: document.getElementById('btnRender'),
    renderProgressContainer: document.getElementById('renderProgressContainer'),
    progressBar: document.getElementById('progressBar'),
    tvRenderStatus: document.getElementById('tvRenderStatus'),
    btnRetry: document.getElementById('btnRetry'),
    videoPreviewContainer: document.getElementById('videoPreviewContainer'),
    videoPreview: document.getElementById('videoPreview'),
    btnDownloadVideo: document.getElementById('btnDownloadVideo'),
    btnNewVideo: document.getElementById('btnNewVideo'),
  };

  // ─── Helpers ─────────────────────────────────────────────────────────
  const formatTime = (seconds) => {
    const s = Math.floor(seconds);
    const m = Math.floor(s / 60);
    const rem = s % 60;
    return `${m}:${rem.toString().padStart(2, '0')}`;
  };

  // ─── Theme Management ────────────────────────────────────────────────
  const applyTheme = (isDark) => {
    state.isDarkMode = isDark;
    document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    dom.switchTheme.checked = !isDark;

    if (isDark) {
      dom.labelDark.className = 'switch-label active';
      dom.labelLight.className = 'switch-label dimmed';
    } else {
      dom.labelDark.className = 'switch-label dimmed';
      dom.labelLight.className = 'switch-label active';
    }
    updateModeLabels();
    drawTitlePreview();
  };

  dom.switchTheme.addEventListener('change', (e) => {
    const isDark = !e.target.checked;
    localStorage.setItem('snapbeat_theme', isDark ? 'dark' : 'light');
    applyTheme(isDark);
  });

  // ─── Mode Management (BASIC / PRO) ──────────────────────────────────
  const updateModeLabels = () => {
    if (state.isProMode) {
      dom.labelBasic.className = 'switch-label dimmed';
      dom.labelPro.className = 'switch-label active';
      dom.cardPro.classList.remove('hidden');
    } else {
      dom.labelBasic.className = 'switch-label active';
      dom.labelPro.className = 'switch-label dimmed';
      dom.cardPro.classList.add('hidden');
    }
  };

  dom.switchMode.addEventListener('change', (e) => {
    state.isProMode = e.target.checked;
    updateModeLabels();
  });

  // ─── Server & Health Checks ──────────────────────────────────────────
  const checkServerHealth = async () => {
    try {
      const res = await fetch(`${state.serverUrl.replace(/\/$/, '')}/api/health`, {
        method: 'GET',
        headers: { 'Accept': 'application/json' },
      });
      if (res.ok) {
        dom.statusDot.className = 'status-dot online';
        dom.lblServerStatus.textContent = 'Server Connected';
        return true;
      }
    } catch (e) {
      // Ignore
    }
    dom.statusDot.className = 'status-dot offline';
    dom.lblServerStatus.textContent = 'Server Offline';
    return false;
  };

  dom.btnOpenSettings.addEventListener('click', () => {
    dom.inputServerUrl.value = state.serverUrl;
    dom.serverTestFeedback.className = 'test-feedback hidden';
    dom.modalSettings.classList.remove('hidden');
  });

  dom.btnCloseSettings.addEventListener('click', () => {
    dom.modalSettings.classList.add('hidden');
  });

  dom.modalSettings.querySelector('.modal-backdrop').addEventListener('click', () => {
    dom.modalSettings.classList.add('hidden');
  });

  dom.btnTestConnection.addEventListener('click', async () => {
    const testUrl = dom.inputServerUrl.value.trim().replace(/\/$/, '');
    dom.serverTestFeedback.className = 'test-feedback';
    dom.serverTestFeedback.textContent = 'Testing connection...';
    try {
      const start = Date.now();
      const res = await fetch(`${testUrl}/api/health`, { method: 'GET' });
      const elapsed = Date.now() - start;
      if (res.ok) {
        const data = await res.json();
        dom.serverTestFeedback.className = 'test-feedback success';
        dom.serverTestFeedback.textContent = `✅ Connected (${elapsed}ms) — Capacity: ${data.available ?? data.total_available ?? 'OK'} slots`;
      } else {
        dom.serverTestFeedback.className = 'test-feedback error';
        dom.serverTestFeedback.textContent = `❌ Server returned HTTP ${res.status}`;
      }
    } catch (e) {
      dom.serverTestFeedback.className = 'test-feedback error';
      dom.serverTestFeedback.textContent = `❌ Could not reach server: ${e.message}`;
    }
  });

  dom.btnSaveServerUrl.addEventListener('click', () => {
    state.serverUrl = dom.inputServerUrl.value.trim().replace(/\/$/, '');
    localStorage.setItem('snapbeat_server_url', state.serverUrl);
    dom.modalSettings.classList.add('hidden');
    checkServerHealth();
  });

  // ─── Music Management ────────────────────────────────────────────────
  const setMusicTrack = (file, name, url) => {
    state.musicFile = file;
    dom.tvMusicStatus.textContent = `🎵 ${name}`;
    dom.audioPlayer.src = url;
    dom.audioPlayer.classList.remove('hidden');

    const tempAudio = new Audio();
    tempAudio.src = url;
    tempAudio.onloadedmetadata = () => {
      state.musicDuration = Math.round(tempAudio.duration) || 30;
      state.audioStart = 0;
      state.audioEnd = state.musicDuration;
      state.isFullTrack = true;

      dom.audioTrimSection.classList.remove('hidden');
      dom.rbAudioFull.checked = true;
      dom.trimSlidersContainer.classList.add('hidden');

      dom.seekAudioStart.max = Math.max(0, state.musicDuration - 3);
      dom.seekAudioStart.value = 0;
      dom.seekAudioEnd.max = state.musicDuration;
      dom.seekAudioEnd.value = state.musicDuration;

      updateTrimLabels();
      checkRenderReadiness();
    };
  };

  dom.inputMusicFile.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const url = URL.createObjectURL(file);
    setMusicTrack(file, file.name, url);
  });

  dom.btnSampleMusic.addEventListener('click', async () => {
    dom.tvMusicStatus.textContent = "Loading sample track...";
    try {
      const res = await fetch('sample_music.mp3');
      if (!res.ok) throw new Error('Sample track file not found');
      const blob = await res.blob();
      const file = new File([blob], 'funk_smooth_party.mp3', { type: 'audio/mpeg' });
      const url = URL.createObjectURL(blob);
      setMusicTrack(file, 'Funk Smooth Party (Sample Tape)', url);
    } catch (e) {
      dom.tvMusicStatus.textContent = `Could not load sample: ${e.message}`;
    }
  });

  // Trimming sliders
  const updateTrimLabels = () => {
    dom.lblAudioStart.textContent = `Start Time: ${formatTime(state.audioStart)}`;
    dom.lblAudioEnd.textContent = `End Time: ${formatTime(state.audioEnd)}`;
    const dur = Math.max(0, state.audioEnd - state.audioStart);
    dom.lblTrimSummary.textContent = `Start: ${formatTime(state.audioStart)}  |  End: ${formatTime(state.audioEnd)}  (Duration: ${formatTime(dur)})`;
  };

  document.querySelectorAll('input[name="audioLengthMode"]').forEach((radio) => {
    radio.addEventListener('change', (e) => {
      state.isFullTrack = (e.target.value === 'full');
      if (state.isFullTrack) {
        dom.trimSlidersContainer.classList.add('hidden');
      } else {
        dom.trimSlidersContainer.classList.remove('hidden');
        updateTrimLabels();
      }
    });
  });

  dom.seekAudioStart.addEventListener('input', (e) => {
    state.audioStart = parseInt(e.target.value, 10);
    if (state.audioStart >= state.audioEnd - 2) {
      state.audioEnd = Math.min(state.musicDuration, state.audioStart + 3);
      dom.seekAudioEnd.value = state.audioEnd;
    }
    updateTrimLabels();
  });

  dom.seekAudioEnd.addEventListener('input', (e) => {
    state.audioEnd = parseInt(e.target.value, 10);
    if (state.audioEnd <= state.audioStart + 2) {
      state.audioStart = Math.max(0, state.audioEnd - 3);
      dom.seekAudioStart.value = state.audioStart;
    }
    updateTrimLabels();
  });

  // ─── Photos Management ───────────────────────────────────────────────
  const addPhotos = (fileList) => {
    const files = Array.from(fileList).filter(f => f.type.startsWith('image/'));
    const limit = 60;
    for (const f of files) {
      if (state.photos.length >= limit) break;
      const previewUrl = URL.createObjectURL(f);
      state.photos.push({
        id: Math.random().toString(36).substring(2, 9),
        file: f,
        previewUrl,
      });
    }
    renderPhotoStack();
    checkRenderReadiness();
  };

  const renderPhotoStack = () => {
    dom.photoStackList.innerHTML = '';
    const count = state.photos.length;

    if (count === 0) {
      dom.tvPhotosStatus.textContent = '0 photos (tap to load)';
      dom.photoStackList.classList.add('hidden');
      return;
    }

    dom.tvPhotosStatus.textContent = `${count} photo${count === 1 ? '' : 's'} loaded (Max 60)`;
    dom.photoStackList.classList.remove('hidden');

    state.photos.forEach((photo, index) => {
      const card = document.createElement('div');
      card.className = 'photo-card';

      card.innerHTML = `
        <div class="photo-thumb-wrap">
          <img src="${photo.previewUrl}" alt="Photo ${index + 1}" class="photo-thumb" />
          <span class="photo-badge">${index + 1}</span>
        </div>
        <div class="photo-actions">
          <button class="btn-icon btn-left" title="Move Left">◀</button>
          <button class="btn-icon btn-delete" title="Remove">✕</button>
          <button class="btn-icon btn-right" title="Move Right">▶</button>
        </div>
      `;

      // Event listeners for reordering
      card.querySelector('.btn-left').addEventListener('click', () => {
        if (index > 0) {
          const temp = state.photos[index];
          state.photos[index] = state.photos[index - 1];
          state.photos[index - 1] = temp;
          renderPhotoStack();
        }
      });

      card.querySelector('.btn-right').addEventListener('click', () => {
        if (index < state.photos.length - 1) {
          const temp = state.photos[index];
          state.photos[index] = state.photos[index + 1];
          state.photos[index + 1] = temp;
          renderPhotoStack();
        }
      });

      card.querySelector('.btn-delete').addEventListener('click', () => {
        state.photos.splice(index, 1);
        renderPhotoStack();
        checkRenderReadiness();
      });

      dom.photoStackList.appendChild(card);
    });
  };

  dom.inputPhotoFiles.addEventListener('change', (e) => {
    addPhotos(e.target.files);
    e.target.value = ''; // Reset
  });

  // Drag & drop support
  dom.photoDropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dom.photoDropZone.classList.add('dragover');
  });

  dom.photoDropZone.addEventListener('dragleave', () => {
    dom.photoDropZone.classList.remove('dragover');
  });

  dom.photoDropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dom.photoDropZone.classList.remove('dragover');
    if (e.dataTransfer && e.dataTransfer.files) {
      addPhotos(e.dataTransfer.files);
    }
  });

  // ─── Title Card Live Canvas Preview ──────────────────────────────────
  const drawTitlePreview = () => {
    const canvas = dom.canvasTitlePreview;
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;

    const titleText = (dom.inputTitleText.value.trim() || 'TITLE CARD PREVIEW').toUpperCase();
    const fontOption = dom.selectTitleFont.value;
    const styleOption = dom.selectTitleStyle.value;
    const frameOption = dom.selectTitleFrame.value;
    const bgRadio = document.querySelector('input[name="titleBg"]:checked');
    const bgMode = bgRadio ? bgRadio.value : 'black';

    // 1. Draw Background
    if (bgMode === 'color') {
      ctx.fillStyle = dom.titleColorHex.value || '#FF4D8D';
      ctx.fillRect(0, 0, width, height);
    } else if (bgMode === 'video') {
      // Simulate video background with animated/film vignette
      const grad = ctx.createRadialGradient(width/2, height/2, 50, width/2, height/2, width/2);
      grad.addColorStop(0, '#1E293B');
      grad.addColorStop(1, '#090D16');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, width, height);

      // Add subtle scanlines
      ctx.fillStyle = 'rgba(255, 255, 255, 0.03)';
      for (let y = 0; y < height; y += 4) {
        ctx.fillRect(0, y, width, 1);
      }
    } else {
      // Black background
      ctx.fillStyle = '#000000';
      ctx.fillRect(0, 0, width, height);
    }

    // 2. Decorative Frame
    ctx.save();
    if (frameOption === 'box') {
      ctx.strokeStyle = '#FFE14D';
      ctx.lineWidth = 4;
      ctx.strokeRect(30, 30, width - 60, height - 60);
    } else if (frameOption === 'viewfinder') {
      ctx.strokeStyle = '#3DD4FF';
      ctx.lineWidth = 4;
      const corner = 36;
      const pad = 36;
      // Top-left
      ctx.beginPath();
      ctx.moveTo(pad, pad + corner); ctx.lineTo(pad, pad); ctx.lineTo(pad + corner, pad);
      // Top-right
      ctx.moveTo(width - pad - corner, pad); ctx.lineTo(width - pad, pad); ctx.lineTo(width - pad, pad + corner);
      // Bottom-left
      ctx.moveTo(pad, height - pad - corner); ctx.lineTo(pad, height - pad); ctx.lineTo(pad + corner, height - pad);
      // Bottom-right
      ctx.moveTo(width - pad - corner, height - pad); ctx.lineTo(width - pad, height - pad); ctx.lineTo(width - pad, height - pad - corner);
      ctx.stroke();

      // Center crosshair
      ctx.beginPath();
      ctx.moveTo(width/2 - 10, height/2); ctx.lineTo(width/2 + 10, height/2);
      ctx.moveTo(width/2, height/2 - 10); ctx.lineTo(width/2, height/2 + 10);
      ctx.strokeStyle = 'rgba(61, 212, 255, 0.4)';
      ctx.lineWidth = 2;
      ctx.stroke();
    } else if (frameOption === 'double_line') {
      ctx.strokeStyle = '#FFE14D';
      ctx.lineWidth = 3;
      ctx.strokeRect(26, 26, width - 52, height - 52);
      ctx.strokeStyle = '#FF4D8D';
      ctx.lineWidth = 2;
      ctx.strokeRect(34, 34, width - 68, height - 68);
    } else if (frameOption === 'film_bars') {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.85)';
      ctx.fillRect(0, 0, width, 40);
      ctx.fillRect(0, height - 40, width, 40);
      ctx.fillStyle = '#FFE14D';
      ctx.fillRect(0, 38, width, 2);
      ctx.fillRect(0, height - 40, width, 2);
    }
    ctx.restore();

    // 3. Text Typography
    let fontFamily = 'Impact, sans-serif';
    let fontSize = 38;
    if (fontOption === 'serif') {
      fontFamily = "'Playfair Display', Georgia, serif";
      fontSize = 36;
    } else if (fontOption === 'clean') {
      fontFamily = "'Space Grotesk', -apple-system, sans-serif";
      fontSize = 34;
    } else if (fontOption === 'typewriter') {
      fontFamily = "'Courier Prime', Courier, monospace";
      fontSize = 32;
    } else if (fontOption === 'playful') {
      fontFamily = "'Work Sans', sans-serif";
      fontSize = 36;
    }

    ctx.font = `900 ${fontSize}px ${fontFamily}`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const cx = width / 2;
    const cy = height / 2;

    // 4. Visual Styles
    ctx.save();
    if (styleOption === 'classic') {
      // Yellow drop shadow
      ctx.fillStyle = '#000000';
      ctx.fillText(titleText, cx + 4, cy + 4);
      ctx.fillStyle = '#FFE14D';
      ctx.fillText(titleText, cx, cy);
    } else if (styleOption === 'neon') {
      // Multi-pass neon cyan glow
      ctx.shadowColor = '#00E5FF';
      ctx.shadowBlur = 24;
      ctx.fillStyle = '#FFFFFF';
      ctx.fillText(titleText, cx, cy);
      ctx.shadowBlur = 10;
      ctx.fillText(titleText, cx, cy);
    } else if (styleOption === '3d_retro') {
      // 80s isometric extrusion shadow
      for (let i = 8; i > 0; i--) {
        ctx.fillStyle = (i % 2 === 0) ? '#FF4D8D' : '#3DD4FF';
        ctx.fillText(titleText, cx + i, cy + i);
      }
      ctx.fillStyle = '#FFE14D';
      ctx.fillText(titleText, cx, cy);
    } else if (styleOption === 'cinematic') {
      // Wide tracked cinematic text
      ctx.letterSpacing = '8px';
      ctx.shadowColor = 'rgba(0,0,0,0.8)';
      ctx.shadowBlur = 8;
      ctx.fillStyle = '#F8FAFC';
      ctx.fillText(titleText, cx, cy);
    } else if (styleOption === 'badge') {
      // Rounded pill container
      const textMetrics = ctx.measureText(titleText);
      const textWidth = textMetrics.width;
      const pillWidth = textWidth + 40;
      const pillHeight = fontSize + 24;

      ctx.fillStyle = '#FFE14D';
      ctx.beginPath();
      ctx.roundRect(cx - pillWidth/2, cy - pillHeight/2, pillWidth, pillHeight, 14);
      ctx.fill();
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 3;
      ctx.stroke();

      ctx.fillStyle = '#000000';
      ctx.fillText(titleText, cx, cy);
    }
    ctx.restore();
  };

  // Listeners for title card controls
  dom.inputTitleText.addEventListener('input', drawTitlePreview);
  dom.selectTitleFont.addEventListener('change', drawTitlePreview);
  dom.selectTitleStyle.addEventListener('change', drawTitlePreview);
  dom.selectTitleFrame.addEventListener('change', drawTitlePreview);

  dom.radioTitleBgs.forEach(radio => {
    radio.addEventListener('change', (e) => {
      if (e.target.value === 'color') {
        dom.colorPickerContainer.classList.remove('hidden');
      } else {
        dom.colorPickerContainer.classList.add('hidden');
      }
      drawTitlePreview();
    });
  });

  dom.titleColorPicker.addEventListener('input', (e) => {
    dom.titleColorHex.value = e.target.value.toUpperCase();
    drawTitlePreview();
  });

  dom.titleColorHex.addEventListener('input', (e) => {
    if (/^#[0-9A-F]{6}$/i.test(e.target.value)) {
      dom.titleColorPicker.value = e.target.value;
      drawTitlePreview();
    }
  });

  dom.seekTitleDuration.addEventListener('input', (e) => {
    dom.lblTitleDuration.textContent = `${e.target.value}s`;
  });

  // ─── Render Pipeline ─────────────────────────────────────────────────
  const checkRenderReadiness = () => {
    const ready = (state.musicFile !== null && state.photos.length > 0);
    dom.btnRender.disabled = !ready;
  };

  const startRender = async () => {
    if (!state.musicFile || state.photos.length === 0) return;

    dom.btnRender.disabled = true;
    dom.btnRetry.classList.add('hidden');
    dom.videoPreviewContainer.classList.add('hidden');
    dom.renderProgressContainer.classList.remove('hidden');
    dom.progressBar.style.width = '10%';
    dom.tvRenderStatus.textContent = 'Packing media & uploading...';

    const formData = new FormData();
    formData.append('audio', state.musicFile, state.musicFile.name || 'music.mp3');

    state.photos.forEach((p, idx) => {
      formData.append('photos', p.file, `photo_${idx}.jpg`);
    });

    // Audio trimming params
    if (state.isFullTrack) {
      formData.append('full_track', 'true');
      formData.append('audio_start', '0');
      formData.append('audio_end', '0');
    } else {
      formData.append('full_track', 'false');
      formData.append('audio_start', state.audioStart.toString());
      formData.append('audio_end', state.audioEnd.toString());
    }

    // Pro mode parameters
    if (state.isProMode) {
      formData.append('template', dom.selectTemplate.value);
      if (dom.switchDropIt.checked) {
        formData.append('drop_it', 'true');
      }
      formData.append('frame', dom.selectAspectRatio.value);

      const titleText = dom.inputTitleText.value.trim();
      if (titleText) {
        formData.append('title_text', titleText);

        const bgRadio = document.querySelector('input[name="titleBg"]:checked');
        const bgVal = bgRadio ? bgRadio.value : 'black';
        const titleBg = (bgVal === 'color') ? (dom.titleColorHex.value.trim() || '#000000') : bgVal;
        formData.append('title_bg', titleBg);
        formData.append('title_duration', dom.seekTitleDuration.value);
        formData.append('title_font', dom.selectTitleFont.value);
        formData.append('title_style', dom.selectTitleStyle.value);
        formData.append('title_frame', dom.selectTitleFrame.value);
      }
    }

    try {
      const uploadUrl = `${state.serverUrl.replace(/\/$/, '')}/api/render/mobile`;
      const uploadRes = await fetch(uploadUrl, {
        method: 'POST',
        body: formData,
      });

      if (!uploadRes.ok) {
        const errorText = await uploadRes.text();
        throw new Error(`Upload failed (${uploadRes.status}): ${errorText}`);
      }

      const uploadData = await uploadRes.json();
      state.currentJobId = uploadData.job_id;

      dom.progressBar.style.width = '25%';
      dom.tvRenderStatus.textContent = 'Rendering in queue...';

      pollJobStatus(state.currentJobId);

    } catch (err) {
      handleRenderError(err.message);
    }
  };

  const pollJobStatus = (jobId) => {
    if (state.pollingTimer) clearInterval(state.pollingTimer);

    const statusUrl = `${state.serverUrl.replace(/\/$/, '')}/api/render/status/${jobId}`;

    state.pollingTimer = setInterval(async () => {
      try {
        const res = await fetch(statusUrl);
        if (!res.ok) throw new Error(`Status check HTTP ${res.status}`);
        const data = await res.json();

        if (data.status === 'done') {
          clearInterval(state.pollingTimer);
          dom.progressBar.style.width = '100%';
          dom.tvRenderStatus.textContent = 'Done! Video saved 🎬';
          dom.btnRender.disabled = false;

          // Display video preview
          const downloadUrl = `${state.serverUrl.replace(/\/$/, '')}/api/render/download/${jobId}`;
          dom.videoPreview.src = downloadUrl;
          dom.btnDownloadVideo.href = downloadUrl;
          dom.videoPreviewContainer.classList.remove('hidden');
          dom.videoPreview.play().catch(() => {}); // Autoplay if allowed
        } else if (data.status === 'failed' || data.status === 'error') {
          clearInterval(state.pollingTimer);
          throw new Error(data.error || 'Rendering failed on server');
        } else {
          // Progress update
          const pct = Math.min(95, Math.max(30, (data.progress || 0) * 100));
          dom.progressBar.style.width = `${pct}%`;
          dom.tvRenderStatus.textContent = data.message || 'Analyzing beats and rendering frames...';
        }
      } catch (err) {
        clearInterval(state.pollingTimer);
        handleRenderError(err.message);
      }
    }, 1200);
  };

  const handleRenderError = (msg) => {
    dom.tvRenderStatus.textContent = `❌ Error: ${msg}`;
    dom.progressBar.style.width = '0%';
    dom.btnRender.disabled = false;
    dom.btnRetry.classList.remove('hidden');
  };

  dom.btnRender.addEventListener('click', startRender);
  dom.btnRetry.addEventListener('click', startRender);

  dom.btnNewVideo.addEventListener('click', () => {
    dom.videoPreview.pause();
    dom.videoPreviewContainer.classList.add('hidden');
    dom.renderProgressContainer.classList.add('hidden');
    dom.tvRenderStatus.textContent = '';
  });

  const REMOTE_CONFIG_URL = 'https://raw.githubusercontent.com/prashanthkandagatla8-ux/snapbeat/main/config.json';

  const fetchRemoteConfig = async () => {
    try {
      const resp = await fetch(REMOTE_CONFIG_URL, { cache: 'no-store' });
      if (resp.ok) {
        const data = await resp.json();
        if (data.server_url && !localStorage.getItem('snapbeat_server_url')) {
          state.serverUrl = data.server_url.trim().replace(/\/+$/, '');
          checkServerHealth();
        }
      }
    } catch (e) {
      // Graceful fallback
    }
  };

  // ─── Initialization ──────────────────────────────────────────────────
  applyTheme(state.isDarkMode);
  updateModeLabels();
  checkServerHealth();
  fetchRemoteConfig();
  drawTitlePreview();
  checkRenderReadiness();

})();
