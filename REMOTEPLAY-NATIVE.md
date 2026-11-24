# RemotePlay Native

Windows-oriented experimental Chiaki-ng fork. All upstream licensing retained. No Veyra code, proprietary NVIDIA DLLs or capture-card integration.

AI update: existing trained FSRCNNX CNN-8 / CNN-16 shaders run on the GPU when upscaling by at least 1.2x. FSR for smaller enlargement. New adaptive controller downgrades on sustained render queue pressure (120ms), recovers gradually after three stable seconds. Stats show the selected filter. New profiles default to AI balanced; existing users can select it in Render Preset or Ctrl+O. At native resolution no AI enlargement occurs. This is not NVIDIA RTX Video Super Resolution or frame generation. Actual RTX VSR requires a separately licensed NVIDIA SDK/runtime and integration. No claims of tested GPU speed or superiority to PXPlay.
