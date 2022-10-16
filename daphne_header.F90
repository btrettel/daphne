#define CHECK(ARG1, ARG2) check(ARG1, ARG2, __FILE__, __LINE__)

#ifndef __F__
#define __PURE__
#define __NOTPURE__
#else
#define __PURE__ pure
#endif
