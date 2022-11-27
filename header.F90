#define ASSERT(ARG1, ARG2) assert(ARG1, ARG2, __FILE__, __LINE__)
#define CHECK_FLAG(ARG) check_flag(ARG, __FILE__, __LINE__)
#define __WRITEFILELINE__ write(unit=*, fmt=*) __FILE__, __LINE__
