{
  nixos.turing = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      loadModels = ["qwen3.8:27b"];

      environmentVariables = {
        OLLAMA_IGPU_ENABLE = "1";
        OLLAMA_CONTEXT_LENGTH = "65536";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_KEEP_ALIVE = "2m";
      };
    };
  };
}
