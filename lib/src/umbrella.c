#include "umbrella.h"
#include "schema.h"
#include "version.h"

const char *umbrella_hello(void)
{
    return UMBRELLA_GREETING;
}

const char *umbrella_version(void)
{
    return VERSION_STRING;
}
