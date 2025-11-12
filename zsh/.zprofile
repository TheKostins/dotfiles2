eval "$(/opt/homebrew/bin/brew shellenv)"
# Added by Toolbox App
export PATH="$PATH:/Users/kost/Library/Application Support/JetBrains/Toolbox/scripts"
[[ -o interactive ]] && source ~/.zshrc


export VULKAN_SDK="/opt/vulkansdk/1.3.283.0/macOS"
export PATH="$VULKAN_SDK/bin:$PATH"
export LD_LIBRARY_PATH="$VULKAN_SDK/lib:${LD_LIBRARY_PATH:-}"
export VK_LAYER_PATH="$VULKAN_SDK/share/vulkan/explicit_layer.d"
export VK_ICD_FILENAMES="$VULKAN_SDK/share/vulkan/icd.d"



