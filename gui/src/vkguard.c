// Imported from chiaki-ng-ultimate, commit ae63504b3db53b63de8f6f03ce6fa58d248bb894; upstream AGPL-3.0-only/OpenSSL exception. See REMOTEPLAY-RTX.md.
#include "vkguard.h"

#if defined(_WIN32) && defined(_MSC_VER)
#include <windows.h>

int chiaki_guarded_call(ChiakiGuardedFunc fn, void *ctx, unsigned long *out_code)
{
	*out_code = 0;
	__try
	{
		return fn(ctx);
	}
	__except(EXCEPTION_EXECUTE_HANDLER)
	{
		*out_code = GetExceptionCode();
		return 0;
	}
}
#else
int chiaki_guarded_call(ChiakiGuardedFunc fn, void *ctx, unsigned long *out_code)
{
	*out_code = 0;
	return fn(ctx);
}
#endif
