import os

target_files = [
    'home_screen.dart',
    'snaps_reorder_strip.dart',
    'video_preview_dialog.dart',
    'retro_subscription_dialog.dart',
    'tester_feedback_dialog.dart'
]

dir_path = r'C:\MyProjects\snapbeat_flutter\lib'

for root, _, files in os.walk(dir_path):
    for filename in files:
        if filename in target_files:
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace white text/icons with dark text for contrast on white canvas
            new_content = content.replace('color: const Color(0xFFFFFFFF)', 'color: AppColors.primaryDarkText')
            new_content = new_content.replace('color: Color(0xFFFFFFFF)', 'color: AppColors.primaryDarkText')
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Fixed contrast in {filename}")
