#include <dlfcn.h>
#include <stdio.h>

int main()
{
	int ret;
	int (*SrvInit)(void);
	void *handle = dlopen("libsrv_init.so", RTLD_LAZY);
	if (!handle) {
		fprintf(stderr, "failed to open libsrv_init.so\n");
		return -1;
	}

	SrvInit = dlsym(handle, "SrvInit");
	if (!SrvInit) {
		fprintf(stderr, "failed to find SrvInit symbol\n");
		return -1;
	}

	ret = SrvInit();

	if (ret) {
		fprintf(stderr, "failed to initialize server\n");
	}

	dlclose(handle);

	return ret;
}
