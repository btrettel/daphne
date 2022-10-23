#define ASSERT(ARG1, ARG2) assert(ARG1, ARG2, __FILE__, __LINE__)
#define CHECK_FLAG(ARG) check(ARG, __FILE__, __LINE__)

#ifndef __GIT__
#define __GIT__ "no revision specified"
#endif

#ifndef __F__
#define __PURE__
#define __NOTPURE__
#else
#define __PURE__ pure
#endif

#ifndef __ELF90__
#define __OUTERc__ outer:
#define __OUTER__ outer
#define __MIDDLEc__ middle:
#define __MIDDLE__ middle
#define __INNERc__ inner:
#define __INNER__ inner
#else
#define __OUTERc__
#define __OUTER__
#define __MIDDLEc__
#define __MIDDLE__
#define __INNERc__
#define __INNER__
#endif
