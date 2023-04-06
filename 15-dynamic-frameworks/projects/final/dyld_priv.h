@import Foundation;


//
// Returns path used by dyld for standard dyld shared cache file for the current arch.
//
// Exists in Mac OS X 10.11 and later
extern const char* dyld_shared_cache_file_path(void);



//
// Update all bindings on specified image.
// Looks for uses of 'replacement' and changes it to 'replacee'.
// NOTE: this is less safe than using static interposing via DYLD_INSERT_LIBRARIES
// because the running program may have already copy the pointer values to other
// locations that dyld does not know about.
//
struct dyld_interpose_tuple {
    const void* replacement;
    const void* replacee;
};
extern void dyld_dynamic_interpose(const struct mach_header* mh, const struct dyld_interpose_tuple array[], size_t count);


struct dyld_shared_cache_dylib_text_info {
    uint64_t        version;        // current version 2
    // following fields all exist in version 1
    uint64_t        loadAddressUnslid;
    uint64_t        textSegmentSize;
    uuid_t            dylibUuid;
    const char*        path;            // pointer invalid at end of iterations
    // following fields all exist in version 2
    uint64_t        textSegmentOffset;  // offset from start of cache
};
typedef struct dyld_shared_cache_dylib_text_info dyld_shared_cache_dylib_text_info;


#ifdef __BLOCKS__
//
// Given the UUID of a dyld shared cache file, this function will attempt to locate the cache
// file and if found iterate all images, returning info about each one.  Returns 0 on success.
//
// Exists in Mac OS X 10.11 and later
//           iOS 9.0 and later
extern int dyld_shared_cache_iterate_text(const uuid_t cacheUuid, void (^callback)(const dyld_shared_cache_dylib_text_info* info));


//
// Given the UUID of a dyld shared cache file, and a NULL terminated array of extra directory paths to search,
// this function will scan the standard and extra directories looking for a cache file that matches the UUID
// and if found iterate all images, returning info about each one.  Returns 0 on success.
//
// Exists in Mac OS X 10.12 and later
//           iOS 10.0 and later
extern int dyld_shared_cache_find_iterate_text(const uuid_t cacheUuid, const char* extraSearchDirs[], void (^callback)(const dyld_shared_cache_dylib_text_info* info));
#endif /* __BLOCKS */


//
// Gets the UUID of the dyld shared cache in the current process.
// Returns false if there is no dyld shared cache in use by the processes.
//
// Exists in Mac OS X 10.12 and later
// Exists in iOS 10.0 and later
extern bool _dyld_get_shared_cache_uuid(uuid_t uuid);

//
// Returns the start address of the dyld cache in the process and sets length to the size of the cache.
// Returns NULL if the process is not using a dyld shared cache
//
// Exists in Mac OS X 10.13 and later
// Exists in iOS 11.0 and later
extern const void* _dyld_get_shared_cache_range(size_t* length);
