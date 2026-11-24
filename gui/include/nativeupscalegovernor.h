// SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL
#pragma once
#include <cstdint>
class NativeUpscaleGovernor {
    int requested_ = 0, level_ = 0;
    std::uint64_t pressure_since_ = 0, stable_since_ = 0;
public:
    int select(int requested, bool pressure, std::uint64_t now_us) {
        if (requested < 0) requested = 0;
        if (requested > 3) requested = 3;
        if (requested != requested_) {
            requested_ = requested; level_ = requested;
            pressure_since_ = stable_since_ = 0;
        }
        if (requested <= 1) return level_;
        if (pressure) {
            stable_since_ = 0;
            if (!pressure_since_ || now_us < pressure_since_) pressure_since_ = now_us;
            if (now_us - pressure_since_ >= 120000 && level_ > 1) {
                --level_; pressure_since_ = now_us;
            }
        } else {
            pressure_since_ = 0;
            if (!stable_since_ || now_us < stable_since_) stable_since_ = now_us;
            if (now_us - stable_since_ >= 3000000 && level_ < requested_) {
                ++level_; stable_since_ = now_us;
            }
        }
        return level_;
    }
};
