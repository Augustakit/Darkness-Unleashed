// AudioManager.js - GameFace Compatible (Minimal Changes)
// 使用 <video> 播放音频，路径相对 index.html

(function() {
    var currentVideo = null;
    
    window.playSound = function(file, volume, loop) {
        try {
            // 🔥 清理旧 video（防止冲突）
            if (currentVideo) {
                currentVideo.pause();
                currentVideo.src = "";
                // ❗️不要手动 removeChild，让 GameFace 管理生命周期
            }
            
            // 🔥 创建新 video 元素
            currentVideo = document.createElement("video");
            currentVideo.preload = "auto";
            currentVideo.style.display = "none";
            currentVideo.muted = false; // ❗️关键：必须 false 才能传音频给引擎
            
            // 在创建 video 元素后添加：
            currentVideo.setAttribute('coh-video-sync', 'off');  // 关闭视频同步，减少时间码检查
            currentVideo.setAttribute('coh-use-aa-geometry', 'off');  // 关闭抗锯齿几何，提升性能

            // 🔥 路径处理（确保 .webm 且不重复）
            var src = file;
            if (src.indexOf('.webm') === -1) {
                src = src.replace(/\.(ogg|mp3|wav)$/i, '') + '.webm';
            }
            // 🔥 确保是相对路径（你的结构：sounds/ 与 index.html 同级）
            if (src.indexOf('ui/') === 0) {
                src = src.replace(/^ui\//, '');
            }
            if (src.indexOf('/') === 0) {
                src = src.substring(1); // 移除开头的 /
            }
            
            currentVideo.src = src;
            currentVideo.volume = (typeof volume === 'number') ? volume : 0.8;
            currentVideo.loop = !!loop;
            
            // 🔥 GameFace 要求：必须添加到 DOM
            document.body.appendChild(currentVideo);
            
            // 🔥 异步播放 + 错误处理
            var p = currentVideo.play();
            if (p && p.catch) {
                p.catch(function(e) {
                    console.log("[NVG] Play error: " + e.message + " | src: " + src);
                });
            }
            
            // 🔥 播放结束后自动清理（防止内存泄漏）
            currentVideo.onended = function() {
                currentVideo.pause();
                currentVideo.src = "";
                // ❗️不手动 removeChild
            };
            
        } catch (e) {
            console.log("[NVG] playSound error: " + e.message);
        }
    };
    
    window.stopMusic = function() {
        if (currentVideo) {
            currentVideo.pause();
            currentVideo.currentTime = 0;
        }
    };
    
    // 兼容原代码的淡出函数
    window.FadeOut = function() {
        if (currentVideo) {
            var fade = setInterval(function() {
                if (currentVideo.volume > 0.01) {
                    currentVideo.volume -= 0.01;
                } else {
                    currentVideo.pause();
                    currentVideo.currentTime = 0;
                    currentVideo.volume = 0.8;
                    clearInterval(fade);
                }
            }, 100);
        }
    };
    
})();