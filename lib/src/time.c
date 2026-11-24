// SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL

#include <chiaki/time.h>

#include <time.h>

#ifdef _WIN32
#include <windows.h>
#endif

CHIAKI_EXPORT uint64_t chiaki_time_now_monotonic_us()
{
#if _WIN32
	LARGE_INTEGER f;
	if(!QueryPerformanceFrequency(&f))
		return 0;
	LARGE_INTEGER v;
	if(!QueryPerformanceCounter(&v))
		return 0;
	// Split before multiplication to avoid overflowing after long system uptime.
	const uint64_t ticks = (uint64_t)v.QuadPart;
	const uint64_t frequency = (uint64_t)f.QuadPart;
	if(!frequency)
		return 0;
	return (ticks / frequency) * UINT64_C(1000000)
		+ ((ticks % frequency) * UINT64_C(1000000)) / frequency;
#else
	struct timespec time;
	clock_gettime(CLOCK_MONOTONIC, &time);
	return time.tv_sec * 1000000 + time.tv_nsec / 1000;
#endif
}
