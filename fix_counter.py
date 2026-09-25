import os

path = r'C:\MyProjects\snapbeat_flutter\lib\ui\screens\home_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove from submitRender
target_submit = "await prefs.setInt('free_render_count', count + 1);"
content = content.replace(target_submit, "")

# 2. Add to background task
target_bg = '''      await qm.updateJob(
        jobId,
        status: "READY",
        videoPath: videoPath,
        progress: 1.0,
      );'''

new_bg = target_bg + '''
      
      if (!sm.isPro) {
        final prefs = await SharedPreferences.getInstance();
        int count = prefs.getInt('free_render_count') ?? 0;
        await prefs.setInt('free_render_count', count + 1);
      }
'''
if target_bg in content and target_submit not in content:
    # it was already replaced or we just replaced it
    pass
content = content.replace(target_bg, new_bg)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Counter moved successfully")
