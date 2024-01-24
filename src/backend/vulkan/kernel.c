#include <vulkan/vulkan.h>

typedef struct {
    const enum { err, ok } type;
    const char* const      msg;
} Res;

// TODO: ANSI escape codes may not work sometimes...
// This is how Zig solves it: https://ziglang.org/documentation/master/std/src/std/io/tty.zig.html
#define OK(msg)  (const Res) { ok,  "\x1B[0;1;42m INFO \x1B[0;1m  " msg "\x1B[0m\n" }
#define ERR(msg) (const Res) { err, "\x1B[0;1;41m ERROR \x1B[0;1m " msg "\x1B[0m\n" }

#define ASSERT(cond, msg) if (__builtin_expect(!(cond), 0)) return ERR(msg)

struct {
    VkInstance inst;
    VkDevice   dev;
} ctx;

inline const Res initInst() {
    ASSERT(VK_SUCCESS == vkCreateInstance(&(const VkInstanceCreateInfo) {
        .sType            = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pNext            = NULL,
        .flags            = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR,
        .pApplicationInfo = &(const VkApplicationInfo) {
            .sType              = VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .pNext              = NULL,
            .pApplicationName   = NULL,
            .applicationVersion = VK_MAKE_VERSION(0, 0, 1),
            .pEngineName        = NULL,
            .engineVersion      = VK_MAKE_VERSION(0, 0, 1),
            .apiVersion         = VK_API_VERSION_1_3,
        },
        .enabledLayerCount       = 0,
        .ppEnabledLayerNames     = NULL,
        .enabledExtensionCount   = 1,
        .ppEnabledExtensionNames = &(const char* const) { VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME },
    }, NULL, &ctx.inst), "TODO: Error message.");
    return OK("TODO: Success message.");
}

#define deinitInst() vkDestroyInstance(ctx.inst, NULL)

inline const Res initDev() {
    uint32_t physic_dev_num, physic_dev_max_score = 0, physic_dev_max_score_idx;
    ASSERT(VK_SUCCESS == vkEnumeratePhysicalDevices(ctx.inst, &physic_dev_num, NULL) && 0 != physic_dev_num,
        "TODO: Error message.");
    VkPhysicalDevice physic_dev_arr[physic_dev_num];
    ASSERT(VK_SUCCESS == vkEnumeratePhysicalDevices(ctx.inst, &physic_dev_num, physic_dev_arr),
        "TODO: Error message.");
#define physic_dev_idx physic_dev_num
    while (--physic_dev_idx) {
#define physic_dev physic_dev_arr[physic_dev_idx]
        VkPhysicalDeviceProperties physic_dev_props;
        VkPhysicalDeviceFeatures   physic_dev_feats;
        vkGetPhysicalDeviceProperties(physic_dev, &physic_dev_props);
        vkGetPhysicalDeviceFeatures(  physic_dev, &physic_dev_feats);
        // const uint32_t physic_dev_score = { 0, 1, 3, 2, 0 }[physic_dev_props.deviceType];
        // if (physic_dev_max_score < physic_dev_score) physic_dev_max_score = physic_dev_score;
        // VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU   == physic_dev_props.deviceType
        // VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU    == physic_dev_props.deviceType
        // VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU == physic_dev_props.deviceType
        // VK_API_VERSION_1_3 >= physic_dev_props.apiVersion
        // physic_dev_feats.logicOp
        // physic_dev_feats.shaderFloat64
        // physic_dev_feats.shaderInt64
        // physic_dev_feats.shaderInt16
        // physic_dev_props.limits.maxComputeSharedMemorySize
    }
    uint32_t queue_fam_props_num, queue_fam_props_max_score = 0, queue_fam_props_max_score_idx;
    vkGetPhysicalDeviceQueueFamilyProperties(physic_dev, &queue_fam_props_num, NULL);
    VkQueueFamilyProperties queue_fam_props_arr[queue_fam_props_num];
    vkGetPhysicalDeviceQueueFamilyProperties(physic_dev, &queue_fam_props_num, queue_fam_props_arr);
#define queue_fam_props_idx queue_fam_props_num
    while (--queue_fam_props_idx) {
#define queue_fam_props queue_fam_props_arr[queue_fam_props_idx]
        // queue_fam_props.queueFlags & VK_QUEUE_COMPUTE_BIT
        // queue_fam_props.queueFlags & VK_QUEUE_COMPUTE_BIT
    }
    return OK("TODO: Success message.");
}

#define deinitDev() vkDestroyDevice(ctx.dev, NULL)
