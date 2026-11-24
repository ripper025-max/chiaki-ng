// Imported from chiaki-ng-ultimate, commit ae63504b3db53b63de8f6f03ce6fa58d248bb894; upstream AGPL-3.0-only/OpenSSL exception. See REMOTEPLAY-RTX.md.
#ifndef CHIAKI_GUI_FLOWFG_H
#define CHIAKI_GUI_FLOWFG_H

#include <libplacebo/gpu.h>
#include <libplacebo/log.h>

#include <memory>

// Vendor neutral frame interpolation built from libplacebo compute shaders,
// so it runs on any GPU and OS that chiaki-ng's Vulkan renderer runs on.
//
// Pipeline per stream frame:
//  1. Luma pyramid of the new frame (1/4 resolution and coarser).
//  2. Symmetric block matching, coarse to fine: for every block of the
//     in-between frame it looks for the motion `v` that makes
//     prev(p - v/2) and cur(p + v/2) agree. Coarser levels, neighbours and
//     the previous frame's motion seed the finer levels, which only refine.
//  3. A clean-up pass that re-picks each block's vector among its neighbours
//     to remove outliers, and a scene cut check on the coarsest level.
//  4. Synthesis at display resolution for each requested time `t`: both
//     frames are warped along the motion and blended; where they disagree
//     (occlusions, mismatches) it leans on the nearer frame, and across a
//     scene cut it repeats the nearer frame.
class FlowInterpolator
{
public:
    FlowInterpolator(pl_log log, pl_gpu gpu);
    ~FlowInterpolator();
    FlowInterpolator(const FlowInterpolator &) = delete;
    FlowInterpolator &operator=(const FlowInterpolator &) = delete;

    // Checks the GPU capabilities and creates the shader dispatcher.
    bool init();

    // `prev` and `cur` are sampleable RGBA textures of equal size, `outputs`
    // storable RGBA8 textures of that size. Generates `count` frames at the
    // times in `times` (0 = prev, 1 = cur). With `prev` null only the analysis
    // of `cur` is prepared for the next call (start of a sequence).
    bool interpolate(pl_tex prev, pl_tex cur, pl_tex const *outputs, const float *times, int count);

    // Motion vectors for DLSS Frame Generation: writes, for each pixel of
    // `cur`, the displacement to the same content in `prev` in pixels into the
    // storable two-channel float texture `out` (same size as `cur`). With
    // `prev` null only the analysis of `cur` is prepared and `written` stays
    // false.
    bool motionVectors(pl_tex prev, pl_tex cur, pl_tex out, bool *written);

    // Drops all size dependent state.
    void invalidate();

    // Resolution of the motion analysis relative to the frames: 4 = 1/4
    // (fast), 2 = 1/2 (finer motion around small details such as HUD text,
    // about four times the analysis work).
    void setAnalysisScale(int scale);
    int analysisScale() const;

    // Average GPU time per stream frame in milliseconds (0 if unknown).
    float gpuTimeMs() const;

private:
    bool analyze(pl_tex prev, pl_tex cur, float anchor, bool &analyzed);

    struct Impl;
    std::unique_ptr<Impl> impl;
};

#endif // CHIAKI_GUI_FLOWFG_H
