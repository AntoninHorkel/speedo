myProject_run = () => new Promise((resolve, reject) => {
    if (!navigator.gpu)
        reject(new Error("Failed to initilize WebGPU context: WebGPU is not supported by your browser."));
    const device = navigator.gpu.requestAdapter({ powerPreference: "high-performance" })
    .then((adapter) => adapter.requestDevice(), (error) => reject(new Error("Failed to request WebGPU adapter: " + error.message)))
    .then((device)  => {
        const pipeline = device.createComputePipeline({
            compute: {
                entryPoint: "entry",
                module:     device.createShaderModule({
                    code: "@compute @workgroup_size(8, 8) fn entry(@builtin(global_invocation_id) id : vec3<u32>) {}",
                }),
            },
            layout: "auto",
        });
        const encoder = device.createCommandEncoder();
        const pass = encoder.beginComputePass();
        pass.setPipeline(pipeline);
        pass.dispatchWorkgroups(workgroupCountX, workgroupCountY);
        pass.end();
        device.queue.submit([encoder.finish()]);
        resolve(42);
    }, (error) => reject(new Error("Failed to request WebGPU device: " + error.message)));
});
